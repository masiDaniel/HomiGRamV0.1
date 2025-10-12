from django.urls import path
from .views import CommentsApi, CommentDetailsApi

urlpatterns = [
    path('post/', CommentsApi.as_view(), name="post"),
    path('getComments/', CommentsApi.as_view(), name="getComment"),
    path('deleteComments/<int:pk>/', CommentDetailsApi.as_view(), name="coment-detail")
]