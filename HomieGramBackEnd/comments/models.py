from django.db import models
from accounts.models import CustomUser
from houses.models import Houses

# Create your models here.
class HouseComments(models.Model):
    """
    This Table Will Hold Info on Comments on Houses
    """
    house_id = models.ForeignKey(Houses, on_delete=models.CASCADE, null=True, blank=False)
    user_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=False)
    comment = models.TextField()
    nested = models.BooleanField(default=False) # true if comment is nested
    # holds the id in which the comment is nested on
    nested_id = models.CharField(max_length=100,default="", blank=True)
