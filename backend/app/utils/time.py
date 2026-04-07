import os
import logging
import time as time_module
from datetime import datetime, time as dt_time

logger = logging.getLogger("utils.time")


def get_current_time() -> dt_time:
    fake_time = os.getenv("FAKE_TIME")
    if fake_time:
        try:
            hours, minutes = map(int, fake_time.split(":"))
            current = dt_time(hours, minutes)
            logger.debug("Usando FAKE_TIME configurado: %s", current)
            return current
        except Exception:
            current = datetime.fromtimestamp(time_module.time()).time()
            logger.warning("FAKE_TIME invalido. Usando horario atual.", exc_info=True)
            return current
    return datetime.fromtimestamp(time_module.time()).time()
