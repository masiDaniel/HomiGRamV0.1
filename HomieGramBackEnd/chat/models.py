from django.db import models
from accounts.models import CustomUser

# Create your models here.
class ChatRoom(models.Model):
    name = models.CharField(max_length=255, unique=True)
    label = models.CharField(max_length=255, blank=True)
    participants = models.ManyToManyField(CustomUser, related_name='chatrooms')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_group = models.BooleanField(default=False)

    def __str__(self):
        return self.name

class Message(models.Model):
    chatroom = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    receiver = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="received_messages", null=True,
    blank=True )
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.sender.username}: {self.content[:30]}"