from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.generics import get_object_or_404
from rest_framework import status
from .models import MyBusiness, Category,Product, Order, Cart, CartItem
from .serializers import MyBusinessSerializer, CategorySerializer, ProductSerializer, CartItemSerializer, CartSerializer, OrderSerializer

# Create your views here.

class MyBusinessAPIView(APIView):
    """
    handles the business operations
    """
    

    def get(self, request, *args, **kwargs):
        """
        get all businesses in teh database
        """

        businesses = MyBusiness.objects.all()
        serialzer = MyBusinessSerializer(businesses, many=True)
        return Response(serialzer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        this will post a business
        """
        serializer = MyBusinessSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

class CategoryAPIView(APIView):
    """
    handles the category operations
    """
    

    def get(self, request, *args, **kwargs):
        """
        get all categories in teh database
        """

        categories = Category.objects.all()
        serialzer = CategorySerializer(categories, many=True)
        return Response(serialzer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        this will post a business
        """
        serializer = CategorySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class ProductAPIView(APIView):
    """
    handles the Product operations
    """
    

    def get(self, request, *args, **kwargs):
        """
        get all products in teh database
        """
        business_null = request.query_params.get('business', None)
        
        if business_null == "null":
            products = Product.objects.filter(business__isnull=True)
        else:
            products = Product.objects.all()

        serialzer = ProductSerializer(products, many=True)
        return Response(serialzer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        this will post a product
        """

        data = request.data.copy()

        if 'business' not in data or not data['business']:
            data['user'] = request.user.id

        serializer = ProductSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

    def patch(self, request, *args, **kwargs):
        """
        this will update parts of a product
        """
        # Retrieve the product instance by the ID from the URL or request data
        product = get_object_or_404(Product, id=kwargs.get('pk'))

        # Use partial=True to allow partial updates
        serializer = ProductSerializer(product, data=request.data, partial=True)

        if serializer.is_valid():
            # Save the updates to the product instance
            serializer.save()
            return Response(serializer.data, status=status.HTTP_202_ACCEPTED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, *args, **kwargs):
        """
        this is to delete a product.
        """

        product = get_object_or_404(Product, id=kwargs.get('pk'))

        # Delete the product instance
        product.delete()

        # Return a success response
        return Response({"message": "Product deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
    
    

class CartAPIView(APIView):
    """
    handles the cart operations
    """
    

    def get(self, request, *args, **kwargs):
        """
        get all carts in teh database
        """

        user = request.user

        try:
            cart = Cart.objects.get(user=user)  # Fetch cart for this user
            serializer = CartSerializer(cart)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Cart.DoesNotExist:
            return Response({"message": "No cart found for this user"}, status=status.HTTP_404_NOT_FOUND)
        
    def post(self, request, *args, **kwargs):
        """
        this will post a cart
        """
        user = request.user

        # Check if user already has a cart
        if Cart.objects.filter(user=user).exists():
            return Response({"message": "User already has a cart"}, status=status.HTTP_400_BAD_REQUEST)

        serializer = CartSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)  # Assign user to the cart
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class CartItemAPIView(APIView):
    """
    handles the cart item operations
    """


    def get(self, request, *args, **kwargs):
        """
        get all cart items in teh database
        """

        cartItems = CartItem.objects.all()
        serialzer = CartItemSerializer(cartItems, many=True)
        return Response(serialzer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        this will post a cart item
        """
        serializer = CartItemSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class OrderAPIView(APIView):
    """
    handles the order operations
    """
    

    def get(self, request, *args, **kwargs):
        """
        get all orders in teh database
        """

        orders = Order.objects.all()
        serialzer = OrderSerializer(orders, many=True)
        return Response(serialzer.data, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        """
        this will post an order
        """
        serializer = OrderSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
