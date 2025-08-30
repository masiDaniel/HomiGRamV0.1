from rest_framework import serializers
from .models import Advertisement, Amenity, Bookmark, CareTaker, HouseImage, HouseRating,  Houses,  Location, Room,  Teenants, PendingAdvertisement, TenancyAgreement
from collections import defaultdict


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

class HouseImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = HouseImage
        fields = ['image']
        
class HousesSerializers(serializers.ModelSerializer):
    latitude = serializers.FloatField(required=False)
    longitude = serializers.FloatField(required=False)
    rooms = serializers.SerializerMethodField()
    images = HouseImageSerializer(many=True, read_only=True) 

    class Meta:
        model = Houses
        fields = "__all__"

    def get_rooms(self, obj):
        grouped = defaultdict(list)
        for room in obj.rooms.all():
            grouped[str(room.number_of_bedrooms)].append(RoomSerializer(room).data)
        return dict(grouped)

class RoomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Room
        fields = "__all__"

class TenancyAgreementSerializer(serializers.ModelSerializer):
    class Meta:
        model = TenancyAgreement
        fields = "__all__"
        
class RoomAndTenancySerializer(serializers.ModelSerializer):
    agreement = serializers.SerializerMethodField()
    class Meta:
        model = Room
        fields = "__all__"

    def get_agreement(self, obj):
        agreement = TenancyAgreement.objects.filter(room=obj, tenant=obj.tenant).first()
        if agreement:
            return TenancyAgreementSerializer(agreement).data
        return None


class HouseWithRoomsSerializer(serializers.ModelSerializer):
    rooms = serializers.SerializerMethodField()

    class Meta:
        model = Houses
        fields = "__all__"

    def get_rooms(self, obj):
        grouped = defaultdict(list)
        for room in obj.rooms.all():
            grouped[str(room.number_of_bedrooms)].append(RoomSerializer(room).data)
        return dict(grouped)
    def create(self, validated_data):
        images_data = validated_data.pop('images', [])
        house = Houses.objects.create(**validated_data)
        for image_data in images_data:
            HouseImage.objects.create(house=house, **image_data)
        return house

    def update(self, instance, validated_data):
        images_data = validated_data.pop('images', None)
        instance = super().update(instance, validated_data)
        if images_data is not None:
            # # Optionally, remove old images first
            # instance.images.all().delete()
            for image_data in images_data:
                HouseImage.objects.create(house=instance, **image_data)
        return instance

class HouseRatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = HouseRating
        fields = ['house', 'user', 'rating', 'comment', 'created_at']

class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
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
        fields = ['id', 'title', 'description', 'image', 'video_file', 'start_date', 'end_date', 'status']

class PendingAdvertisementSerializer(serializers.ModelSerializer):
    class Meta:
        model = PendingAdvertisement
        fields =  "__all__"
    
class CaretakerSerializer(serializers.ModelSerializer):
    class Meta:
        model = CareTaker
        fields = "__all__"