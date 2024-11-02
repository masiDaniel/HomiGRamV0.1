from rest_framework import serializers
from .models import Advertisement, Amenity, Bookmark, CareTaker, HouseRating,  Houses,  Location, Room,  Teenants


class CareTakersSerializer(serializers.ModelSerializer):
    class Meta:
        model = CareTaker
        fields = ['user_id', 'house_id']

# class LandLordsSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = LandLords
#         fields = ['user_id', 'num_houses']

class TeenantsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Teenants
        fields = ['user_id', 'house_id']

class HousesSerializers(serializers.ModelSerializer):
    class Meta:
        model = Houses
        fields = "__all__"

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


class AdvertisementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Advertisement
        fields = ['id', 'title', 'description', 'image', 'video_file', 'start_date', 'end_date', 'is_active']