#!/usr/bin/env python3
import base64
from datetime import datetime, timezone

def generate_timestamp(use_utc: bool = True) -> str:
    """
    Generate timestamp in the format YYYYMMDDHHMMSS.
    Defaults to UTC time (useful for most payment APIs).
    """
    now = datetime.now(timezone.utc) if use_utc else datetime.now()
    return now.strftime("%Y%m%d%H%M%S")

def generate_password(shortcode: str, passkey: str, timestamp: str | None = None) -> str:
    """
    Generate base64 password = base64(Shortcode + Passkey + Timestamp).
    - shortcode: the business/short code (string)
    - passkey: API passkey (string)
    - timestamp: timestamp string in YYYYMMDDHHMMSS format. If None, it will be created (UTC).
    Returns: base64-encoded string (str)
    """
    if timestamp is None:
        timestamp = generate_timestamp()

    raw = f"{shortcode}{passkey}{timestamp}"
    raw_bytes = raw.encode("utf-8")
    b64 = base64.b64encode(raw_bytes).decode("utf-8")
    return b64

# Example usage
if __name__ == "__main__":
    SHORTCODE = "3560279"            # replace with your shortcode
    PASSKEY = "bae1e8b4f6e1c73bed1d65c920fa166d7105b694459fd1e4c6102edbd1e41679"    # replace with your passkey
    ts = generate_timestamp()       # or set explicit: "20250919083045"

    password = generate_password(SHORTCODE, PASSKEY, ts)
    print("Timestamp:", ts)
    print("Password (base64):", password)

