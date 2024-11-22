from django.shortcuts import render
from django.contrib.auth import authenticate, login, logout
from .serializers import AccountSerializer, MessageSerializer
from knox.models import AuthToken
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.decorators import permission_classes
from rest_framework import status
from rest_framework.response import Response
from .models import CustomUser

# Create your views here.
class LoginApIView(APIView):
    """
    handles User activities such as Login and Logout
    """
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        """
        Handles log in of the user
        """
        
        email = request.data.get("email")
        password = request.data.get("password")
        print(email, password)
        user = authenticate(username=email, password=password)

        # if user exists
        if user:
            serializer = AccountSerializer(user)
            login(request, user)
            data = serializer.data
            data['token'] = AuthToken.objects.create(user=user)[1]
            return Response(data, status=status.HTTP_200_OK)
        # user doesn't exist
        else:
            data = {
                "message": "Invalid User Credentials",
                }
            serializer = MessageSerializer(data)
            return Response(serializer.data, status=status.HTTP_403_FORBIDDEN)

class LogoutAPIView(APIView):
    """
    Handles User logout
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        """
        Handles log out of the user
        """
        logout(request)
        return Response({"message": "Logged out successfully."}, status=status.HTTP_200_OK)



class RegisterUsersAPIView(APIView):
    """
    Handles Registatration of Users
    """
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        """
        Handles registration of Users
        """
        data = {
            "first_name": request.data.get("first_name"),
            "last_name": request.data.get("last_name"),
            "email": request.data.get("email"),
            "password": request.data.get("password"),
        }
        # making the username same as the email
        data['username'] = request.data.get("email")

        serializer = AccountSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            data = {
                'message': "User Successfully registered",
                }
            serializer = MessageSerializer(data)
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserSearchAPIView(APIView):
    """
    Handles searching for a user or retrieving all users
    """
    # permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        """
        Handles getting all users or searching for a specific user
        """
        query = request.query_params.get('q')

        if query:
            users = CustomUser.objects.filter(email__icontains=query)
        else:
            users = CustomUser.objects.all()

        serializer = AccountSerializer(users, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class UpdateUserAPIView(APIView):
    """
    Handles dynamic updates to user fields
    """
    permission_classes = [IsAuthenticated]

    def patch(self, request, *args, **kwargs):
        """
        Updates user fields dynamically
        """
        # Get the authenticated user
        user = request.user

        # Extract fields to update from the request
        update_data = request.data

        if not update_data:
            return Response(
                {"message": "No data provided for update."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Update the user's fields
        for field, value in update_data.items():
            if hasattr(user, field):  # Check if the field exists on the user model
                setattr(user, field, value)
            else:
                return Response(
                    {"message": f"Field '{field}' is not valid."},
                    status=status.HTTP_400_BAD_REQUEST
                )

        # Save changes to the database
        user.save()

        # Serialize the updated user and return the response
        serializer = AccountSerializer(user)
        return Response(serializer.data, status=status.HTTP_200_OK)