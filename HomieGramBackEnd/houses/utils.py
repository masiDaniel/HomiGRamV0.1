from django.utils.text import slugify

def get_safe_group_name(name: str, unique_id: int = None) -> str:
    """
    Converts a string (e.g., house name) into a safe group name
    suitable for Django Channels or similar usage.

    If unique_id is provided, it appends it to ensure uniqueness.
    """
    safe_name = slugify(name) 

    if unique_id is not None:
        safe_name = f"{safe_name}-{unique_id}-official"

    return safe_name

def check_payment_status(room):
    # Simulate payment check. Replace with real payment gateway integration.
    return True  # For the sake of the example, assume payment is always confirmed

def parse_coordinate(coord):
    """
    Converts a coordinate string like '0.6768° S' or '34.7817° E'
    into a decimal float (-0.6768, 34.7817).
    If already a number, just returns it.
    """
    if isinstance(coord, (float, int)):
        return float(coord)

    coord = str(coord).strip().replace("°", "")
    parts = coord.split()

    if not parts:
        raise ValueError("Invalid coordinate format")

    value = float(parts[0])
    if len(parts) > 1:
        direction = parts[1].upper()
        if direction in ["S", "W"]:
            value = -value
    return value

