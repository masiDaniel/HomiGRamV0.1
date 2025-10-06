from django.urls import path
from .views import AddBookmarkView, ApproveTerminationAPIView, AssignCaretakerView, AssignTenantView, AmenitiessAPIView, ConfirmAgreementView, GetBookmarksAPIView, HouseWithRoomsAPIView, LocationsAPIView, HouseAPIView, MyRoomsAPIView, PaymentStatusView, RateHouseAPIView, RemoveBookmarkView, RemoveCaretakerView, RentPaymentPreviewView, RequestTerminationAPIView, SearchApiView, GetRoomssAPIView, GetAdvertisementsAPIView, GetCaretakersAPIView, StartRentView, SubmitAdvertisementAPIView,ConfirmPaymentAPIView, RentPaymentInitiateView,MpesaCallbackView 

urlpatterns = [
    path('gethouses/', HouseAPIView.as_view(), name="get_houses"),
    path('gethousesWithRooms/', HouseWithRoomsAPIView.as_view(), name="get_houses_with_rooms"),
    path('updateHouse/<int:house_id>/', HouseAPIView.as_view(), name="update-house"),
    path('getRooms/', GetRoomssAPIView.as_view(), name="get_houses"),
    path('getMyRooms/', MyRoomsAPIView.as_view(), name="get_houses"),
    path('updateRoom/<int:room_id>/', GetRoomssAPIView.as_view()),
    path("search/<str:name>", SearchApiView.as_view(), name="search_house"),
    path('rate/<int:house_id>/', RateHouseAPIView.as_view(), name='rate-house'),
    path('locations/', LocationsAPIView.as_view(), name="get_locations"),

    # /?status=pending, active, expired/
    path('getAdverstisments/', GetAdvertisementsAPIView.as_view(), name="get_advertismens"),
    path('submitAdvertisment/', SubmitAdvertisementAPIView.as_view(), name="submit_advertisment"),
    path('confirmPayment/', ConfirmPaymentAPIView.as_view(), name="confirm_payment"),
    path('amenities/', AmenitiessAPIView.as_view(), name="get_amenities"),
    path('getBookmarks/', GetBookmarksAPIView.as_view(), name="get_bookmarks"),
    path('bookmark/add/<int:house_id>/', AddBookmarkView.as_view(), name='add_bookmark'),
    path('bookmark/remove/<int:house_id>/', RemoveBookmarkView.as_view(), name='remove_bookmark'),

    path('assign-tenant/<int:house_id>/', AssignTenantView.as_view(), name='assign_tenant'),
    path('request-contract-termination/<int:agreement_id>/', RequestTerminationAPIView.as_view(), name='request_contract_termination'),
    path('approve-contract-termination/<int:agreement_id>/', ApproveTerminationAPIView.as_view(), name='assign_tenant'),
    path('assign-caretaker/', AssignCaretakerView.as_view(), name='assign_caretaker'),
    path('remove-caretaker/', RemoveCaretakerView.as_view(), name='remove_caretaker'),
    path('get-all-caretaker/', GetCaretakersAPIView.as_view(), name='get_caretakers'),

    #initiate reting process 
    path('initiate-renting-process/', StartRentView.as_view(), name='start_renting_process'),
    path('sign-agremment/', ConfirmAgreementView.as_view(), name='confirm_agreemeng'),
    path('payment-preview/', RentPaymentPreviewView.as_view(), name='payment_preview'),
    path('payment-initialization/', RentPaymentInitiateView.as_view(), name='payment_initialization'),
    path('payment-status/', PaymentStatusView.as_view(), name='payment_status'),
    path('mpesa-callback/', MpesaCallbackView.as_view(), name='mpesa_callback'),
]