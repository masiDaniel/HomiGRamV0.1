import json
from channels.generic.websocket import AsyncWebsocketConsumer

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        
        # Check if it's a private chat or group chat
        if 'room_name' in self.scope['url_route']['kwargs']:
            self.room_name = self.scope['url_route']['kwargs']['room_name']
        else:
            user1 = self.scope['user']
            user2_id = self.scope['url_route']['kwargs']['other_user']
            self.room_name = f'private_{min(user1.id, user2_id)}_{max(user1.id, user2_id)}'

        self.room_group_name = f'chat_{self.room_name}'

        # Join the room
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        # Remove the user from the private room
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data['message']
        username = self.scope['user'].username 

        # Broadcast message to the private room
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message,
                'username': username,
            }
        )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'message': event['message'],
            'username': event['username'],
        }))
