from accounts.models import CustomUser
from rest_framework import serializers

class AccountSerializer(serializers.ModelSerializer): 
    class Meta:
        model = CustomUser
        fields = ['id', 'password', 'last_login', 'username', 'first_name',
                  'last_name', 'date_joined', 'email','nick_name', 'profile_pic', 'id_scan', 'id_number', 'phone_number', 'passport_pic', 'user_type', 'regno'
                  ]
        
        extra_kwargs = {
            "password": {"write_only": True}
        }

    def create(self, validated_data):
        """
        Creates a new user profile from the request's data
        """
        account = CustomUser(**validated_data)
        account.set_password(account.password)
        account.save()

        # user_profile = UserProfileModel.objects.create(account=account, **validated_data)
        return account
    
    def update(self, instance, validated_data):
        """
        Updates a user's profile from the request's data
        """
        instance.set_password(instance.password)
        validated_data["password"] = instance.password
        return super().update(instance, validated_data)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'email', 'first_name', 'last_name']

class MessageTokenSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=100)
    token = serializers.CharField(max_length=100)

class MessageSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=100)