from django.contrib import admin
from .models import Amenity, Bookmark, HouseRating, LandLords, Houses, CareTaker, Location, Room, RoomImage, Teenants 

# Register your models here.
models_to_register = [LandLords, Houses, CareTaker, Teenants,HouseRating, Amenity, Location, Room, RoomImage, Bookmark]
admin.site.register(models_to_register)