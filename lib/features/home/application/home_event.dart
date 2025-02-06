part of 'home_bloc.dart';

abstract class HomeEvent {}

class GetDirectionEvent extends HomeEvent {
  dynamic vsync;
  GetDirectionEvent({required this.vsync});
}

class GetUserDetailsEvent extends HomeEvent {
  final int? loading;
  GetUserDetailsEvent({this.loading});
}

class ShowCarMenuEvent extends HomeEvent {}

class ChooseCarMenuEvent extends HomeEvent {
  final int menu;
  ChooseCarMenuEvent({required this.menu});
}

class EnableBiddingEvent extends HomeEvent {
  final bool isEnabled;
  EnableBiddingEvent({required this.isEnabled});
}

class UpdatePricePerDistanceEvent extends HomeEvent {
  final String price;
  UpdatePricePerDistanceEvent({required this.price});
}

class EnableBubbleEvent extends HomeEvent {
  final bool isEnabled;
  EnableBubbleEvent({required this.isEnabled});
}

class StartBubbleEvent extends HomeEvent {}

class StopBubbleEvent extends HomeEvent {}

class RideRespondEvent extends HomeEvent {}

class StreamRequestEvent extends HomeEvent {}

class UploadProofEvent extends HomeEvent {
  final String image;
  final bool isBefore;
  final String id;
  UploadProofEvent(
      {required this.image, required this.isBefore, required this.id});
}

class ShowGetDropAddressEvent extends HomeEvent {}

class GetGoodsTypeEvent extends HomeEvent {}

class ShowBidRideEvent extends HomeEvent {
  final String id;
  final double pickLat;
  final double pickLng;
  final double dropLat;
  final double dropLng;
  final List stops;
  final String pickAddress;
  final String dropAddress;
  final String acceptedRideFare;
  ShowBidRideEvent({
    required this.id,
    required this.pickLat,
    required this.pickLng,
    required this.dropLat,
    required this.dropLng,
    required this.stops,
    required this.pickAddress,
    required this.dropAddress,
    required this.acceptedRideFare,
  });
}

class ChangeDistanceEvent extends HomeEvent {
  final double distance;
  ChangeDistanceEvent({required this.distance});
}

class AcceptRejectEvent extends HomeEvent {
  final String requestId;
  final int status;

  AcceptRejectEvent({required this.requestId, required this.status});
}

class AcceptBidRideEvent extends HomeEvent {
  final String id;
  AcceptBidRideEvent({required this.id});
}

class DeclineBidRideEvent extends HomeEvent {
  final String id;
  DeclineBidRideEvent({required this.id});
}

class AcceptOutStationRideEvent extends HomeEvent {
  final String id;
  AcceptOutStationRideEvent({required this.id});
}

class DeclineOutStationRideEvent extends HomeEvent {
  final String id;
  DeclineOutStationRideEvent({required this.id});
}

class RideArrivedEvent extends HomeEvent {
  final String requestId;
  RideArrivedEvent({required this.requestId});
}

class ImageCaptureEvent extends HomeEvent {}

class ShowOtpEvent extends HomeEvent {}

class ShowImagePickEvent extends HomeEvent {}

class ShowSignatureEvent extends HomeEvent {}

class UpdateSignEvent extends HomeEvent {
  final Map? points;
  UpdateSignEvent({required this.points});
}

class CompleteStopEvent extends HomeEvent {
  final String id;
  CompleteStopEvent({required this.id});
}

class ShowChooseStopEvent extends HomeEvent {}

class RideStartEvent extends HomeEvent {
  final String requestId;
  final String otp;
  final double pickLat;
  final double pickLng;
  RideStartEvent(
      {required this.requestId,
      required this.otp,
      required this.pickLat,
      required this.pickLng});
}

class RideEndEvent extends HomeEvent {
  RideEndEvent();
}

class PolylineEvent extends HomeEvent {
  final double pickLat;
  final double pickLng;
  final double dropLat;
  final double dropLng;
  final List stops;
  final String packageName;
  final String signKey;
  final String pickAddress;
  final String dropAddress;
  PolylineEvent(
      {required this.pickLat,
      required this.pickLng,
      required this.dropLat,
      required this.dropLng,
      required this.stops,
      required this.packageName,
      required this.signKey,
      required this.pickAddress,
      required this.dropAddress});
}

