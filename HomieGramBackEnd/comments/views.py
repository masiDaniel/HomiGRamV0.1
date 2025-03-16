from tokenize import Comment
from django.shortcuts import render
from rest_framework import status, generics
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from comments.models import HouseComments
from .serializers import CommentsSerializers
from accounts.serializers import MessageSerializer
from .models import HouseComments

User = get_user_model() 

# Create your views here.
class CommentsApi(APIView):
    def get(self, request, *args, **kwargs):
        house_id = request.query_params.get("house_id")
        comments = HouseComments.objects.filter(house_id = house_id)
        serialzer = CommentsSerializers(comments, many=True)
        print(serialzer.data)
        return Response(serialzer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        Used to post a comment about houses
        """
        data = {
            "house_id" : request.data.get("house_id"),
            "user_id" : request.data.get("user_id"),
            "comment" : request.data.get("comment"),
            "parent" : request.data.get("parent"),
        }

        # checking data sent if any required field is missing return 400
        if not all(data):
            message ={"message": "Missing Some required Fields"}
            serializer = MessageSerializer(message)
            return Response(serializer.data, status=status.HTTP_400_BAD_REQUEST)
    
    

        serializer = CommentsSerializers(data=data)
        if serializer.is_valid():
            serializer.save()
            data = {
                'message': "Successfully Posted",
                }
            serializer = MessageSerializer(data)
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

    def put(self, request, *args, **kwargs):
        """Handles liking and disliking comments"""
        comment_id = request.data.get("comment_id")
        action = request.data.get("action")  # 'like' or 'dislike'
        user_id = request.data.get("user_id")

        try:
            comment = HouseComments.objects.get(id=comment_id)
            user = User.objects.get(id=user_id)  # Convert ID to actual User object

            if action == "like":
                if comment.likes.filter(id=user.id).exists():
                    comment.likes.remove(user)
                    return Response({"message": "Like removed"}, status=status.HTTP_200_OK)

                comment.likes.add(user)
                comment.dislikes.remove(user)  # Remove dislike if exists
                return Response({"message": "Comment liked"}, status=status.HTTP_200_OK)

            elif action == "dislike":
                if comment.dislikes.filter(id=user.id).exists():
                    comment.dislikes.remove(user)
                    return Response({"message": "Dislike removed"}, status=status.HTTP_200_OK)

                comment.dislikes.add(user)
                comment.likes.remove(user)  # Remove like if exists
                return Response({"message": "Comment disliked"}, status=status.HTTP_200_OK)

            return Response({"error": "Invalid action"}, status=status.HTTP_400_BAD_REQUEST)

        except HouseComments.DoesNotExist:
            return Response({"error": "Comment not found"}, status=status.HTTP_404_NOT_FOUND)

        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



class CommentDetailsApi(generics.DestroyAPIView):
    queryset = HouseComments.objects.all()
    def delete(self, request, *args, **kwargs):
        try:
            Comment = self.get_object()
            Comment.delete()
            return Response({"message": "comment deleted succesfully,"}, status=status.HTTP_204_NO_CONTENT)
        except HouseComments.DoesNotExist:
            return Response({"message": "comment does not excist"}, status=status.HTTP_404_NOT_FOUND)


