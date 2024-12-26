import uuid
from datetime import datetime
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import CustomUser

@receiver(post_save, sender=CustomUser)
def create_registration_number(sender, instance, created, **kwargs):
    if created and not instance.regno:
        # Format: USER-YYYYMMDD-UUID
        date_part = datetime.now().strftime('%Y%m%d')
        unique_part = uuid.uuid4().hex[:6].upper()
        instance.regno = f"USER-{date_part}-{unique_part}"
        instance.save()
