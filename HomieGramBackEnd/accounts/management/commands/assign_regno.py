import uuid
from datetime import datetime
from django.core.management.base import BaseCommand
from accounts.models import CustomUser

class Command(BaseCommand):
    help = "Assign registration numbers to existing users without a regno"

    def handle(self, *args, **kwargs):
        # Query all users who don't have a regno
        users_without_regno = CustomUser.objects.filter(regno__isnull=True)
        
        # Loop through each user
        for user in users_without_regno:
            # Generate a regno in the format USER-YYYYMMDD-XXXX
            date_part = datetime.now().strftime('%Y%m%d')  # Current date as YYYYMMDD
            unique_part = uuid.uuid4().hex[:6].upper()  # First 6 characters of a UUID
            user.regno = f"USER-{date_part}-{unique_part}"  # Combine to form regno
            
            # Save the updated user
            user.save()
            
            # Print the assigned regno for verification
            self.stdout.write(self.style.SUCCESS(f"Assigned regno {user.regno} to {user.username}"))