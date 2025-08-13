# chat/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from accounts.models import CustomUser
from .models import ChatRoom, Message
from .serializers import ChatRoomSerializer, MessageSerializer
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from rest_framework.permissions import  IsAuthenticated


User = get_user_model()

class GetOrCreateChatRoom(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request):

        print("HEADERS:", request.headers)
        print("USER:", request.user)
        print("IS AUTH:", request.user.is_authenticated)
        user1 = request.user
        receiver_id = request.data.get("receiver_id")

        if not receiver_id:
            return Response({"error": "receiver_id is required"}, status=400)

        try:
            user2 = User.objects.get(id=receiver_id)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=404)

        room_name = f"user_{min(user1.id, user2.id)}_{max(user1.id, user2.id)}"
        room, created = ChatRoom.objects.get_or_create(name=room_name)
        room.participants.set([user1, user2])

        # Find the other user
        other_user = user2 if user1 == request.user else user1

        return Response({"room_name": room.name})


class CreateGroupChatRoom(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        name = request.data.get("name")
        participant_ids = request.data.get("participant_ids", [])
      

        if not name or not participant_ids:
            return Response({"error": "Group name and participant IDs are required."}, status=400)

        # Create the chat room
        room = ChatRoom.objects.create(name=name)
        room.participants.add(request.user)  # Add the creator

        for pid in participant_ids:
            try:
                user = User.objects.get(id=pid)
                room.participants.add(user)
            except User.DoesNotExist:
                continue


        return Response({
            "success": True,
            "room_id": room.id,
            "room_name": room.name,
            "participants": list(room.participants.values("id", "username"))
        })

class ChatRoomDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, room_name):
        room = get_object_or_404(ChatRoom, name=room_name)
        serializer = ChatRoomSerializer(room)
        return Response(serializer.data)
    


class MessageHistoryAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, room_name):
        room = get_object_or_404(ChatRoom, name=room_name)
        
        last_message_id = request.query_params.get("after_id")
        
        if last_message_id:
            messages = room.messages.filter(id__gt=last_message_id).order_by("timestamp")
        else:
            messages = room.messages.order_by("-timestamp")[:50]  # first load

        return Response(MessageSerializer(messages, many=True).data)



class UserChatRoomsAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        updated_after = request.query_params.get("updated_after")

        rooms = ChatRoom.objects.filter(participants=user)
        if updated_after:
            rooms = rooms.filter(updated_at__gt=updated_after)

        serializer = ChatRoomSerializer(rooms, many=True, context={'request': request})
        return Response(serializer.data)
    

# from django.shortcuts import get_object_or_404
# from rest_framework.views import APIView
# from rest_framework.response import Response
# from rest_framework import status
# from rest_framework.permissions import IsAuthenticated
# from .models import ChatRoom, Message
# from .serializers import ChatRoomSerializer, MessageSerializer

# class ChatRoomAPIView(APIView):
#     """
#     Handles chat room operations.
#     """
#     permission_classes = [IsAuthenticated]

#     def get(self, request, *args, **kwargs):
#         """
#         Retrieve all chat rooms.
#         """
#         chat_rooms = ChatRoom.objects.all()
#         serializer = ChatRoomSerializer(chat_rooms, many=True)
#         return Response(serializer.data, status=status.HTTP_200_OK)

#     def post(self, request, *args, **kwargs):
#         """
#         Create a new chat room.
#         """
#         serializer = ChatRoomSerializer(data=request.data)
#         if serializer.is_valid():
#             serializer.save()
#             return Response(serializer.data, status=status.HTTP_201_CREATED)
#         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# class MessageAPIView(APIView):
#     """
#     Handles message operations.
#     """
#     permission_classes = [IsAuthenticated]

#     def get(self, request, *args, **kwargs):
#         """
#         Retrieve all messages.
#         """
#         messages = Message.objects.all()
#         serializer = MessageSerializer(messages, many=True)
#         return Response(serializer.data, status=status.HTTP_200_OK)

#     def post(self, request, *args, **kwargs):
#         """
#         Create a new message.
#         """
#         serializer = MessageSerializer(data=request.data)
#         if serializer.is_valid():
#             serializer.save(sender=request.user)
#             return Response(serializer.data, status=status.HTTP_201_CREATED)
#         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

