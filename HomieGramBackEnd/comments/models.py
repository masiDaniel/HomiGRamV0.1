from django.db import models
from accounts.models import CustomUser
from houses.models import Houses

# Create your models here.
class HouseComments(models.Model):
    """
    This Table Will Hold Info on Comments on Houses
    """
    house_id = models.ForeignKey(Houses, on_delete=models.CASCADE, null=True, blank=False)
    user_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=False)
    comment = models.TextField()
    parent = models.ForeignKey(
        'self', 
        on_delete=models.CASCADE, 
        null=True, blank=True, 
        related_name='replies'
    )

    created_at = models.DateTimeField(auto_now_add=True)
   

    likes = models.ManyToManyField(CustomUser, related_name="liked_comments", blank=True)
    dislikes = models.ManyToManyField(CustomUser, related_name="disliked_comments", blank=True)

    def total_likes(self):
        return self.likes.count()

    def total_dislikes(self):
        return self.dislikes.count()
    
    def __str__(self):
        return f"Comment by {self.user} on {self.house_id}"