from rest_framework import serializers
from .models import ChatRoom, Message

class MessageSerializer(serializers.ModelSerializer):
    sender = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'chatroom', 'sender', 'content', 'timestamp']
    
    def get_sender(self, obj):
        return obj.sender.email

class ChatRoomSerializer(serializers.ModelSerializer):
    messages = MessageSerializer(many=True, read_only=True)
    label = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = ['id', 'name', 'label','participants', 'messages', 'is_group']

    def get_label(self, obj):
        request = self.context.get('request')
        if not request:
            return None

        user = request.user
       
        if not obj.is_group and user in obj.participants.all():
            others = obj.participants.exclude(id=user.id)
            if others.exists():
                return others.first().username

        return None 
