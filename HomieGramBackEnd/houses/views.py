from django.utils.text import slugify
import time
import uuid
from django.shortcuts import get_object_or_404,  render
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.response import Response
from rest_framework.generics import RetrieveAPIView
from django.utils import timezone
from chat.models import ChatRoom
from houses.mpesa import MpesaHandler
from accounts.models import CustomUser
from django.utils.crypto import get_random_string
from .utils import get_safe_group_name
from .serializers import AdvertisementSerializer, AmenitiesSerializer, BookmarkSerializer, CareTakersSerializer, HouseRatingSerializer, HouseWithRoomsSerializer, HousesSerializers, LocationSerializer, RoomAndTenancySerializer, RoomSerializer, TenancyAgreementSerializer
from .models import Advertisement, Amenity, Bookmark, CareTaker, Charge, HouseImage, HouseRating, Houses, Location, Payment, PaymentItem, Room, PendingAdvertisement, RoomImage, TenancyAgreement, Receipt
from rest_framework.permissions import  IsAuthenticated
from django.template.loader import render_to_string
from django.core.mail import EmailMultiAlternatives
from django.db import transaction
from datetime import datetime
from django.utils import timezone
from weasyprint import HTML
from django.http import HttpResponse
import tempfile
from django.conf import settings

def generate_receipt(payment):
    if hasattr(payment, "receipt"): 
        return payment.receipt
    
    receipt_number = f"RCPT-{get_random_string(8).upper()}"
    receipt = Receipt.objects.create(
        payment=payment,
        tenant=payment.tenant,
        receipt_number=receipt_number,
        amount=payment.amount,
    )
    return receipt

def create_private_chat_if_not_exists(user1, user2):
        if user1 == user2:
            return  # skip self-chat

        # Sort users for consistent room naming
        sorted_ids = sorted([user1.id, user2.id])
        private_room_name = f"user_{sorted_ids[0]}_{sorted_ids[1]}"

        room, created = ChatRoom.objects.get_or_create(
            name=private_room_name,
            defaults={"is_group": False},
        )
        room.participants.add(user1, user2)

# def send_receipt_email(receipt):
#     subject = f"Your Payment Receipt - {receipt.receipt_number}"
#     from_email = "no-reply@yourapp.com"
#     recipient_list = [receipt.tenant.email]

#     html_content = render_to_string("receipt.html", {"receipt": receipt})
    
#     msg = EmailMultiAlternatives(subject, "", from_email, recipient_list)
#     msg.attach_alternative(html_content, "text/html")
#     msg.send()

def send_receipt_email(receipt):
    """
    Sends a detailed payment receipt email (HTML + PDF attachment) to the tenant.
    """
    subject = f"Your Payment Receipt - {receipt.receipt_number}"
    from_email = settings.DEFAULT_FROM_EMAIL
    to = [receipt.tenant.email]

    context = {
        "receipt": receipt,
        "payment": receipt.payment,
        "items": receipt.payment.items.all(),
        "support_email": settings.DEFAULT_FROM_EMAIL,
    }

    # Render both text and HTML versions
    html_content = render_to_string("emails/receipt.html", context)
    text_content = render_to_string("emails/receipt.txt", context)

    # Convert HTML to PDF
    pdf_file = HTML(string=html_content).write_pdf()

    # Build the email
    email = EmailMultiAlternatives(subject, text_content, from_email, to)
    email.attach_alternative(html_content, "text/html")
    email.attach(
        f"Receipt_{receipt.receipt_number}.pdf",
        pdf_file,
        "application/pdf"
    )

    # Send email
    email.send(fail_silently=False)

def compute_charges(agreement, is_first_payment):
    items, total_amount = [], 0

    # Only applies for the first time.
    if is_first_payment:
        items.append({"name": "Monthly Rent", "amount": agreement.room.rent})
        total_amount += agreement.room.rent
        items.append({"name": "Deposit Rent", "amount": agreement.room.rent})
        total_amount += agreement.room.rent
        if getattr(agreement.house, "security_deposit", None):
            items.append({"name": "Security Deposit", "amount": agreement.house.security_deposit})
            total_amount += agreement.house.security_deposit
        if getattr(agreement.house, "water_deposit", None):
            items.append({"name": "Water Deposit", "amount": agreement.house.water_deposit})
            total_amount += agreement.house.water_deposit

    # normal payments - after first payment.
    today = timezone.now().date()
    charges = agreement.charges.filter(
        month__month=today.month, month__year=today.year, is_paid=False
    )
    for c in charges:
        items.append({"name": c.name, "amount": c.amount})
        total_amount += c.amount

    return items, total_amount

