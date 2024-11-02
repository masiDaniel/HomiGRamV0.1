from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from .models import Houses
from accounts.models import CustomUser

@receiver(post_save, sender=Houses)
def update_landlord_info(sender, instance, **kwargs):
    if instance.landlord_id:
        landlord = instance.landlord_id  # landlord_id is already a CustomUser instance
        if landlord.user_type != 'landlord':
            landlord.user_type = 'landlord'
            landlord.is_landlord = True
        # Update num_houses to reflect the count of houses associated with this landlord
        landlord.num_houses = Houses.objects.filter(landlord_id=landlord).count()
        landlord.save()

@receiver(post_delete, sender=Houses)
def decrement_landlord_num_houses(sender, instance, **kwargs):
    if instance.landlord_id:
        landlord = instance.landlord_id  # landlord_id is already a CustomUser instance
        landlord.num_houses = Houses.objects.filter(landlord_id=landlord).count()
        # If no more houses, reset user_type and is_landlord
        if landlord.num_houses == 0:
            landlord.user_type = 'tenant'
            landlord.is_landlord = False
        landlord.save()