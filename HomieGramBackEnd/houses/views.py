from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.response import Response
from rest_framework.generics import RetrieveAPIView

from accounts.models import CustomUser

from .utils import check_payment_status
from .serializers import AdvertisementSerializer, AmenitiesSerializer, BookmarkSerializer, CareTakersSerializer, HousesSerializers, LocationSerializer, RoomSerializer
from accounts.serializers import MessageSerializer
from .models import Advertisement, Amenity, Bookmark, CareTaker, HouseRating, Houses, Location, Room

# Create your views here.
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
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        Create a new house
        """
        serializer = HousesSerializers(data=request.data)  # Pass the incoming data to the serializer
        if serializer.is_valid():  # Validate the data
            serializer.save()  # Save the house if the data is valid
            return Response(serializer.data, status=status.HTTP_201_CREATED)  # Respond with the created house data
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST) 
    

    # def post(self, request, *args, **kwargs):
    #     """
    #     Used to get a house by id
    #     """
    #     house_id = request.data.get("house_id")
    #     house = Houses.objects.get(id=house_id)

    #     # sent house id doesn't exist
    #     if not house:
    #         message = {"message": "House Doesn't Exist"}
    #         serializer = MessageSerializer(message)
    #         return Response(serializer.data, status=status.HTTP_400_BAD_REQUEST)
        
    #     serializer = HousesSerializers(house)
    #     return Response(serializer.data, status=status.HTTP_200_OK)
    
class GetHouseAPIView(RetrieveAPIView):
    pass


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

class GetLocationsAPIView(APIView):

    def get (self, request, *args , **kwargs):
        """
        get all locations in the database
        """
        locations = Location.objects.all()
        serializer = LocationSerializer(locations, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
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

class GetAmenitiessAPIView(APIView):

    def get (self, request, *args , **kwargs):
        """
        get all amenities in the database
        """
        locations = Amenity.objects.all()
        serializer = AmenitiesSerializer(locations, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
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

class getAdvvertismentsAPIView(APIView):

    def get (self, request, *args , **kwargs):
        """
        get all adverst in the database for today
        """
        adverts = Advertisement.objects.all()
        serializer =  AdvertisementSerializer(adverts, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class AssignTenantView(APIView):
     def post(self, request, house_id):
        # Get the house object
        house = Houses.objects.filter(id=house_id).first()
        
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

        # Assign the tenant to the room after successful payment
        tenant = request.user  # Assuming the user sending the request is the tenant
        empty_room.assign_tenant(tenant)

        # Mark the rent status as true (meaning the rent has been paid)
        empty_room.rent_status = True
        empty_room.save()

        # Optionally, serialize and return room information (or tenant info, depending on your needs)
        room_data = RoomSerializer(empty_room).data  # Serialize room data to return
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
        user_id = request.data.get('user_id')
        house_id = request.data.get('house_id')

        try:
            caretaker = CareTaker.objects.get(user_id=user_id, house_id=house_id)
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