def format_phone_number(raw_number):
    num = str(raw_number).replace(" ", "").replace("+", "")
    if num.startswith("0"):
        return "254" + num[1:]
    elif not num.startswith("254"):
        return "254" + num
    return num

def get_valid_until(paid_at=None):
    paid_at = paid_at or timezone.now()
    year = paid_at.year
    month = paid_at.month

    # Determine next month and year
    if month == 12:
        next_month = 1
        next_year = year + 1
    else:
        next_month = month + 1
        next_year = year

    # Valid until 5th of next month
    valid_until = datetime(next_year, next_month, 5)
    return valid_until


def generate_tenancy_agreement_pdf(request, agreement_id):
    agreement = get_object_or_404(TenancyAgreement, id=agreement_id)

    # Render HTML template with context
    html_string = render_to_string("tenancy_agreement_template.html", {
        "agreement": agreement,
        "tenant": agreement.tenant,
        "house": agreement.house,
        "room": agreement.room,
    })

    # Create PDF in memory
    with tempfile.NamedTemporaryFile(delete=True) as output:
        HTML(string=html_string).write_pdf(output.name)
        output.seek(0)
        response = HttpResponse(output.read(), content_type="application/pdf")
        filename = f"tenancy_agreement_{agreement.tenant.username}_{agreement.id}.pdf"
        response["Content-Disposition"] = f'attachment; filename="{filename}"'
        return response

def agreement_detail(request, pk):
    """
    Render the tenancy agreement as HTML in browser.
    """
    agreement = get_object_or_404(TenancyAgreement, pk=pk)
    context = {
        'agreement': agreement,
        'house': getattr(agreement, 'house', None),
        'room': getattr(agreement, 'room', None),
    }
    return render(request, 'tenancy_agreement_template.html', context)

def agreement_pdf(request, pk):
    """
    Generate a PDF from the same template and return as attachment.
    """
    agreement = get_object_or_404(TenancyAgreement, pk=pk)
    context = {
        'agreement': agreement,
        'house': getattr(agreement, 'house', None),
        'room': getattr(agreement, 'room', None),
    }
    html_string = render_to_string('tenancy_agreement_template.html', context, request=request)

    base_url = request.build_absolute_uri('/') 
   
    html = HTML(string=html_string, base_url=base_url)
    result = html.write_pdf()

   
    filename = f"Tenancy_Agreement_for_{agreement.tenant.username}.pdf"
    response = HttpResponse(result, content_type='application/pdf')
    response['Content-Disposition'] = f'attachment; filename="{filename}"'
    return response

