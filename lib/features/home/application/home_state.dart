part of 'home_bloc.dart';

abstract class HomeState {}

final class HomeInitialState extends HomeState {}

final class HomeDataLoadingStartState extends HomeState {}

final class HomeDataLoadingStopState extends HomeState {}

final class HomeDataSuccessState extends HomeState {}

final class GetLocationPermissionState extends HomeState {}

final class ShowCarMenuState extends HomeState {}

final class UpdateState extends HomeState {}

final class PolylineSuccessState extends HomeState {}

final class UserDetailsLoadingState extends HomeState {}

final class UserDetailsSuccessState extends HomeState {}

final class OnlineOfflineSuccessState extends HomeState {}

final class DistanceUpdateState extends HomeState {}

final class ChangedMenuState extends HomeState {}

final class ImageCaptureSuccessState extends HomeState {}

final class ImagePickState extends HomeState {}

final class EnableBiddingSettingsState extends HomeState {}

final class EnableBubbleSettingsState extends HomeState {}

class ShowErrorState extends HomeState {
  final String message;
  ShowErrorState({required this.message});
}

final class ShowImagePickState extends HomeState {}

final class ShowSignatureState extends HomeState {}

final class UpdateSignatureState extends HomeState {}

final class BidRideRequestState extends HomeState {}

final class ShowBidRideState extends HomeState {}

final class ShowBiddingPageState extends HomeState {}

final class ShowChooseStopsState extends HomeState {}

final class ShowOtpState extends HomeState {}

final class ChoosenCancelReasonState extends HomeState {}

final class CancelReasonSuccessState extends HomeState {}

final class RideChatSuccessState extends HomeState {}

final class ReviewUpdateState extends HomeState {}

final class AddReviewState extends HomeState {}

final class ShowChatState extends HomeState {}

final class OnlineOfflineLoadingState extends HomeState {}

final class RideUpdateState extends HomeState {}

final class InstantEtaSuccessState extends HomeState {}

final class InstantRideSuccessState extends HomeState {}

final class GetGoodsSuccessState extends HomeState {}

final class SearchTimerUpdateStatus extends HomeState {}

final class UserDetailsFailureState extends HomeState {}

final class UserUnauthenticatedState extends HomeState {}

final class ServiceTypeChangeState extends HomeState {}

final class UpdateLocationState extends HomeState {}

final class StateChangedState extends HomeState {}

final class DestinationSelectState extends HomeState {
  final bool isPickupChange;

  DestinationSelectState({required this.isPickupChange});
}

class UpdateReducedTimeState extends HomeState {
  final int reducedTimeInMinutes;
  UpdateReducedTimeState({required this.reducedTimeInMinutes});
}

class UpdateOnlineTimeState extends HomeState {
  final int minutes;

  UpdateOnlineTimeState({required this.minutes});
}

final class NavigationTypeState extends HomeState {}

class ShowoutsationpageState extends HomeState {
  final bool isVisible;

  ShowoutsationpageState({required this.isVisible});
}

class OutstationSuccessState extends HomeState {}

class ShowSubVehicleTypesState extends HomeState {}
