from django.core.management.base import BaseCommand
from django.utils import timezone
from houses.models import Payment, Room

class Command(BaseCommand):
    help = "Checks expired payments and updates room rent status"

    def handle(self, *args, **options):
        today = timezone.now().date()
        
        # Step 1: Get all expired payments
        expired_payments = Payment.objects.filter(valid_until__lt=today)

        updated_rooms = 0

        for payment in expired_payments:
            room = payment.room

            has_valid_payment = Payment.objects.filter(
                room=room,
                valid_until__gte=today,
                is_active=True
            ).exists()
          
            if not has_valid_payment and room.rent_status:
                room.rent_status = False
                room.save()
                updated_rooms += 1

        self.stdout.write(
            self.style.SUCCESS(f"✅ Updated {updated_rooms} room(s) whose payments expired.")
        )
