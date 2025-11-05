from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.conf import settings


def send_manual_verification_email(user):
    """
    Sends an email requesting the user to provide verification documents.
    """
    subject = "Complete Your Homigram Verification"
    from_email = settings.DEFAULT_FROM_EMAIL
    to = [user.email]

    context = {
        "user": user,
        "support_email": settings.DEFAULT_FROM_EMAIL, 
    }

    html_content = render_to_string("emails/manual_verification.html", context)
    text_content = render_to_string("emails/manual_verification.txt", context)

    email = EmailMultiAlternatives(subject, text_content, from_email, to)
    email.attach_alternative(html_content, "text/html")
    email.send(fail_silently=False)
