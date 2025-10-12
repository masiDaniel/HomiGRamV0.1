from django.contrib import admin
from .models import CustomUser

@admin.register(CustomUser)
class CustomUserAdmin(admin.ModelAdmin):
    list_display = ('id', 'username', 'email', 'regno', 'user_type', 'is_active')
    readonly_fields = ('regno',)
    search_fields = ('username', 'email', 'regno')
    list_filter = ('user_type', 'is_active', 'is_staff')
    ordering = ('id',)