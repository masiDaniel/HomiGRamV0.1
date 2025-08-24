import time
from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.response import Response
from rest_framework.generics import RetrieveAPIView
from datetime import  datetime, timezone
import uuid

from chat.models import ChatRoom
from houses.mpesa import MpesaHandler
from accounts.models import CustomUser

from .utils import check_payment_status
from .serializers import AdvertisementSerializer, AmenitiesSerializer, BookmarkSerializer, CareTakersSerializer, HousesSerializers, LocationSerializer, RoomSerializer,  PendingAdvertisementSerializer
from accounts.serializers import MessageSerializer
from .models import Advertisement, Amenity, Bookmark, CareTaker, HouseRating, Houses, Location, Room, PendingAdvertisement

# Create your views here.

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


class HouseAPIView(APIView):
    """
    Handles All House Processes
    """


    def get (self, request, *args , **kwargs):
        """
        get all houses in the database
        """
        houses = Houses.objects.all()
        serializer = HousesSerializers(houses, many=True)
        # if serializer:
        #     mpesa_client = MpesaHandler()
        #     stk_data = {
        #         'amount': 10000,
        #         'phone_number': '254799212379'
        #     }
        #     res_status, res_data = mpesa_client.make_stk_push(stk_data)
        #     if res_status  == 200:
        #         num_of_tries = 0
        #         while True:

        #             #asynchronus progrgramming
        #             time.sleep(1)
        #             trans_status, trans_response = mpesa_client.query_transaction_status(res_data['CheckoutRequestID'])

        #             if trans_status == 200:
        #                 break

        #             if num_of_tries == 60:
        #                 break

        #             num_of_tries += 1


        #         if trans_status == 200 and trans_response['ResultCode'] == '0':
        #             serializer.save()

        #             pass
        #         else:
        #             return Response({'error': trans_response['ResultDesc']}, status=status.HTTP_400_BAD_REQUEST)

                
        #     else:
        #         return Response({'error': res_data['errorMessage']}, status=status.HTTP_400_BAD_REQUEST)
                



        #     ad = serializer.save(payment_reference=str(uuid.uuid4()))  # Generate payment reference
        #     payment_reference=str(uuid.uuid4())

        #     return Response(
        #         {"message": "Payment required", "payment_link": payment_reference},
        #         status=status.HTTP_202_ACCEPTED
        #     )
     
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        Create a new house and a corresponding chat room with the house name.
        """
        serializer = HousesSerializers(data=request.data)
        if serializer.is_valid():
            house = serializer.save()

            user = request.user 

            
            room, created = ChatRoom.objects.get_or_create(
                name=house.name,
                defaults={'is_group': True}
            )

           
            room.participants.add(user)

            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def patch(self, request, *args, **kwargs):
        """
        Partially update an existing house
        """
        try:
            house = Houses.objects.get(id=kwargs['house_id'])  
        except Houses.DoesNotExist:
            return Response({"detail": "House not found."}, status=status.HTTP_404_NOT_FOUND)

        serializer = HousesSerializers(house, data=request.data, partial=True)  
        if serializer.is_valid():
            serializer.save()  
            return Response(serializer.data, status=status.HTTP_200_OK) 
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class SearchApiView(RetrieveAPIView):
    lookup_field = "name"
    queryset = Houses.objects.all()
    serializer_class = HousesSerializers

class RateHouseAPIView(APIView):
    # permission_classes = [IsAuthenticated]

    def post(self, request, house_id, *args, **kwargs):
        house = Houses.objects.get(id=house_id)
        rating_value = request.data.get('rating')
        comment = request.data.get('comment', '')

        rating, created = HouseRating.objects.update_or_create(
            house=house,
            user=request.user,
            defaults={'rating': rating_value, 'comment': comment}
        )

        house.update_average_rating()  # Update the average rating after a new rating is saved

        return Response({"message": "Rating submitted successfully"}, status=status.HTTP_200_OK)

class LocationsAPIView(APIView):

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

    def get (self, request, *args , **kwargs):
        """
        get all rooms in the database
        """
        Rooms = Room.objects.all()
        serializer = RoomSerializer(Rooms, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        Create new multiple rooms in the database
        """
        rooms_data = request.data  # Expecting a list of room data
        if not isinstance(rooms_data, list):
            return Response({"detail": "Request body should be a list of room data."}, status=status.HTTP_400_BAD_REQUEST)
        
        rooms = []
        for room_data in rooms_data:
            serializer = RoomSerializer(data=room_data)
            if serializer.is_valid():
                rooms.append(serializer.save())  # Save the valid room
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        return Response({"detail": "Rooms added successfully."}, status=status.HTTP_201_CREATED)
    
    def patch(self, request, *args, **kwargs):
        """
        Partially update an existing house
        """
        try:
            house = Room.objects.get(id=kwargs['house_id'])  
        except Houses.DoesNotExist:
            return Response({"detail": "House not found."}, status=status.HTTP_404_NOT_FOUND)

        serializer = HousesSerializers(house, data=request.data, partial=True)  
        if serializer.is_valid():
            serializer.save()  
            return Response(serializer.data, status=status.HTTP_200_OK) 
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class AmenitiessAPIView(APIView):

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

    def get (self, request, *args , **kwargs):
        """
        get all bookmarks in the database
        """
        bookmarks = Bookmark.objects.all()
        serializer = BookmarkSerializer(bookmarks, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
        

class AddBookmarkView(APIView):
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

    def get(self, request, *args, **kwargs):
        today = datetime.now(timezone.utc).date()

      
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
        landlord = house.landlord_id
        CareTaker = house.caretaker
        house_group_name = f"{house.name}_official" 
        
        if not house:
            return Response({"error": "House not found"}, status=status.HTTP_404_NOT_FOUND)

        # Find an empty room in the house (where occupied=False)
        empty_room = Room.objects.filter(apartment=house, occupied=False).first()

        if not empty_room:
            return Response({"error": "No empty rooms available in this house"}, status=status.HTTP_400_BAD_REQUEST)

        # Simulate checking payment status (you would integrate with an actual payment gateway here)
        payment_confirmed = check_payment_status(empty_room)
        
        if not payment_confirmed:
            return Response({"error": "Payment not confirmed"}, status=status.HTTP_400_BAD_REQUEST)

      
        tenant = request.user
        empty_room.assign_tenant(tenant)

        
        empty_room.rent_status = True
        empty_room.save()

        house_group, created = ChatRoom.objects.get_or_create(
        name=house_group_name,
        defaults={"is_group": True},
        )
        
        house_group.participants.add(tenant)

        create_private_chat_if_not_exists(tenant, landlord)

        if CareTaker:
            create_private_chat_if_not_exists(tenant, CareTaker.user_id)

       
        room_data = RoomSerializer(empty_room).data 
        return Response(room_data, status=status.HTTP_200_OK)
    
    



class AssignCaretakerView(APIView):
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

    def get (self, request, *args , **kwargs):
        """
        get all caretakers in the database
        """
        caretakers = CareTaker.objects.all()
        serializer = CareTakersSerializer(caretakers, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)