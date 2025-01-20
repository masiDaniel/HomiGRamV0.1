from django.urls import path
from .consumers import ChatConsumer

websocket_urlpatterns = [
     # Group chat endpoint
    path('ws/chat/group/<str:room_name>/', ChatConsumer.as_asgi()),
    # Private chat endpoint
    path('ws/chat/private/<int:other_user>/', ChatConsumer.as_asgi()),
]
