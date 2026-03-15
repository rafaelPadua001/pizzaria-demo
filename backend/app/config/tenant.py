import os

raw_value = os.getenv("RESTAURANT_ID")
try:
    parsed_value = int(raw_value) if raw_value not in (None, "") else None
except ValueError:
    parsed_value = None

# Keep None when the env var is missing/invalid/zero to avoid accidental filtering.
RESTAURANT_ID = parsed_value if parsed_value and parsed_value > 0 else None
