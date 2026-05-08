from django.urls import path

from chat.api import api

urlpatterns = [
    path("api/", api.urls),
]
