from django.contrib.auth import authenticate
from .serializers import AccountSerializer, MessageSerializer, UserSerializer
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework import status
from rest_framework.response import Response
from .models import CustomUser
from rest_framework_simplejwt.tokens import RefreshToken

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

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
        user = authenticate(username=email, password=password)

        if user:
            serializer = AccountSerializer(user)
            tokens = get_tokens_for_user(user)

            data = serializer.data
            data.update(tokens)
     
            return Response(data, status=status.HTTP_200_OK)

        else:
            data = {
                "message": "Invalid User Credentials",
                }
            serializer = MessageSerializer(data)
            return Response(serializer.data, status=status.HTTP_403_FORBIDDEN)

class LogoutAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get("refresh")
            if not refresh_token:
                return Response(
                    {"message": "Refresh token is required."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            token = RefreshToken(refresh_token)
            token.blacklist() 

            return Response(
                {"message": "Logged out successfully."},
                status=status.HTTP_205_RESET_CONTENT
            )

        except Exception:
            return Response(
                {"message": "Invalid or expired token."},
                status=status.HTTP_400_BAD_REQUEST
            )



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
    permission_classes = [IsAuthenticated]

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
        user = request.user
        update_data = request.data

        if not update_data:
            return Response(
                {"message": "No data provided for update."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        for field, value in update_data.items():
            if hasattr(user, field):  
                setattr(user, field, value)
            else:
                return Response(
                    {"message": f"Field '{field}' is not valid."},
                    status=status.HTTP_400_BAD_REQUEST
                )
     
        user.save()

        serializer = AccountSerializer(user)
        return Response(serializer.data, status=status.HTTP_200_OK)


class GetUsersAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get (self, request, *args , **kwargs):
        """
        get all userss in the database
        """
        users = CustomUser.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)