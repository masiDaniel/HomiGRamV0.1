from .base import *
import os, environ
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
environ.Env.read_env(os.path.join(BASE_DIR, ".env.development"))

MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "house_images"


