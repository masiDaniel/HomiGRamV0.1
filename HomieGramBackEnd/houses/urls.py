from django.urls import path
from .views import AddBookmarkView, AssignCaretakerView, AssignTenantView, AmenitiessAPIView, GetBookmarksAPIView, LocationsAPIView, HouseAPIView, RateHouseAPIView, RemoveBookmarkView, RemoveCaretakerView, SearchApiView, GetRoomssAPIView, getAdvvertismentsAPIView, GetCaretakersAPIView, getAdvvertismentsAPIView, SubmitAdvertisementAPIView,ConfirmPaymentAPIView

urlpatterns = [
    path('gethouses/', HouseAPIView.as_view(), name="get_houses"),
    path('updateHouse/<int:house_id>/', HouseAPIView.as_view(), name="update-house"),
    path('getRooms/', GetRoomssAPIView.as_view(), name="get_houses"),
    path("search/<str:name>", SearchApiView.as_view(), name="search_house"),
    path('rate/<int:house_id>/', RateHouseAPIView.as_view(), name='rate-house'),
    path('locations/', LocationsAPIView.as_view(), name="get_locations"),
    path('getAdverstisments/', getAdvvertismentsAPIView.as_view(), name="get_advertismens"),
    path('submitAdvertisment/', SubmitAdvertisementAPIView.as_view(), name="submit_advertisment"),
    path('confirmPayment/', ConfirmPaymentAPIView.as_view(), name="confirm_payment"),
    path('amenities/', AmenitiessAPIView.as_view(), name="get_amenities"),
    path('getBookmarks/', GetBookmarksAPIView.as_view(), name="get_bookmarks"),
    path('bookmark/add/<int:house_id>/', AddBookmarkView.as_view(), name='add_bookmark'),
    path('bookmark/remove/<int:house_id>/', RemoveBookmarkView.as_view(), name='remove_bookmark'),
    path('getAdverts/', getAdvvertismentsAPIView.as_view(), name="get_adverts"),
    path('assign-tenant/<int:house_id>/', AssignTenantView.as_view(), name='assign_tenant'),
    path('assign-caretaker/', AssignCaretakerView.as_view(), name='assign_caretaker'),
    path('remove-caretaker/', RemoveCaretakerView.as_view(), name='remove_caretaker'),
    path('get-all-caretaker/', GetCaretakersAPIView.as_view(), name='get_caretakers'),
]