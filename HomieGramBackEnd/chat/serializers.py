from rest_framework import serializers

from accounts.models import CustomUser
from .models import ChatRoom, Message

class MessageSerializer(serializers.ModelSerializer):
    sender = serializers.SerializerMethodField()
    class Meta:
        model = Message
        fields = ['id', 'chatroom', 'sender', 'content', 'timestamp']
    
    def get_sender(self, obj):
        return obj.sender.email

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email']

class ChatRoomSerializer(serializers.ModelSerializer):
    messages = MessageSerializer(many=True, read_only=True)
    label = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    participants = UserSerializer(many=True, read_only=True)

    class Meta:
        model = ChatRoom
        fields = ['id', 'name', 'label','participants', 'messages', 'is_group',  'last_message', 'updated_at']

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
    def get_last_message(self, obj):
        msg = obj.messages.order_by("-timestamp").first()
        return MessageSerializer(msg).data if msg else None




    