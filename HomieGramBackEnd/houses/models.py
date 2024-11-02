from datetime import timezone
from django.conf import settings
from django.db import models
from accounts.models import CustomUser
from django.core.validators import MinValueValidator, MaxValueValidator
from django.contrib.auth.models import User
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType


# Create your models here.
# class LandLords(models.Model):
#     """
#     Stores Information about landLords of Houses
#     """
#     user_id = models.ForeignKey(CustomUser, null=True, on_delete=models.CASCADE)
#     num_houses = models.IntegerField(default=0)

#     def __str__(self) -> str:
#         return self.user_id.get_full_name()


class Amenity(models.Model):
    """
    Stores information about house amenities.
    """
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class Location(models.Model):
    """
    Stores information about house locations.
    """
    county = models.CharField(max_length=50)
    town = models.CharField(max_length=50)
    area = models.CharField(max_length=50)

    def __str__(self):
        return f'{self.county}, {self.town}, {self.area}'

class Houses(models.Model):
    """
    Will Hold Information about the House
    """
    name = models.CharField(max_length=100, null=False, blank=False, default="")
    rent_amount = models.DecimalField(null=False, blank=False,
                                      decimal_places=2, max_digits=10)
    landlord_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE,
                                     null=True, blank=False)
    rating = models.PositiveSmallIntegerField(default=0, null=False, blank=False, )
    description = models.TextField()
    location = models.CharField(default="", max_length=50)
    location_detail = models.ForeignKey(Location, on_delete=models.SET_NULL, null=True)
    amenities = models.ManyToManyField(Amenity, related_name='houses')
    image = models.ImageField(upload_to='house_images/', null=True, blank=True)
    image_1 = models.ImageField(upload_to='house_images/', null=True, blank=True)
    image_2 = models.ImageField(upload_to='house_images/', null=True, blank=True)
    image_3 = models.ImageField(upload_to='house_images/', null=True, blank=True)
    video = models.FileField(upload_to='house_videos/', null=True, blank=True)
    payment_bank_name = models.CharField(max_length=100, blank=True)
    payment_account_number = models.CharField(max_length=50, blank=True)
    # TODO implement ratings from teenants and non teenants
    #validators=[MinValueValidator(0), MaxValueValidator(5)
    
    def calculate_average_rating(self):
        ratings = self.ratings.all()
        if ratings.exists():
            return ratings.aggregate(average=models.Avg('rating'))['average']
        return 0

    def update_average_rating(self):
        self.rating = self.calculate_average_rating()
        self.save()

    def __str__(self):
        return f'{self.name} - Rating: {self.rating}'

class HouseRating(models.Model):
    house = models.ForeignKey(Houses, related_name='ratings', on_delete=models.CASCADE)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    rating = models.PositiveSmallIntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    comment = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('house', 'user')  # Ensures that a user can only rate a house once

    def __str__(self):
        return f'{self.house.name} - {self.rating} by {self.user.username}'


class CareTaker(models.Model):
    """
    Stores Information about Caretakers
    """
    user_id = models.ForeignKey(CustomUser, null=True, on_delete=models.CASCADE)
    house_id = models.ForeignKey(Houses, null=True, on_delete=models.CASCADE)

    def __str__(self) -> str:
        return self.user_id.get_full_name()



class Teenants(models.Model):
    """
    Stores Information about Teenants
    """
    user_id = models.ForeignKey(CustomUser, null=True, on_delete=models.CASCADE)
    house_id = models.ForeignKey(Houses, null=True, on_delete=models.CASCADE)

    def __str__(self) -> str:
        return self.user_id.get_full_name()
    
class Room(models.Model):
    apartment = models.ForeignKey(Houses, related_name='rooms', on_delete=models.CASCADE)
    # room_name ="{self.apartment.name} {self.id}"
    number_of_bedrooms = models.IntegerField()
    size_in_sq_meters = models.DecimalField(max_digits=6, decimal_places=2)
    rent = models.DecimalField(max_digits=10, decimal_places=2)
    occupied = models.BooleanField(default=False)
    tenant =  models.ForeignKey(CustomUser, related_name='tenant_occupying', on_delete=models.SET_NULL, null=True, blank=True)
    # entry_date = models.DateField(default=timezone.now())
    room_images = models.ImageField(upload_to='room_images/', default="Homi rooms")
    rent_status = models.BooleanField(default=False)
    
    def assign_tenant(self, tenant):
        self.tenant = tenant
        self.occupied = True
        self.save()

    def remove_tenant(self, tenant):
        self.tenant = None
        self.occupied = False
        self.save()
    def __str__(self):
        # name = apartment + self.id
        return f"{self.apartment.name} {self.id}"
    
class RoomImage(models.Model):
    room =  models.ForeignKey(Room, related_name='images', on_delete=models.CASCADE)
    image = models.ImageField(upload_to='room_images/')

    def __str__(self):
        return  f"image {self.room}"


class Bookmark(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    house = models.ForeignKey(Houses, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'house')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user} bookmarked {self.house}"
    

class Advertisement(models.Model):
    title = models.CharField(max_length=100)
    description = models.TextField()
    image = models.ImageField(upload_to='advertisements/images', null=True, blank=True)
    video_file = models.FileField(upload_to='advertisements/videos/', null=True, blank=True)
    start_date = models.DateField()
    end_date = models.DateField()
    is_active = models.BooleanField(default=True)
    # business = models.ForeignKey(MyBusiness, related_name='business', on_delete=models.CASCADE)

    def __str__(self):
        return self.title

    def is_currently_active(self):
        return self.is_active and self.start_date <= timezone.now().date() <= self.end_date