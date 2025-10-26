from django.urls import path
from .views import CartAPIView, CartItemAPIView, CategoryAPIView, MyBusinessAPIView, OrderAPIView, ProductAPIView


urlpatterns = [
    path("getBusiness/", MyBusinessAPIView.as_view(), name="get Buinesses" ), 
    path("updateBusiness/<int:pk>/", MyBusinessAPIView.as_view(), name="update Buinesses" ), 
    path("getCarts/", CartAPIView.as_view(), name="get carts" ),
    path("getCartItems/", CartItemAPIView.as_view(), name="get cart items" ),
    path("postCartItems/", CartItemAPIView.as_view(), name="post cart items" ),
    path("postProducts/", ProductAPIView.as_view(), name="post products" ),
    path("updateProducts/<int:pk>/", ProductAPIView.as_view(), name="update product" ),
    path("deleteProducts/<int:pk>/", ProductAPIView.as_view(), name="delete product" ),
    path("getProducts/", ProductAPIView.as_view(), name="get products" ),
    path("getCategorys/", CategoryAPIView.as_view(), name="get categorys" ),
    path("getOrders/", OrderAPIView.as_view(), name="get orders")
   
]