class GeocodingLatLngEvent extends HomeEvent {
  final double lat;
  final double lng;
  GeocodingLatLngEvent({
    required this.lat,
    required this.lng,
  });
}

class GeocodingAddressEvent extends HomeEvent {
  final String placeId;
  final String address;
  final LatLng? position;
  GeocodingAddressEvent(
      {required this.placeId, required this.address, this.position});
}

class GetAutoCompleteAddressEvent extends HomeEvent {
  final String searchText;

  GetAutoCompleteAddressEvent({required this.searchText});
}

class GetEtaRequestEvent extends HomeEvent {}

class CreateInstantRideEvent extends HomeEvent {}

class ClearAutoCompleteEvent extends HomeEvent {}

class ChangeMenuEvent extends HomeEvent {
  final int menu;
  ChangeMenuEvent({required this.menu});
}

class PolylineSuccessEvent extends HomeEvent {}

class OpenAnotherFeatureEvent extends HomeEvent {
  final String value;
  OpenAnotherFeatureEvent({required this.value});
}

class BidRideRequestEvent extends HomeEvent {}

class ShowBiddingPageEvent extends HomeEvent {}

class RemoveChoosenRideEvent extends HomeEvent {}

class PaymentRecievedEvent extends HomeEvent {}

class WaitingTimeEvent extends HomeEvent {}

class RequestTimerEvent extends HomeEvent {}

class GetCurrentLocationEvent extends HomeEvent {}

class UpdateCurrentPositionEvent extends HomeEvent {}

class ReviewUpdateEvent extends HomeEvent {
  final int star;

  ReviewUpdateEvent({required this.star});
}

class ChangeOnlineOfflineEvent extends HomeEvent {}

class AddReviewEvent extends HomeEvent {}

class ChangeGoodsEvent extends HomeEvent {
  String id;
  ChangeGoodsEvent({required this.id});
}

class ShowChatEvent extends HomeEvent {}

class UploadReviewEvent extends HomeEvent {}

class GetRideChatEvent extends HomeEvent {}

class ChatSeenEvent extends HomeEvent {}

class SendChatEvent extends HomeEvent {}

class HideCancelReasonEvent extends HomeEvent {}

class GetCancelReasonEvent extends HomeEvent {}

class DestinationSelectEvent extends HomeEvent {
  final bool isPickupChange;

  DestinationSelectEvent({required this.isPickupChange});
}

class ChooseCancelReasonEvent extends HomeEvent {
  final int? choosen;
  ChooseCancelReasonEvent({required this.choosen});
}

class CancelRequestEvent extends HomeEvent {}

class UpdateLocationEvent extends HomeEvent {
  final LatLng latLng;

  UpdateLocationEvent({required this.latLng});
}

class UpdateMarkerEvent extends HomeEvent {
  final LatLng latLng;

  UpdateMarkerEvent({required this.latLng});
}

class GetLocalDataEvent extends HomeEvent {}

class UpdateEvent extends HomeEvent {}

class UpdateReducedTimeEvent extends HomeEvent {
  final int reducedTimeInMinutes;
  UpdateReducedTimeEvent(this.reducedTimeInMinutes);
}

class UpdateOnlineTimeEvent extends HomeEvent {
  final int minutes;

  UpdateOnlineTimeEvent({required this.minutes});
}

class NavigationTypeEvent extends HomeEvent {
  NavigationTypeEvent();
}

class BiddingIncreaseOrDecreaseEvent extends HomeEvent {
  final bool isIncrease;
  BiddingIncreaseOrDecreaseEvent({required this.isIncrease});
}

class ShowoutsationpageEvent extends HomeEvent {
  final bool isVisible;
  ShowoutsationpageEvent({required this.isVisible});
}

class OutstationSuccessEvent extends HomeEvent {}

class GetSubVehicleTypesEvent extends HomeEvent {
  final String serviceLocationId;
  final String vehicleType;

  GetSubVehicleTypesEvent(
      {required this.serviceLocationId, required this.vehicleType});
}

class UpdateSubVehiclesTypeEvent extends HomeEvent {
   final List subTypes;

  UpdateSubVehiclesTypeEvent({required this.subTypes});
}
