part of 'acc_bloc.dart';

abstract class AccEvent {}

class AccGetUserDetailsEvent extends AccEvent {}

class AccGetDirectionEvent extends AccEvent {}

class AddHistoryMarkerEvent extends AccEvent {
  final List? stops;
  final String pickLat;
  final String pickLng;
  final String? dropLat;
  final String? dropLng;
  final String? polyline;
  AddHistoryMarkerEvent(
      {this.stops,
      required this.pickLat,
      required this.pickLng,
      this.dropLat,
      this.dropLng,
      this.polyline});
}

class SosInitEvent extends AccEvent {
  final SOSPageArguments arg;

  SosInitEvent({required this.arg});
}

class OnTapChangeEvent extends AccEvent {}

class IsEditPage extends AccEvent {}

class NavigateToEditPageEvent extends AccEvent {}

class GetUserProfileDetailsEvent extends AccEvent {}

class GetWithdrawDataEvent extends AccEvent {
  final int pageIndex;
  GetWithdrawDataEvent({required this.pageIndex});
}

class GetWithdrawInitEvent extends AccEvent {}

class RequestWithdrawEvent extends AccEvent {
  final String amount;
  RequestWithdrawEvent({required this.amount});
}

class UpdateControllerWithDetailsEvent extends AccEvent {
  final UpdateDetailsArguments args;

  UpdateControllerWithDetailsEvent({required this.args});
}

class GetFleetDashboardEvent extends AccEvent {
  final String fleetId;

  GetFleetDashboardEvent({required this.fleetId});
}

class GetDriverPerformanceEvent extends AccEvent {
  final String driverId;

  GetDriverPerformanceEvent({required this.driverId});
}

class UpdateDetailsEvent extends AccEvent {
  final String? name;
  final String? mail;

  UpdateDetailsEvent({
    required this.name,
    required this.mail,
  });
}

class UpdateTextFieldEvent extends AccEvent {
  final String text;
  final UpdateDetailsArguments arg;

  UpdateTextFieldEvent({required this.text, required this.arg});
}

class UpdateUserNameEvent extends AccEvent {
  final String name;

  UpdateUserNameEvent({required this.name});
}

class UpdateUserEmailEvent extends AccEvent {
  final String email;

  UpdateUserEmailEvent({required this.email});
}

class UpdateUserGenderEvent extends AccEvent {
  final String gender;

  UpdateUserGenderEvent({required this.gender});
}

class UserDetailsPageInitEvent extends AccEvent {
  final AccountPageArguments arg;

  UserDetailsPageInitEvent({required this.arg});
}

class NotificationGetEvent extends AccEvent {
  final int? pageNumber;

  NotificationGetEvent({this.pageNumber});
}

class ComplaintEvent extends AccEvent {
  final String? complaintType;

  ComplaintEvent({this.complaintType});
}

class NotificationLoading extends AccEvent {}

class GetBankDetails extends AccEvent {}

class DeleteNotificationEvent extends AccEvent {
  final String id;

  DeleteNotificationEvent({required this.id});
}

class ClearAllNotificationsEvent extends AccEvent {}

class HistoryGetEvent extends AccEvent {
  final String historyFilter;
  final int? pageNumber;
  final int? typeIndex;

  HistoryGetEvent(
      {required this.historyFilter, this.pageNumber, this.typeIndex});
}

class AddBankEvent extends AccEvent {
  final int? choosen;

  AddBankEvent({
    required this.choosen,
  });
}

class EditBankEvent extends AccEvent {
  final int? choosen;

  EditBankEvent({
    required this.choosen,
  });
}

class UpdateBankDetailsEvent extends AccEvent {
  final dynamic body;
  UpdateBankDetailsEvent({required this.body});
}

class OutstationReadyToPickupEvent extends AccEvent {
  final String requestId;

  OutstationReadyToPickupEvent({required this.requestId});
}

class DriverLevelnitEvent extends AccEvent {}

class DriverLevelGetEvent extends AccEvent {
  final int pageNo;
  DriverLevelGetEvent({required this.pageNo});
}

class LogoutEvent extends AccEvent {}

class GetFaqListEvent extends AccEvent {}

