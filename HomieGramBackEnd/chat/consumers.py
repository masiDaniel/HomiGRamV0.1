import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from django.contrib.auth.models import AnonymousUser
from django.db import close_old_connections
from urllib.parse import parse_qs
from knox.auth import TokenAuthentication
from .models import Message, ChatRoom

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        query_string = self.scope["query_string"].decode()
        token = parse_qs(query_string).get("token", [None])[0]

        if not token:
            await self.close()
            return

        user = await self.get_user_for_token(token)
        if not user or user.is_anonymous:
            await self.close()
            return

        self.scope["user"] = user
        self.user = user
        close_old_connections()

        self.room_name = self.scope["url_route"]["kwargs"]["room_name"]
        self.room_group_name = f"chat_{self.room_name}"

        room_exists = await self.room_exists_and_user_allowed(self.room_name, self.user)
        if not room_exists:
            await self.close()
            return

        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data["message"]
        receiver_id = data.get("receiver_id", None)
        sender = self.scope["user"]
        sender_id = sender.id

        room = await self.get_room(self.room_name)
        if not room:
            await self.send(text_data=json.dumps({"error": "Room does not exist."}))
            return

        if receiver_id:
            # Private message validation
            allowed = await self.both_users_allowed_in_room(self.room_name, sender_id, receiver_id)
            if not allowed:
                await self.send(text_data=json.dumps({
                    "error": "Both sender and receiver must be participants of this room."
                }))
                return
        else:
            # Group message validation
            is_participant = await self.is_user_in_room(sender_id, self.room_name)
            if not is_participant:
                await self.send(text_data=json.dumps({
                    "error": "Sender must be a participant to send group messages."
                }))
                return

        # Save and broadcast
        await self.save_message(sender_id, receiver_id, message, self.room_name)

        await self.channel_layer.group_send(
            self.room_group_name,
            {
                "type": "chat_message",
                "message": message,
                "sender_id": sender_id,
                "receiver_id": receiver_id
            }
        )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            "message": event["message"],
            "sender_id": event["sender_id"],
            "receiver_id": event["receiver_id"]
        }))

    @database_sync_to_async
    def get_user_for_token(self, token):
        auth = TokenAuthentication()
        try:
            user, _ = auth.authenticate_credentials(token.encode())
            return user
        except Exception:
            return AnonymousUser()

    @database_sync_to_async
    def get_room(self, room_name):
        try:
            return ChatRoom.objects.get(name=room_name)
        except ChatRoom.DoesNotExist:
            return None

    @database_sync_to_async
    def room_exists_and_user_allowed(self, room_name, user):
        try:
            room = ChatRoom.objects.get(name=room_name)
            return user in room.participants.all()
        except ChatRoom.DoesNotExist:
            return False

    @database_sync_to_async
    def both_users_allowed_in_room(self, room_name, sender_id, receiver_id):
        try:
            room = ChatRoom.objects.get(name=room_name)
            return (
                room.participants.filter(id=sender_id).exists() and
                room.participants.filter(id=receiver_id).exists()
            )
        except ChatRoom.DoesNotExist:
            return False

    @database_sync_to_async
    def is_user_in_room(self, user_id, room_name):
        try:
            room = ChatRoom.objects.get(name=room_name)
            return room.participants.filter(id=user_id).exists()
        except ChatRoom.DoesNotExist:
            return False

    @database_sync_to_async
    def save_message(self, sender_id, receiver_id, message, room_name):
        sender = User.objects.get(id=sender_id)
        receiver = User.objects.get(id=receiver_id) if receiver_id else None
        room = ChatRoom.objects.get(name=room_name)
        return Message.objects.create(
            sender=sender,
            receiver=receiver,
            chatroom=room,
            content=message
        )
