import os
import time as time_module
from datetime import datetime, time as dt_time


def get_current_time() -> dt_time:
    fake_time = os.getenv("FAKE_TIME")
    if fake_time:
        try:
            hours, minutes = map(int, fake_time.split(":"))
            current = dt_time(hours, minutes)
            print("DEBUG CURRENT TIME:", current)
            return current
        except Exception:
            current = datetime.fromtimestamp(time_module.time()).time()
            print("DEBUG CURRENT TIME:", current)
            return current
    current = datetime.fromtimestamp(time_module.time()).time()
    print("DEBUG CURRENT TIME:", current)
    return current
