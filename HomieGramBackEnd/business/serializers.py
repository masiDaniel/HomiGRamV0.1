from rest_framework import serializers
from .models import MyBusiness, Cart, CartItem, Category,Order, Product

class MyBusinessSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyBusiness
        fields = "__all__"

class CartSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cart
        fields = "__all__"

class CartItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = CartItem
        fields = "__all__"

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = "__all__"

class OrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = "__all__"

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = "__all__"
    

    extra_kwargs = {"seller": {"read_only": True}} 
      
    
    def create(self, validated_data):
        request = self.context.get("request")  # Get the request from context
        if "business" not in validated_data:  # If no business is provided
            validated_data["seller"] = request.user  # Set seller to the authenticated user

        return super().create(validated_data)

