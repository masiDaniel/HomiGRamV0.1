from django.urls import path
from .views import MyBusinessAPIView


urlpatterns = [
    path("getBusiness/", MyBusinessAPIView.as_view(), name="get Buinesses" ), 
    
   
]