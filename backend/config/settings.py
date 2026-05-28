import os
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

SECRET_KEY = os.getenv("DJANGO_SECRET_KEY", "dev-only-change-me")
DEBUG = os.getenv("DJANGO_DEBUG", "True").lower() == "true"
ALLOWED_HOSTS = os.getenv("DJANGO_ALLOWED_HOSTS", "*").split(",")

INSTALLED_APPS = [
    "django.contrib.contenttypes",
    "django.contrib.auth",
    "django.contrib.staticfiles",
    "corsheaders",
    "chat",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.common.CommonMiddleware",
]

ROOT_URLCONF = "config.urls"
WSGI_APPLICATION = "config.wsgi.application"


def _parse_db_url(url):
    from urllib.parse import urlparse

    p = urlparse(url)
    return {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": p.path.lstrip("/"),
        "USER": p.username,
        "PASSWORD": p.password,
        "HOST": p.hostname,
        "PORT": str(p.port or 5432),
    }


_database_url = os.getenv("DATABASE_URL")
_transaction_pooler = os.getenv("TRANSACTION_POOLER")
_direct_url = os.getenv("DIRECT_URL")
_db_url = _database_url or _transaction_pooler or _direct_url

DATABASES = {
    "default": _parse_db_url(_db_url) if _db_url else {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
    }
}

STATIC_URL = "static/"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

CORS_ALLOW_ALL_ORIGINS = True

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

_schema_context_path = Path(os.getenv("AI_SCHEMA_CONTEXT_PATH", "schema_context.md"))
if not _schema_context_path.is_absolute():
    _schema_context_path = BASE_DIR / _schema_context_path
AI_SCHEMA_CONTEXT_PATH = _schema_context_path
