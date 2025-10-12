from django.db import models
from django.contrib.auth.models import AbstractUser
import random
import string


def generate_unique_regno():
    """
    Generates a unique 5-character registration number (A-Z, 0-9).
    Automatically retries if a collision occurs.
    """
    from .models import CustomUser  # local import to avoid circular reference

    while True:
        regno = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5))
        if not CustomUser.objects.filter(regno=regno).exists():
            return regno

# Create your models here.
class CustomUser(AbstractUser):
    email = models.EmailField(unique=True)
    nick_name = models.CharField(unique=True, null=True)
    id_number = models.IntegerField(default=0)
    phone_number = models.CharField(max_length=15, default='')
    profile_pic = models.ImageField(null=True)
    passport_pic = models.ImageField(null=True)
    id_scan = models.ImageField(null=True)
    USER_TYPES = (('tenant', 'Tenant'), ('landlord', 'Landlord'), ('caretaker', 'Caretaker'))
    user_type = models.CharField(max_length=10, choices=USER_TYPES, default='tenant')
    is_landlord = models.BooleanField(default=False) 
    num_houses = models.IntegerField(default=0)  
    regno = models.CharField(max_length=5, unique=True, editable=False)

    def save(self, *args, **kwargs):
        if not self.regno:
            self.regno = generate_unique_regno()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.username} ({self.regno})"
