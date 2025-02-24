from django.db import models
from django.contrib.auth.models import AbstractUser, AbstractBaseUser
from django.forms import ValidationError


# Create your models here.
class CustomUser(AbstractUser):
    email = models.EmailField(unique=True)
    id_number = models.IntegerField(default=0)
    phone_number = models.CharField(max_length=15, default='')
    profile_pic = models.ImageField(null=True)
    passport_pic = models.ImageField(null=True)
    id_scan = models.ImageField(null=True)
    USER_TYPES = (('tenant', 'Tenant'), ('landlord', 'Landlord'))
    user_type = models.CharField(max_length=10, choices=USER_TYPES, default='tenant')
    is_landlord = models.BooleanField(default=False)  # To indicate if user is a landlord
    num_houses = models.IntegerField(default=0)  # Track the number of houses they own
    regno = models.CharField(max_length=20, unique=True, blank=True, null=True)

    def clean(self):
        if self.regno and not self.regno.startswith("USER-"):
            raise ValidationError("Registration number must start with 'USER-'")

    def __str__(self):
        return f"{self.username} ({self.regno})"
