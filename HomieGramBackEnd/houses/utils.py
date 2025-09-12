from django.utils.text import slugify

def get_safe_group_name(name: str, unique_id: int = None) -> str:
    """
    Converts a string (e.g., house name) into a safe group name
    suitable for Django Channels or similar usage.

    If unique_id is provided, it appends it to ensure uniqueness.
    """
    safe_name = slugify(name)  # converts "My House Name" -> "my-house-name"

    if unique_id is not None:
        safe_name = f"{safe_name}-{unique_id}"

    return safe_name

def check_payment_status(room):
    # Simulate payment check. Replace with real payment gateway integration.
    return True  # For the sake of the example, assume payment is always confirmed

