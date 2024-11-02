from django.db import models
from django.contrib.auth.models import AbstractUser, AbstractBaseUser


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
