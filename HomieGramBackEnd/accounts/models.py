from django.db import models
from HomieGramBackEnd.houses.models import LandLords
from accounts.models import CustomUser
from django.contrib.auth.models import AbstractUser, AbstractBaseUser


# Create your models here.
class CustomUser(AbstractUser):
    email = models.EmailField(unique=True)
    id_number = models.IntegerField(default=0)
    phone_number = models.IntegerField(default=0)
    profile_pic = models.ImageField(null=True)
    passport_pic = models.ImageField(null=True)
    id_scan = models.ImageField(null=True) 
    # user_type = models.ForeignKey(LandLords,null=True, on_delete=models.CASCADE)
