from rest_framework import serializers
from .models import HouseComments

class CommentsSerializers(serializers.ModelSerializer):

    total_likes = serializers.SerializerMethodField()
    total_dislikes = serializers.SerializerMethodField()

    class Meta:
        model = HouseComments
        fields = '__all__'  # This includes total_likes and total_dislikes

    def get_total_likes(self, obj):
        return obj.likes.count()

    def get_total_dislikes(self, obj):
        return obj.dislikes.count()  # Fix wrong reference