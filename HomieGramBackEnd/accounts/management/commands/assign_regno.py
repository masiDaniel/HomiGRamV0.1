import uuid
from datetime import datetime
from django.core.management.base import BaseCommand
from accounts.models import CustomUser

class Command(BaseCommand):
    help = "Assign registration numbers to existing users without a regno"

    def handle(self, *args, **kwargs):
       
        users_without_regno = CustomUser.objects.filter(regno__isnull=True)
       
        for user in users_without_regno:
         
            date_part = datetime.now().strftime('%Y%m%d') 
            unique_part = uuid.uuid4().hex[:6].upper() 
            user.regno = f"USER-{date_part}-{unique_part}" 
            
          
            user.save()
            
            self.stdout.write(self.style.SUCCESS(f"Assigned regno {user.regno} to {user.username}"))