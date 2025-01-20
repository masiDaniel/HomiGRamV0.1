from rest_framework import serializers
from .models import ChatRoom, Message

class MessageSerializer(serializers.ModelSerializer):
    sender = serializers.StringRelatedField()  # To display sender's username

    class Meta:
        model = Message
        fields = ['id', 'chatroom', 'sender', 'content', 'timestamp']

class ChatRoomSerializer(serializers.ModelSerializer):
    messages = MessageSerializer(many=True, read_only=True)

    class Meta:
        model = ChatRoom
        fields = ['id', 'name', 'participants', 'messages']