class FaqOnTapEvent extends AccEvent {
  final int selectedFaqIndex;

  FaqOnTapEvent({required this.selectedFaqIndex});
}

class UpdateUserDetailsEvent extends AccEvent {
  final String name;
  final String email;
  final String gender;
  final String profileImage;

  UpdateUserDetailsEvent(
      {required this.name,
      required this.email,
      required this.gender,
      required this.profileImage});
}

class GenderSelectedEvent extends AccEvent {
  final String selectedGender;

  GenderSelectedEvent({required this.selectedGender});
}

class ChooseMapOnTapEvent extends AccEvent {
  final int chooseMapIndex;

  ChooseMapOnTapEvent({required this.chooseMapIndex});
}

class ComplaintButtonEvent extends AccEvent {
  final String complaintTitleId;
  final String complaintText;
  final String requestId;

  ComplaintButtonEvent(
      {required this.complaintTitleId,
      required this.complaintText,
      required this.requestId});
}

class DeleteAccountEvent extends AccEvent {}

class HistoryTypeChangeEvent extends AccEvent {
  final int historyTypeIndex;

  HistoryTypeChangeEvent({required this.historyTypeIndex});
}

class GetWalletHistoryListEvent extends AccEvent {
  final int pageIndex;
  GetWalletHistoryListEvent({required this.pageIndex});
}

class GetSubscriptionListEvent extends AccEvent {}

class SubscribeToPlanEvent extends AccEvent {
  final int paymentOpt;
  final int amount;
  final int planId;

  SubscribeToPlanEvent(
      {required this.paymentOpt, required this.amount, required this.planId});
}

class SubscriptionOnTapEvent extends AccEvent {
  final int selectedPlanIndex;
  SubscriptionOnTapEvent({required this.selectedPlanIndex});
}

class SubscriptionPaymentOnTapEvent extends AccEvent {
  final int selectedPayIndex;
  SubscriptionPaymentOnTapEvent({required this.selectedPayIndex});
}

class ChoosePlanEvent extends AccEvent {
  final bool isPlansChoosed;

  ChoosePlanEvent({required this.isPlansChoosed});
}

class WalletEmptyEvent extends AccEvent {}

class GetWalletInitEvent extends AccEvent {}

class TransferMoneySelectedEvent extends AccEvent {
  final String selectedTransferAmountMenuItem;

  TransferMoneySelectedEvent({required this.selectedTransferAmountMenuItem});
}

class MoneyTransferedEvent extends AccEvent {
  final String transferMobile;
  final String role;
  final String transferAmount;

  MoneyTransferedEvent(
      {required this.transferMobile,
      required this.role,
      required this.transferAmount});
}

class DeleteContactEvent extends AccEvent {
  final String? id;

  DeleteContactEvent({required this.id});
}

class SelectContactDetailsEvent extends AccEvent {}

class AddContactEvent extends AccEvent {
  final String name;
  final String number;

  AddContactEvent({required this.name, required this.number});
}

class UpdateEvent extends AccEvent {}

class DeleteFavAddressEvent extends AccEvent {
  final String? id;

  DeleteFavAddressEvent({required this.id});
}

class GetFavListEvent extends AccEvent {}

class FavPageInitEvent extends AccEvent {}

class SelectFromFavAddressEvent extends AccEvent {
  final String addressType;

  SelectFromFavAddressEvent({required this.addressType});
}

class AddFavAddressEvent extends AccEvent {
  final String address;
  final String name;
  final String lat;
  final String lng;

  AddFavAddressEvent(
      {required this.address,
      required this.name,
      required this.lat,
      required this.lng});
}

class UserDetailEditEvent extends AccEvent {
  final String header;
  final String text;

  UserDetailEditEvent({required this.header, required this.text});
}

class UserDetailEvent extends AccEvent {}

class SendAdminMessageEvent extends AccEvent {
  final String newChat;
  final String message;
  final String chatId;

  SendAdminMessageEvent(
      {required this.newChat, required this.message, required this.chatId});
}

class GetAdminChatHistoryListEvent extends AccEvent {}

class PickImageFromGalleryEvent extends AccEvent {}

class PickImageFromCameraEvent extends AccEvent {}

