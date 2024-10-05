from rest_framework import serializers
from .models import HouseComments

class CommentsSerializers(serializers.ModelSerializer):
    class Meta:
        model = HouseComments
        fields = ['id', 'house_id', 'user_id', 'comment',
                  'nested', 'nested_id']