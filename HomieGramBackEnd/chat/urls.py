from django.urls import path
from .views import ChatRoomDetailView, MessageHistoryAPIView, GetOrCreateChatRoom ,CreateGroupChatRoom, UserChatRoomsAPIView

urlpatterns = [
    path("messages/<str:room_name>/", MessageHistoryAPIView.as_view(), name="message-history"),
    path("create-group/", CreateGroupChatRoom.as_view(), name="create-group-chat"), 
    path('my-chat-rooms/', UserChatRoomsAPIView.as_view(), name='my-chat-rooms'),
    path("get-or-create-room/", GetOrCreateChatRoom.as_view(), name="message-history"),
    #  path('chatroom/', GetOrCreateChatRoom.as_view(), name='get_or_create_chatroom'),
    # path('chatroom/<str:room_name>/', ChatRoomDetailView.as_view(), name='chatroom_detail'),
    # path('chatroom/<str:room_name>/messages/', MessageHistoryAPIView.as_view(), name='message_history'),
]