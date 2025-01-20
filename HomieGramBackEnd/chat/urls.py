from django.urls import path
from .views import ChatRoomAPIView, MessageAPIView

urlpatterns = [
    path('chatrooms/', ChatRoomAPIView.as_view(), name='chatrooms'),
    path('messages/', MessageAPIView.as_view(), name='messages'),
]