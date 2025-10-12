from django.urls import path
from .views import ChatRoomDetailView, MessageHistoryAPIView, GetOrCreateChatRoom ,CreateGroupChatRoom, UserChatRoomsAPIView

urlpatterns = [
    path("messages/<str:room_name>/", MessageHistoryAPIView.as_view(), name="message-history"),
    path("create-group/", CreateGroupChatRoom.as_view(), name="create-group-chat"), 
    path('my-chat-rooms/', UserChatRoomsAPIView.as_view(), name='my-chat-rooms'),
    path("get-or-create-room/", GetOrCreateChatRoom.as_view(), name="message-history"),
]