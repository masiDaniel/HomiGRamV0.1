from django.utils import timezone
from django.conf import settings
from django.db import models
from dynaconf import ValidationError
# from django.utils import timezone
from accounts.models import CustomUser
from django.core.validators import MinValueValidator, MaxValueValidator
from django.contrib.auth.models import User
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType




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

def validate_file_extension(value):
    valid_extensions = ['pdf', 'docx', 'doc']
    extension = value.name.split('.')[-1].lower()
    if extension not in valid_extensions:
        raise ValidationError(('Unsupported file extension. Only PDF, DOC, DOCX files are allowed.'))


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
    
    location_detail = models.ForeignKey(Location, on_delete=models.SET_NULL, null=True)
    amenities = models.ManyToManyField(Amenity, related_name='houses')
    image = models.ImageField(upload_to='house_images/', null=True, blank=True)
    image_1 = models.ImageField(upload_to='house_images/', null=True, blank=True)
    image_2 = models.ImageField(upload_to='house_images/', null=True, blank=True)
    image_3 = models.ImageField(upload_to='house_images/', null=True, blank=True)
    video = models.FileField(upload_to='house_videos/', null=True, blank=True)
    payment_bank_name = models.CharField(max_length=100, blank=True)
    payment_account_number = models.CharField(max_length=50, blank=True)
    caretaker = models.OneToOneField(
        "CareTaker", null=True, blank=True, on_delete=models.SET_NULL,
        related_name='assigned_house'
    )
    contract_file = models.FileField(upload_to='house_contacts/', validators=[validate_file_extension], null=True, blank=True)
    
    
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
    house_id = models.ForeignKey(Houses, null=True, on_delete=models.CASCADE, related_name='caretakers')

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)

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
    room_name =  models.CharField(max_length=100, null=False, blank=False, default="Homi room")
    number_of_bedrooms = models.IntegerField()
    size_in_sq_meters = models.DecimalField(max_digits=6, decimal_places=2)
    rent = models.DecimalField(max_digits=10, decimal_places=2)
    occupied = models.BooleanField(default=False)
    tenant =  models.ForeignKey(CustomUser, related_name='tenant_occupying', on_delete=models.SET_NULL, null=True, blank=True)
    # entry_date = models.DateField(default=timezone.now())
    room_images = models.ImageField(upload_to='room_images/', default="Homi rooms")
    rent_status = models.BooleanField(default=False)
    last_payment_date = models.DateField(null=True, blank=True)
    
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


class Payment(models.Model):
    tenant = models.ForeignKey(CustomUser, related_name="payments", on_delete=models.CASCADE)
    room = models.ForeignKey(Room, related_name="payments", on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    payment_date = models.DateTimeField(default=timezone.now)
    payment_status = models.BooleanField(default=True)  # True if payment was successful

    def save(self, *args, **kwargs):
        """Automatically update rent status when payment is saved."""
        super().save(*args, **kwargs)  # Save payment record
        self.room.rent_status = True
        self.room.last_payment_date = self.payment_date
        self.room.save()



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
    

class PendingAdvertisement(models.Model):
    """Stores ad details before payment confirmation."""
    title = models.CharField(max_length=100)
    description = models.TextField()
    image = models.ImageField(upload_to='advertisements/images', null=True, blank=True)
    video_file = models.FileField(upload_to='advertisements/videos/', null=True, blank=True)
    start_date = models.DateField()
    end_date = models.DateField()
    payment_status = models.BooleanField(default=False)  # Payment not received yet
    payment_reference = models.CharField(max_length=100, null=True, blank=True)

    def __str__(self):
        return f"{self.title} - {'Paid' if self.payment_status else 'Pending'}"


class Advertisement(models.Model):
    title = models.CharField(max_length=100)
    description = models.TextField()
    image = models.ImageField(upload_to='advertisements/images', null=True, blank=True)
    video_file = models.FileField(upload_to='advertisements/videos/', null=True, blank=True)
    start_date = models.DateField()
    end_date = models.DateField()
    STATUS_CHOICES = [
    ('pending', 'Pending'),
    ('active', 'Active'),
    ('expired', 'Expired'),
    ]
    
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')


    def __str__(self):
        return self.title
    
    def clean(self):
        if self.start_date > self.end_date:
            raise ValidationError({"end_date": "End date cannot be before the start date."})

    def update_status(self):
        today = timezone.now().date()
        if today < self.start_date:
            self.status = 'pending'
        elif self.start_date <= today <= self.end_date:
            self.status = 'active'
        else:
            self.status = 'expired'
        

    
    def save(self, *args, **kwargs):
        """Automatically update is_active based on start and end dates before saving."""
        self.update_status()
        super().save(*args, **kwargs)