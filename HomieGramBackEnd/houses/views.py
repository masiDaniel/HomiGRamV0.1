from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.response import Response
from rest_framework.generics import RetrieveAPIView
from .serializers import AmenitiesSerializer, BookmarkSerializer, HousesSerializers, LocationSerializer
from accounts.serializers import MessageSerializer
from .models import Amenity, Bookmark, HouseRating, Houses, Location

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
        return Response({'message': 'Bookmark already exists'}, status=status.HTTP_200_OK)

class RemoveBookmarkView(APIView):
    def post(self, request, house_id, *args, **kwargs):
        try:
            bookmark = Bookmark.objects.get(user=request.user, house_id=house_id)
        except Bookmark.DoesNotExist:
            return Response({'error': 'Bookmark not found'}, status=status.HTTP_404_NOT_FOUND)

        bookmark.delete()
        return Response({'message': 'Bookmark removed'}, status=status.HTTP_204_NO_CONTENT)