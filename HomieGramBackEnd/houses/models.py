from django.utils import timezone
from django.conf import settings
from django.db import models
from dynaconf import ValidationError
from accounts.models import CustomUser
from datetime import timedelta
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils.timezone import now


def validate_file_extension(value):
    valid_extensions = ['pdf', 'docx', 'doc']
    extension = value.name.split('.')[-1].lower()
    if extension not in valid_extensions:
        raise ValidationError(('Unsupported file extension. Only PDF, DOC, DOCX files are allowed.'))
    
class Amenity(models.Model):
    """
    Stores information about house amenities.
    """
    name = models.CharField(max_length=100)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return self.name

class Location(models.Model):
    """
    Stores information about house locations.
    """
    county = models.CharField(max_length=50)
    town = models.CharField(max_length=50)
    area = models.CharField(max_length=50)

    class Meta:
        ordering = ['county', 'town', 'area'] 

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
    location_detail = models.ForeignKey(Location, on_delete=models.SET_NULL, null=True)
    latitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    amenities = models.ManyToManyField(Amenity, related_name='houses')
    video = models.FileField(upload_to='house_videos/', null=True, blank=True)
    payment_bank_name = models.CharField(max_length=100, blank=True)
    payment_account_number = models.CharField(max_length=50, blank=True)
    caretaker = models.OneToOneField(
        "CareTaker", null=True, blank=True, on_delete=models.SET_NULL,
        related_name='assigned_house'
    )
    water_deposit = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    contract_file = models.FileField(upload_to='house_contacts/', validators=[validate_file_extension], null=True, blank=True)
    
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

class HouseImage(models.Model):
    house = models.ForeignKey(Houses, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='house_images/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Image for {self.house.name}"
    
class HouseRating(models.Model):
    house = models.ForeignKey(Houses, related_name='ratings', on_delete=models.CASCADE)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    rating = models.PositiveSmallIntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    comment = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    month = models.DateField(default=now) 

    class Meta:
        unique_together = ('house', 'user', 'month') 

    def save(self, *args, **kwargs):
        self.month = self.month.replace(day=1)
        super().save(*args, **kwargs)    
        ratings = HouseRating.objects.filter(house=self.house)
        avg = ratings.aggregate(models.Avg('rating'))['rating__avg']
        self.house.rating = avg or 0
        self.house.save()

    def __str__(self):
        return f'{self.house.name} - {self.rating} by {self.user.username} ({self.month.strftime("%B %Y")})'

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
   
    rent_status = models.BooleanField(default=False)
    last_payment_date = models.DateTimeField(null=True, blank=True)
    
    def assign_tenant(self, tenant):
        self.tenant = tenant
        self.occupied = True
        self.save()

    def remove_tenant(self, tenant):
        self.tenant = None
        self.occupied = False
        self.save()
    def __str__(self):
        return f"{self.apartment.name} {self.room_name}"

class RoomImage(models.Model):
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='room_images/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Image for {self.room.room_name}"

class TenancyAgreement(models.Model):
    AGREEMENT_STATUS = [
        ("pending", "Pending"),
        ("approved", "Approved"),
        ("active", "Active"),
        ("terminated", "Terminated"),
    ]

    tenant = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    house = models.ForeignKey(Houses, on_delete=models.CASCADE)
    room = models.ForeignKey(Room, on_delete=models.CASCADE)
    start_date = models.DateTimeField(auto_now_add=True)
    end_date = models.DateTimeField(null=True, blank=True)
    status = models.CharField(max_length=50, choices=AGREEMENT_STATUS, default='pending')
    signed_at = models.DateTimeField(null=True, blank=True)
    termination_requested = models.BooleanField(default=False)
    previous_agreement = models.ForeignKey("self", null=True, blank=True, on_delete=models.SET_NULL)

    def __str__(self):
        return f"Agreement - {self.tenant.username} -> {self.room.room_name} ({self.status}) id {self.id}"

class Payment(models.Model):
    # Who made the payment
    tenant = models.ForeignKey(CustomUser, related_name="payments", on_delete=models.CASCADE)
    room = models.ForeignKey(Room, related_name="payments", on_delete=models.CASCADE)
    house = models.ForeignKey(Houses, on_delete=models.CASCADE, related_name="payments")
    agreement = models.ForeignKey("TenancyAgreement", on_delete=models.CASCADE, related_name="payments")

    # Core details
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(
        max_length=20,
        choices=(("pending", "Pending"), ("confirmed", "Confirmed"), ("failed", "Failed")),
        default="pending",
    )

    # Tracking identifiers
    checkout_request_id = models.CharField(max_length=100, blank=True, null=True, unique=True)
    mpesa_receipt = models.CharField(max_length=50, blank=True, null=True, unique=True)
    failure_reason = models.TextField(blank=True, null=True)

    # Dates
    created_at = models.DateTimeField(auto_now_add=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    valid_until = models.DateTimeField(null=True, blank=True)

    def mark_confirmed(self, amount=None, receipt_number=None):
        """Mark payment as confirmed and update validity."""
        self.status = "confirmed"
        if amount:
            self.amount = amount
        if receipt_number:
            self.mpesa_receipt = receipt_number
        self.paid_at = timezone.now()
        # Example: valid for one month
        self.valid_until = timezone.now() + timedelta(days=30)
        self.save()

    def mark_failed(self, reason=None):
        """Mark payment as failed and store reason."""
        self.status = "failed"
        if reason:
            self.failure_reason = reason
        self.save()

    def __str__(self):
        return f"Payment {self.id} - {self.tenant.username} - {self.status}"

class PaymentItem(models.Model):
    payment = models.ForeignKey(Payment, on_delete=models.CASCADE, related_name="items")
    name = models.CharField(max_length=100)  # e.g. "Rent", "Water", "Electricity", "Security Deposit"
    amount = models.DecimalField(max_digits=10, decimal_places=2)

class Charge(models.Model):
    agreement = models.ForeignKey(TenancyAgreement, on_delete=models.CASCADE, related_name="charges")
    name = models.CharField(max_length=100)  # "Water", "Electricity", "Garbage", etc.
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    month = models.DateField()  # which month it applies
    is_paid = models.BooleanField(default=False)

class Receipt(models.Model):
    payment = models.OneToOneField(Payment, on_delete=models.CASCADE, related_name="receipt")
    tenant = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    receipt_number = models.CharField(max_length=20, unique=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date_issued = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Receipt {self.receipt_number} for {self.payment}"

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
    image = models.ImageField(upload_to='advertisment_images/', null=True, blank=True)
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
