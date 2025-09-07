from django.urls import path
from .views import GetUsersAPIView, LogoutAPIView, RegisterUsersAPIView, LoginApIView, UpdateUserAPIView, UserSearchAPIView
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView
)

urlpatterns = [
    path("signup/", RegisterUsersAPIView.as_view(), name="signup"),
    path("login/", LoginApIView.as_view(), name="login"),
    path("logout/", LogoutAPIView.as_view(), name="logout"),
    path('users/', UserSearchAPIView.as_view(), name='user-search'),
    path('user/update/', UpdateUserAPIView.as_view(), name='update-user'),
    path('getUsers/', GetUsersAPIView.as_view(), name='get-users'),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/token/verify/', TokenVerifyView.as_view(), name='token_verify'),
]