class HouseAPIView(APIView):
    """
    Handles All House Processes
    """

    permission_classes = [IsAuthenticated]


    def get (self, request, *args , **kwargs):
        """
        get all houses in the database
        """
        houses = Houses.objects.all()
        serializer = HousesSerializers(houses, many=True)
       
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        Create a new house and a corresponding chat room with the house name.
        """
        serializer = HousesSerializers(data=request.data)
        if serializer.is_valid():
            house = serializer.save()

            user = request.user 

            safe_name = get_safe_group_name(house.name, house.id)
            
            room, created = ChatRoom.objects.get_or_create(
                name=safe_name,
                defaults={'is_group': True}
            )

           
            room.participants.add(user)

            if request.FILES:
                for key, image in request.FILES.items():
                    HouseImage.objects.create(house=house, image=image)

            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def patch(self, request, house_id):
        try:
            house = Houses.objects.get(id=house_id)
        except Houses.DoesNotExist:
            return Response({"detail": "House not found"}, status=404)
        serializer = HousesSerializers(house, data=request.data, partial=True)
        if serializer.is_valid():
            house = serializer.save()

          
            if 'images' in request.FILES:
                images = request.FILES.getlist('images')
                for image in images:
                    HouseImage.objects.create(house=house, image=image)

            return Response(serializer.data, status=200)
        return Response(serializer.errors, status=400)

class HouseWithRoomsAPIView(APIView):
    """
    Fetches all houses along with their rooms
    """
    permission_classes = [IsAuthenticated]
    def get(self, request, *args, **kwargs):
        houses = Houses.objects.prefetch_related('rooms').all()
        serializer = HouseWithRoomsSerializer(houses, many=True)
  
        return Response(serializer.data, status=status.HTTP_200_OK)

class SearchApiView(RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    lookup_field = "name"
    queryset = Houses.objects.all()
    serializer_class = HousesSerializers

class SubmitHouseRating(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = HouseRatingSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Rating submitted successfully.", "data": serializer.data}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        # List all ratings of the logged-in user
        ratings = HouseRating.objects.filter(user=request.user)
        serializer = HouseRatingSerializer(ratings, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class LocationsAPIView(APIView):

    permission_classes = [IsAuthenticated]
    def get (self, request, *args , **kwargs):
        """
        get all locations in the database
        """
        locations = Location.objects.all()
        serializer = LocationSerializer(locations, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args , **kwargs):
        """
        post new location
        """

        serializer = LocationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class GetRoomssAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def get (self, request, *args , **kwargs):
        """
        get all rooms in the database
        """
        Rooms = Room.objects.all()
        serializer = RoomSerializer(Rooms, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        serializer = RoomSerializer(data=request.data)
        if serializer.is_valid():
            room = serializer.save()

            images = request.FILES.getlist('images')

            for image in images:
                RoomImage.objects.create(room=room, image=image)

            return Response(
                {"detail": "Room added successfully.", "room": RoomSerializer(room).data},
                status=status.HTTP_201_CREATED
            )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def patch(self, request, *args, **kwargs):
        """
        Partially update an existing room
        """
        try:
            room = Room.objects.get(id=kwargs['room_id'])  
        except Room.DoesNotExist:
            return Response({"detail": "Room not found."}, status=status.HTTP_404_NOT_FOUND)

        serializer = RoomSerializer(room, data=request.data, partial=True)  
        if serializer.is_valid():
            serializer.save()  
            return Response(serializer.data, status=status.HTTP_200_OK) 
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class MyRoomsAPIView(APIView):

    permission_classes = [IsAuthenticated]
    def get(self, request, *args, **kwargs):
        """
        Get rooms that belong to the current logged-in user
        """
        user = request.user
        my_rooms = Room.objects.filter(tenant=user)  # filter rooms by tenant
        serializer = RoomAndTenancySerializer(my_rooms, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class AmenitiessAPIView(APIView):

    permission_classes = [IsAuthenticated]

    def get (self, request, *args , **kwargs):
        """
        get all amenities in the database
        """
        amenities = Amenity.objects.all()
        serializer = AmenitiesSerializer(amenities, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args , **kwargs):
        """
        post new amenities
        """

        serializer = AmenitiesSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class GetBookmarksAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get (self, request, *args , **kwargs):
        """
        get all bookmarks in the database
        """
        bookmarks = Bookmark.objects.all()
        serializer = BookmarkSerializer(bookmarks, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class AddBookmarkView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, house_id, *args, **kwargs):
        try:
            house = Houses.objects.get(id=house_id)
        except Houses.DoesNotExist:
            return Response({'error': 'House not found'}, status=status.HTTP_404_NOT_FOUND)

        bookmark, created = Bookmark.objects.get_or_create(user=request.user, house=house)
        if created:
            return Response({'message': 'Bookmark added'}, status=status.HTTP_201_CREATED)
        return Response({'message': 'Bookmark already exists',}, status=status.HTTP_200_OK)

class RemoveBookmarkView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, house_id, *args, **kwargs):
        try:
            bookmark = Bookmark.objects.get(house=house_id, user=request.user.id)
        except Bookmark.DoesNotExist:
            return Response({'error': 'Bookmark not found'}, status=status.HTTP_404_NOT_FOUND)

        bookmark.delete()
        return Response({'message': 'Bookmark removed'}, status=status.HTTP_204_NO_CONTENT)

class SubmitAdvertisementAPIView(APIView):
    """
    User submits an ad, but it's not saved in the main advertisement model until payment is confirmed.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = AdvertisementSerializer(data=request.data)
        
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data ,status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ConfirmPaymentAPIView(APIView):
    """
    After payment, this endpoint verifies payment status and moves the ad to the main model.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        payment_reference = request.data.get("payment_reference")
        if not payment_reference:
            return Response({"error": "Payment reference required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            ad = PendingAdvertisement.objects.get(payment_reference=payment_reference)
            # Simulate payment verification (Replace with real payment API check)
            payment_verified = True  # Assume payment is successful for now

            if payment_verified:
                # Move ad to main Advertisement model
                Advertisement.objects.create(
                    title=ad.title,
                    description=ad.description,
                    image=ad.image,
                    video_file=ad.video_file,
                    start_date=ad.start_date,
                    end_date=ad.end_date
                )
                ad.delete()  # Remove from pending ads
                return Response({"message": "Payment confirmed. Ad is now active."}, status=status.HTTP_200_OK)

            return Response({"error": "Payment not verified"}, status=status.HTTP_400_BAD_REQUEST)

        except PendingAdvertisement.DoesNotExist:
            return Response({"error": "Invalid payment reference"}, status=status.HTTP_404_NOT_FOUND)

class GetAdvertisementsAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        today = timezone.now

      
        status_param = request.query_params.get('status', None)

        
        adverts = Advertisement.objects.all()

        if status_param in ['pending', 'active', 'expired']:
            adverts = adverts.filter(status=status_param)
            
        for ad in adverts:
            ad.update_status()
            ad.save()

        serializer = AdvertisementSerializer(adverts, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class AssignTenantView(APIView):
    permission_classes = [IsAuthenticated]
     
    def create_private_chat_if_not_exists(user1, user2):
        if user1 == user2:
            return  # skip self-chat

        # Sort users for consistent room naming
        sorted_ids = sorted([user1.id, user2.id])
        private_room_name = f"user_{sorted_ids[0]}_{sorted_ids[1]}"

        room, created = ChatRoom.objects.get_or_create(
            name=private_room_name,
            defaults={"is_group": False,  "label": user2.username if user1.id == sorted_ids[0] else user1.username},
            
        )
        room.participants.add(user1, user2)

    def post(self, request, house_id):
        # Get the house object
        house = Houses.objects.filter(id=house_id).first()
        if not house:
            return Response({"error": "House not found"}, status=status.HTTP_404_NOT_FOUND)

        landlord = house.landlord_id
        caretaker = house.caretaker
        house_group_name = f"{house.name}_official"

        # Get room_id from request
        room_id = request.data.get("room_id")
        if not room_id:
            return Response({"error": "room_id is required"}, status=status.HTTP_400_BAD_REQUEST)

        # Find the specific room (and assume FE only sends empty ones)
        try:
            room = Room.objects.get(id=room_id, apartment=house, occupied=False)
        except Room.DoesNotExist:
            return Response({"error": "Room not available"}, status=status.HTTP_400_BAD_REQUEST)

        tenant = request.user

        # Create tenancy agreement first
        agreement = TenancyAgreement.objects.create(
            tenant=tenant,
            house=house,
            room=room,
            status="pending"  
        )

        # 2) Create a payment entry (pending by default)
        payment = Payment.objects.create(
            tenant=tenant,
            house=house,
            room=room,
            amount=room.rent,
            payment_reference=str(uuid.uuid4()),
            status="pending",
            valid_until=timezone.now(),  # will update when confirmed
        )

        mpesa_client = MpesaHandler()
        stk_data = {
            'amount': room.rent,
            'phone_number': tenant.phone_number,
        }

        res_status, res_data = mpesa_client.make_stk_push(stk_data)

        if res_status != 200:
                payment.mark_failed(res_data)
                return Response(
                    {
                        "error": res_data.get("errorMessage", "Failed to initiate STK push"),
                        "payment_id": payment.id,
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )
        
        payment.save()

        checkout_id = res_data.get("CheckoutRequestID")

        num_of_tries = 0
        trans_status, trans_response = None, None
        while True:
            time.sleep(12)
            trans_status, trans_response = mpesa_client.query_transaction_status(checkout_id)

            # break when we get a meaningful response or timeout
            if trans_status == 200 and trans_response and "ResultCode" in trans_response:
                break

            if num_of_tries >= 60:
                break

            num_of_tries += 1


    
        if trans_status == 200 and trans_response.get("ResultCode") == "0":
            # Payment confirmed
            payment.status = "confirmed"
            payment.save()
      
            # Approve agreement and assign tenant to room
            agreement.status = "active"
            agreement.save()

          

            room.assign_tenant(tenant)  # assuming this method exists and saves
            room.rent_status = True
            room.save()
     
            # Ensure official house group exists and add participant
            
            house_group_name = f"{slugify(house.name)}-official"
            house_group, created = ChatRoom.objects.get_or_create(
                name=house_group_name,
                defaults={"is_group": True},
            )
            house_group.participants.add(tenant)

            # Landlord & caretaker chats
            landlord = house.landlord_id
            caretaker = house.caretaker
            create_private_chat_if_not_exists(tenant, landlord)
            if caretaker:
                create_private_chat_if_not_exists(tenant, caretaker.user_id)

            # Return updated room data + payment info
            room_data = RoomSerializer(room).data
            return Response(
                {
                    "status": "success",
                    "message": "Payment confirmed and tenancy activated",
                    "room": room_data,
                    "payment_id": payment.id,
                    "payment_reference": payment.payment_reference,
                    
                },
                status=status.HTTP_200_OK,
            )

        # Payment failed / timed out
        payment.status = "failed"
        payment.save()
        return Response(
            {
                "status": "error",
                "message": (trans_response or {}).get("ResultDesc", "Payment failed or timed out"),
                "payment_id": payment.id,
                "mpesa_result": trans_response,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )
# step 1: initiate.
class StartRentView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        house_id = request.data.get("house_id")
        room_id = request.data.get("room_id")

        if not house_id or not room_id:
            return Response({"error": "house_id and room_id are required"}, status=400)

        try:
            # TODO : get more info on this
            with transaction.atomic():
                # lock the room row to prevent race conditions
                room = Room.objects.select_for_update().get(
                    id=room_id, apartment_id=house_id
                )
                if room.occupied:
                    return Response({"error": "This room is already occupied"}, status=400)

             
                has_existing_agreement = TenancyAgreement.objects.filter(
                    tenant=request.user,
                    room=room,
                    status__in=["pending", "approved", "active"]
                ).first()

                if has_existing_agreement:
                    return Response(
                        {
                            "error": "You already have an existing agreement for this room.",
                            "agreement": TenancyAgreementSerializer(has_existing_agreement).data,
                        },
                        status=200
                    )

                # create new pending agreement safely inside the lock
                new_agreement = TenancyAgreement.objects.create(
                    tenant=request.user,
                    house=room.apartment,
                    room=room,
                    status="pending"
                )

                return Response(
                    {"agreement": TenancyAgreementSerializer(new_agreement).data},
                    status=201
                )

        except Room.DoesNotExist:
            return Response({"error": "Room not found"}, status=404)
# Step 2: Confirm agreement
class ConfirmAgreementView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        agreement_id = request.data.get("agreement_id")
        if not agreement_id:
            return Response({"error": "agreement_id is required"}, status=400)

        agreement = get_object_or_404(
            TenancyAgreement,
            id=agreement_id,
            tenant=request.user,
            status__in=["pending", "approved"]
        )

        if agreement.status == "pending":
            agreement.status = "approved"
            agreement.signed_at = timezone.now()
            agreement.save(update_fields=["status", "signed_at"])

            message = "Agreement confirmed successfully. Proceed to payment."
        else:
   
            message = "Agreement already confirmed. Proceed to payment."

        return Response({
            "message": message,
            "agreement": TenancyAgreementSerializer(agreement).data
        }, status=200)
# Step 3: Initiate payment
class RentPaymentPreviewView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        agreement_id = request.data.get("agreement_id")
        agreement = get_object_or_404(
            TenancyAgreement,
            id=agreement_id,
            tenant=request.user,
            status__in=["approved"]
        )

        is_first_payment = not Payment.objects.filter(
            agreement=agreement, status="Confirmed"
        ).exists()

        items, total_amount = compute_charges(agreement, is_first_payment)

        return Response({
            "agreement_id": agreement.id,
            "is_first_payment": is_first_payment,
            "items": items,
            "total": total_amount,
        })

class RentPaymentInitiateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            agreement_id = request.data.get("agreement_id")
            if not agreement_id:
                return Response({"error": "agreement_id is required"}, status=400)

            agreement = get_object_or_404(
                TenancyAgreement,
                id=agreement_id,
                tenant=request.user,
                status__in=["approved", "active"]
            )

            #  Check for an existing pending payment
            existing_payment = Payment.objects.filter(
                agreement=agreement,
                tenant=request.user,
                status="pending"
            ).first()

            if existing_payment:
                # Calculate how long ago the payment was created
                time_diff = timezone.now() - existing_payment.created_at

                if time_diff.total_seconds() < 120 and existing_payment.status == "pending":
                    # Less than 2 minutes since creation and still pending — tell user to wait
                    return Response({
                        "message": (
                            "You already have a pending payment. "
                            "Please complete it on your phone. "
                            "If you cancelled, wait 2 minutes before trying again."
                        ),
                        "payment_id": existing_payment.id,
                        "checkout_request_id": existing_payment.checkout_request_id,
                        "status": existing_payment.status,
                    }, status=200)

                # Mark old pending payments as failed if they timed out
                if existing_payment.status == "pending":
                    existing_payment.status = "failed"
                    existing_payment.failure_reason = "Timed out - user did not complete payment"
                    existing_payment.save()

            # Compute charges again
            is_first_payment = not Payment.objects.filter(
                agreement=agreement, status="confirmed"
            ).exists()

            items, total_amount = compute_charges(agreement, is_first_payment)

            # Create new pending payment
            payment = Payment.objects.create(
                agreement=agreement,
                tenant=request.user,
                house=agreement.house,
                room=agreement.room,
                amount=total_amount,
                status="pending",
            )

            for item in items:
                PaymentItem.objects.create(payment=payment, name=item["name"], amount=item["amount"])

            phone_number = format_phone_number(request.user.phone_number)

            # Initiate STK push
            mpesa = MpesaHandler()
            res_status, res_data = mpesa.make_stk_push({
                "amount": total_amount,
                "phone_number": phone_number 
            })

            if not res_status or res_data.get("errorCode"):
                payment.status = "failed"
                payment.failure_reason = res_data.get("errorMessage", "STK Push failed")
                payment.save()

                return Response({
                    "success": False,
                    "message": "Failed to initiate payment.",
                    "errors": {
                        "mpesa_code": res_data.get("errorCode"),
                        "reason": res_data.get("errorMessage", "Unknown error"),
                    },
                    "payment_id": payment.id
                }, status=status.HTTP_400_BAD_REQUEST)

            # [3] Success case
            payment.checkout_request_id = res_data.get("CheckoutRequestID")
            payment.status = "pending"
            payment.save()

            return Response({
                "success": True,
                "message": "STK push initiated successfully. Please complete payment on your phone.",
                "data": {
                    "payment_id": payment.id,
                    "amount": total_amount,
                    "items": items,
                    "mpesa_response": {
                        "CheckoutRequestID": res_data.get("CheckoutRequestID"),
                        "MerchantRequestID": res_data.get("MerchantRequestID"),
                        "ResponseDescription": res_data.get("ResponseDescription"),
                        "CustomerMessage": res_data.get("CustomerMessage")
                    }
                }
            }, status=status.HTTP_200_OK)

        except Exception as e:
            # Handle unexpected errors gracefully
            import traceback
            print("Unexpected error during payment initiation:", traceback.format_exc())
            return Response({
                "success": False,
                "message": "An unexpected error occurred while processing your payment.",
                "error": str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class PaymentStatusView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, *args, **kwargs):
        payment_id = request.data.get("payment_id")
        payment = get_object_or_404(Payment, id=payment_id, tenant=request.user)
        if payment.status == "confirmed":
            receipt = generate_receipt(payment)
            return Response({
                "status": "confirmed",
                "agreement_id": payment.agreement.id,
                "receipt_number": receipt.receipt_number,
                "amount": str(receipt.amount),
                "date_issued": receipt.date_issued,
            })
        return Response({"status": payment.status})
    
class MpesaCallbackView(APIView):
    def post(self, request, *args, **kwargs):
        body = request.data.get("Body", {})
        stk_callback = body.get("stkCallback", {})

        result_code = stk_callback.get("ResultCode")
        result_desc = stk_callback.get("ResultDesc")
        checkout_request_id = stk_callback.get("CheckoutRequestID")

        # 1. Find the payment
        payment = Payment.objects.filter(checkout_request_id=checkout_request_id).first()
        if not payment:
            return Response({"error": "Payment not found"}, status=404)

        # 2. If success
        if result_code == 0:
            metadata = {item["Name"]: item.get("Value") for item in stk_callback.get("CallbackMetadata", {}).get("Item", [])}
            amount = metadata.get("Amount")
            receipt_number = metadata.get("MpesaReceiptNumber")

            payment.status = "confirmed"
            payment.amount = amount
            payment.mpesa_receipt = receipt_number
            payment.paid_at = timezone.now()
            payment.valid_until = get_valid_until(payment.paid_at)
            payment.save()

            # Mark charges as paid
            for item in payment.items.all():
                if item.name in ["Water", "Electricity", "Garbage"]:
                    Charge.objects.filter(
                        agreement=payment.agreement,
                        name=item.name,
                        month__month=payment.paid_at.month,
                        month__year=payment.paid_at.year
                    ).update(is_paid=True)

            # Create receipt
            receipt = Receipt.objects.create(
                payment=payment,
                tenant=payment.tenant,
                receipt_number=f"RCT-{payment.id}-{int(timezone.now().timestamp())}",
                amount=payment.amount
            )

            agreement = payment.agreement
            if agreement.status == "approved":
                agreement.status = "active"
                agreement.start_date = timezone.now()
                agreement.save()

                # Optionally mark room as occupied
                agreement.room.occupied = True
                agreement.room.save()
            
            room = agreement.room
            if room:
                room.tenant = agreement.tenant
                room.assign_tenant(agreement.tenant) 
                room.rent_status = True
                room.last_payment_date=timezone.now()
                room.save()

            house = agreement.house
            tenant = agreement.tenant
            caretaker = house.caretaker

            house_group_name = get_safe_group_name(house.name, house.id)
            house_group, created = ChatRoom.objects.get_or_create(
                name=house_group_name,
                defaults={"is_group": True},
            )

            if not house_group.participants.filter(id=tenant.id).exists():
                house_group.participants.add(tenant)

            if caretaker:
                create_private_chat_if_not_exists(tenant, caretaker.user_id)
            # send the reciept
            send_receipt_email(receipt)
            return Response({
                "status": "success",
                "receipt_number": receipt.receipt_number
            })

        # 3. If failed
        else:
            payment.status = "failed"
            payment.failure_reason = result_desc
            payment.save()
            return Response({"status": "failed", "reason": result_desc})

class AssignCaretakerView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request):
        user_id = request.data.get('user_id')
        house_id = request.data.get('house_id')

        try:
            user = CustomUser.objects.get(pk=user_id)
            house = Houses.objects.get(pk=house_id)
        except (CustomUser.DoesNotExist, Houses.DoesNotExist) as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        caretaker, created = CareTaker.objects.get_or_create(user_id=user, house_id=house)
        return Response(
            {"message": "Caretaker assigned successfully", "created": created},
            status=status.HTTP_200_OK
        )

class RemoveCaretakerView(APIView):
    permission_classes = [IsAuthenticated]
    def delete(self, request):
        caretaker_id = request.data.get('caretaker_id')
        house_id = request.data.get('house_id')

        try:
            caretaker = CareTaker.objects.get(pk=caretaker_id, house_id=house_id)
            caretaker.delete()
            return Response({"message": "Caretaker removed successfully!"}, status=status.HTTP_200_OK)
        except CareTaker.DoesNotExist:
            return Response({"error": "Caretaker not found"}, status=status.HTTP_404_NOT_FOUND)

class GetCaretakersAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get (self, request, *args , **kwargs):
        """
        get all caretakers in the database
        """
        caretakers = CareTaker.objects.all()
        serializer = CareTakersSerializer(caretakers, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class RequestTerminationAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, agreement_id):
        try:
            agreement = TenancyAgreement.objects.get(id=agreement_id, tenant=request.user)
        except TenancyAgreement.DoesNotExist:
            return Response({"error": "Agreement not found"}, status=404)

        if agreement.status != "active":
            return Response({"error": "Agreement is not active"}, status=400)

        agreement.termination_requested = True
        agreement.save()

        return Response({"message": "Termination request submitted, awaiting approval"}, status=200)

class ApproveTerminationAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, agreement_id):
        # Only system/admins should hit this endpoint
        try:
            agreement = TenancyAgreement.objects.get(id=agreement_id, termination_requested=True)
        except TenancyAgreement.DoesNotExist:
            return Response({"error": "No termination request found"}, status=404)

        agreement.status = "terminated"
        agreement.end_date = timezone.now()
        agreement.save()

        # Free the room
        room = agreement.room
        room.tenant = None
        room.occupied = False
        room.rent_status = False
        room.save()

        return Response({"message": "Agreement terminated successfully"}, status=200)