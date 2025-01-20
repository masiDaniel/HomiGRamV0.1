from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import ChatRoom, Message
from .serializers import ChatRoomSerializer, MessageSerializer

class ChatRoomAPIView(APIView):
    """
    Handles chat room operations.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        """
        Retrieve all chat rooms.
        """
        chat_rooms = ChatRoom.objects.all()
        serializer = ChatRoomSerializer(chat_rooms, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, *args, **kwargs):
        """
        Create a new chat room.
        """
        serializer = ChatRoomSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class MessageAPIView(APIView):
    """
    Handles message operations.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        """
        Retrieve all messages.
        """
        messages = Message.objects.all()
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, *args, **kwargs):
        """
        Create a new message.
        """
        serializer = MessageSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(sender=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
