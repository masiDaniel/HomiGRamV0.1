from django.urls import path
from .views import AddBookmarkView, AssignTenantView, GetAmenitiessAPIView, GetBookmarksAPIView, GetLocationsAPIView, HouseAPIView, RateHouseAPIView, RemoveBookmarkView, SearchApiView, GetRoomssAPIView, getAdvvertismentsAPIView

urlpatterns = [
    path('gethouses/', HouseAPIView.as_view(), name="get_houses"),
    path('getRooms/', GetRoomssAPIView.as_view(), name="get_houses"),

    path("search/<str:name>", SearchApiView.as_view(), name="search_house"),
    path('rate/<int:house_id>/', RateHouseAPIView.as_view(), name='rate-house'),
    path('getLocation/', GetLocationsAPIView.as_view(), name="get_locations"),
    path('getAmenities/', GetAmenitiessAPIView.as_view(), name="get_amenities"),
    path('getBookmarks/', GetBookmarksAPIView.as_view(), name="get_bookmarks"),
    path('bookmark/add/<int:house_id>/', AddBookmarkView.as_view(), name='add_bookmark'),
    path('bookmark/remove/<int:house_id>/', RemoveBookmarkView.as_view(), name='remove_bookmark'),
    path('getAdverts/', getAdvvertismentsAPIView.as_view(), name="get_adverts"),
    path('assign-tenant/<int:house_id>/', AssignTenantView.as_view(), name='assign_tenant'),

]