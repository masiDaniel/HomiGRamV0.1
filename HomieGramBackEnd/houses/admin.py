from django.contrib import admin
from .models import Amenity, Bookmark, HouseRating, Houses, CareTaker, Location, Room, RoomImage, Teenants, Advertisement, PendingAdvertisement,HouseImage, TenancyAgreement

# Register your models here.
models_to_register = [ Houses, CareTaker, Teenants,HouseRating, Amenity, Location, Room, RoomImage, Bookmark, Advertisement, PendingAdvertisement, HouseImage, TenancyAgreement]
admin.site.register(models_to_register)