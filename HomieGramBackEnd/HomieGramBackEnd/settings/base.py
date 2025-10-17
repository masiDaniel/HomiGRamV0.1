from pathlib import Path
import os
import environ
from datetime import timedelta

BASE_DIR = Path(__file__).resolve().parent.parent

env = environ.Env(
    DEBUG=(bool, False)
)
# ✅ Read the correct .env file depending on DJANGO_ENV
DJANGO_ENV = os.getenv("DJANGO_ENV", "development")
env_file = Path(__file__).resolve().parent.parent.parent / f".env.{DJANGO_ENV}"

if env_file.exists():
    environ.Env.read_env(env_file)
else:
    print(f"⚠️ No .env file found for {DJANGO_ENV}")


SECRET_KEY = env("SECRET_KEY")
DEBUG = env("DEBUG")
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=[])

INSTALLED_APPS = [
    "daphne",
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # Installed Apps
    "rest_framework",
    "knox",
    # Custom apps
    "accounts.apps.AccountsConfig",
    "houses.apps.HousesConfig",
    "comments.apps.CommentsConfig",
    "business.apps.BusinessConfig",
    "chat.apps.ChatConfig",
    "rest_framework_simplejwt.token_blacklist"
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    'whitenoise.middleware.WhiteNoiseMiddleware',
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "HomieGramBackEnd.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "HomieGramBackEnd.wsgi.application"
ASGI_APPLICATION = "HomieGramBackEnd.asgi.application"

DATABASES = {
    "default": env.db("DATABASE_URL")
}

AUTH_USER_MODEL = "accounts.CustomUser"

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LANGUAGE_CODE = "en-us"
TIME_ZONE = 'Africa/Nairobi'
USE_I18N = True
USE_TZ = False


STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "static"

MEDIA_ROOT = '/var/www/homigram/media'
MEDIA_URL = '/media/'

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    )
}


SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=2),   
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),   
    'ROTATE_REFRESH_TOKENS': True,                   
    'BLACKLIST_AFTER_ROTATION': True,                
    'AUTH_HEADER_TYPES': ('Bearer',),                 
}

# Channels
REDIS_URL = env("REDIS_URL", default="redis://127.0.0.1:6379/0")
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {"hosts": [REDIS_URL]},
    }
}

import os
from pathlib import Path

# Detect environment for flexibility
DJANGO_ENV = os.getenv("DJANGO_ENV", "development")

# Use environment variable for logging dir, or fallback to a safe local directory
if DJANGO_ENV == "production":
    LOGGING_DIR = '/home/dan/HomiGRamV0.1/HomieGramBackEnd/logs'
else:
    LOGGING_DIR = Path(BASE_DIR) / "logs"

os.makedirs(LOGGING_DIR, exist_ok=True)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '[{asctime}] {levelname} {name} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'class': 'logging.FileHandler',
            'filename': os.path.join(LOGGING_DIR, 'django_errors.log'),
            'formatter': 'verbose',
        },
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file', 'console'],
            'level': 'ERROR' if DJANGO_ENV == 'production' else 'DEBUG',
            'propagate': True,
        },
        '': { 
            'handlers': ['file', 'console'],
            'level': 'INFO',
        },
    },
}
