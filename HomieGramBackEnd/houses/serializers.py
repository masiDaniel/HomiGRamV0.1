from rest_framework import serializers
from .models import Amenity, Bookmark, CareTaker, HouseRating,  Houses, LandLords, Location, Room,  Teenants


class CareTakersSerializer(serializers.ModelSerializer):
    class Meta:
        model = CareTaker
        fields = ['user_id', 'house_id']

class LandLordsSerializer(serializers.ModelSerializer):
    class Meta:
        model = LandLords
        fields = ['user_id', 'num_houses']

class TeenantsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Teenants
        fields = ['user_id', 'house_id']

class HousesSerializers(serializers.ModelSerializer):
    class Meta:
        model = Houses
        fields = ["id","name", "rent_amount", "rating", "description", "location", "image", "image_1", "image_2", "image_3", "location_detail", "amenities"]

class HouseRatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = HouseRating
        fields = ['house', 'user', 'rating', 'comment', 'created_at']

class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = "__all__"


class RoomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Room
        fields = "__all__"

class AmenitiesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Amenity
        fields = "__all__"

class BookmarkSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bookmark
        fields = ['id', 'user', 'house', 'created_at']