from django.contrib import admin
from business.models import Category, Product, CartItem, Cart, Order, MyBusiness
# Register your models here.

admin.site.register(Category)
admin.site.register(Product)
admin.site.register(Cart)
admin.site.register(CartItem)
admin.site.register(Order)
admin.site.register(MyBusiness)