class AdminMessageSeenEvent extends AccEvent {
  final String? chatId;

  AdminMessageSeenEvent({required this.chatId});
}

class GetOwnerDashboardEvent extends AccEvent {}

class UpdateImageEvent extends AccEvent {
  final String name;
  final String email;
  final String gender;
  final ImageSource source;

  UpdateImageEvent({
    required this.name,
    required this.email,
    required this.gender,
    required this.source,
  });
}

class GetLeaderBoardEvent extends AccEvent {
  final int type;
  GetLeaderBoardEvent({required this.type});
}

class LanguageGetEvent extends AccEvent {}

class FavLocateMeEvent extends AccEvent {}

class PaymentOnTapEvent extends AccEvent {
  final int selectedPaymentIndex;

  PaymentOnTapEvent({required this.selectedPaymentIndex});
}

class RideLaterCancelRequestEvent extends AccEvent {
  final String requestId;

  RideLaterCancelRequestEvent({
    required this.requestId,
  });
}

class UserDataInitEvent extends AccEvent {
  final UserDetail? userDetails;

  UserDataInitEvent({required this.userDetails});
}

class AddMoneyWebViewUrlEvent extends AccEvent {
  dynamic from;
  dynamic url;
  dynamic userId;
  dynamic requestId;
  dynamic currencySymbol;
  dynamic money;
  dynamic planId;
  BuildContext context;

  AddMoneyWebViewUrlEvent(
      {this.url,
      this.from,
      this.userId,
      this.requestId,
      this.currencySymbol,
      this.money,
      this.planId,
      required this.context});
}

class AddDriverEvent extends AccEvent {}

class GetVehiclesEvent extends AccEvent {}

class GetUserDetailsEvent extends AccEvent {}

class ChangeEarningsWeekEvent extends AccEvent {
  final int week;
  ChangeEarningsWeekEvent({required this.week});
}

class GetDailyEarningsEvent extends AccEvent {
  final String date;
  GetDailyEarningsEvent({required this.date});
}

class GetEarningsEvent extends AccEvent {}

class GetDriverEvent extends AccEvent {
  int from;
  String? fleetId;
  GetDriverEvent({required this.from, this.fleetId});
}

class DeleteDriverEvent extends AccEvent {
  String driverId;
  DeleteDriverEvent({required this.driverId});
}

class AssignDriverEvent extends AccEvent {
  String driverId;
  String fleetId;
  AssignDriverEvent({required this.driverId, required this.fleetId});
}

class SosLoadingEvent extends AccEvent {}

class NotificationLoadingEvent extends AccEvent {}

class WalletPageReUpdateEvent extends AccEvent {
  String from;
  String url;
  String userId;
  String requestId;
  String currencySymbol;
  String money;
  String planId;

  WalletPageReUpdateEvent({
    required this.from,
    required this.url,
    required this.userId,
    required this.requestId,
    required this.currencySymbol,
    required this.money,
    required this.planId,
  });
}

class GetIncentiveEvent extends AccEvent {
  final int type;
  GetIncentiveEvent({
    required this.type,
  });
}

class SelectIncentiveDateEvent extends AccEvent {
  final String selectedDate;
  final bool isSelected;
  final int choosenIndex;

  SelectIncentiveDateEvent(
      {required this.selectedDate,
      required this.isSelected,
      required this.choosenIndex});
}

class DriverLevelPopupEvent extends AccEvent {
  final LevelDetails driverLevelList;

  DriverLevelPopupEvent({required this.driverLevelList});
}

class DriverRewardGetEvent extends AccEvent {
  final int pageNo;
  DriverRewardGetEvent({required this.pageNo});
}

class DriverGetInitEvent extends AccEvent {}

class DriverRewardInitEvent extends AccEvent {}

class DriverRewardPointsEvent extends AccEvent {}

class RedeemPointsEvent extends AccEvent {
  final String amount;
  RedeemPointsEvent({required this.amount});
}

class HowItWorksEvent extends AccEvent {}

class UpdateRedeemedAmountEvent extends AccEvent {
  final double? redeemedAmount;
  UpdateRedeemedAmountEvent({required this.redeemedAmount});
}
