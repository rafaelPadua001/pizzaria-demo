import os

# Default to 0 so multi-tenant flows never depend on a global env restaurant id.
RESTAURANT_ID = int(os.getenv("RESTAURANT_ID", "0") or 0)
