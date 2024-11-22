from django.urls import path
from .views import LogoutAPIView, RegisterUsersAPIView, LoginApIView, UpdateUserAPIView, UserSearchAPIView

urlpatterns = [
    path("signup/", RegisterUsersAPIView.as_view(), name="signup"),
    path("login/", LoginApIView.as_view(), name="login"),
    path("logout/", LogoutAPIView.as_view(), name="logout"),
    path('users/', UserSearchAPIView.as_view(), name='user-search'),
    path('user/update/', UpdateUserAPIView.as_view(), name='update-user'),
]