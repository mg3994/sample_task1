// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bubble_head/bubble.dart';
import 'package:dash_bubble/dash_bubble.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_tagxi/common/tobitmap.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_tagxi/common/app_audios.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/geohasher.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/db/app_database.dart';
import 'package:restart_tagxi/features/home/application/usecase/ride_usecases.dart';
import 'package:restart_tagxi/features/home/domain/models/address_auto_complete_model.dart';
import 'package:restart_tagxi/features/home/domain/models/cancel_reason_model.dart';
import 'package:restart_tagxi/features/home/domain/models/goods_type_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:restart_tagxi/common/debouncer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:workmanager/workmanager.dart';
import '../../../common/common.dart';
import '../../../core/utils/custom_snack_bar.dart';
import '../../../core/utils/functions.dart';
import '../../../di/locator.dart';
import '../../driverprofile/domain/models/vehicle_types_model.dart';
import 'usecase/home_usecases.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  GoogleMapController? googleMapController;
  AudioPlayer audioPlayer = AudioPlayer();

  TextEditingController searchController = TextEditingController();
  TextEditingController pickupAddressController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  TextEditingController dropAddressController = TextEditingController();
  TextEditingController rideOtp = TextEditingController();
  TextEditingController chatField = TextEditingController();
  TextEditingController cancelReasonText = TextEditingController();
  TextEditingController bidRideAmount = TextEditingController();
  TextEditingController outstationRideAmount = TextEditingController();
  TextEditingController instantUserName = TextEditingController();
  TextEditingController instantUserMobile = TextEditingController();
  TextEditingController goodsSizeText = TextEditingController();
  TextEditingController pricePerDistance = TextEditingController();
  final fm.MapController fmController = fm.MapController();
  Set<Polyline> polyline = {};
  String? choosenCompleteStop;
  List rideList = [];
  List outStationList = [];
  String? choosenRide;
  List waitingList = [];
  final debouncer = Debouncer(milliseconds: 1000);
  List oldRides = [];
  String? sessionToken;
  String? instantRidePrice;
  String? instantRideCurrency;
  bool autoSuggestionSearching = false;
  bool isBiddingIncreaseLimitReach = false;
  bool isBiddingDecreaseLimitReach = false;
  bool visibleOutStation = false;
  List latlngArray = [];
  double distance = 0.0;
  int waitingTimeBeforeStart = 0;
  int waitingTimeAfterStart = 0;
  Animation<double>? _animation;
  AnimationController? animationController;
  bool showOutstationWidget = false;
  dynamic vsync;
  String darkMapString = '';
  String lightMapString = '';
  int choosenMenu = 0;
  List banners = [];
  List chats = [];
  int timer = 0;
  int? choosenCancelReason;
  String dropAddress = '';
  LatLng? dropLatLng;
  LatLng? pickLatLng;
  String pickAddress = '';
  String languageCode = '';
  Timer? searchTimer;
  bool isOnline = false;
  bool isUserCancelled = false;
  bool bidDeclined = false;
  bool isLoading = false;
  List<CancelReasonData> cancelReasons = [];
  bool showCancelReason = false;
  GeoHasher geo = GeoHasher();
  double lat = 0.0144927536231884;
  double lon = 0.0181818181818182;
  bool onlineLoader = false;
  List signaturePoints = [];
  bool addReview = false;
  bool showCarMenu = false;
  Query request = FirebaseDatabase.instance.ref('request-meta');
  Stream<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: (Platform.isAndroid)
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 50,
              intervalDuration: Duration(seconds: 5),
              foregroundNotificationConfig: const ForegroundNotificationConfig(
                notificationText:
                    "${AppConstants.title} will continue to receive your location in background",
                notificationTitle: "Location background service running",
                enableWakeLock: true,
              ))
          : AppleSettings(
              accuracy: LocationAccuracy.high,
              activityType: ActivityType.otherNavigation,
              distanceFilter: 50,
              showBackgroundLocationIndicator: true,
            ));
  StreamSubscription? positionSubscription;
  StreamSubscription? requestStream;
  StreamSubscription? bidRequestStream;
  StreamSubscription? rideStream;
  StreamSubscription? rideAddStream;
  StreamSubscription? ownersDriver;
  BitmapDescriptor? vehicleMarker;
  BitmapDescriptor? onlineCar;
  BitmapDescriptor? onrideCar;
  BitmapDescriptor? offlineCar;
  BitmapDescriptor? onlineTruck;
  BitmapDescriptor? onrideTruck;
  BitmapDescriptor? offlineTruck;
  BitmapDescriptor? onlineBike;
  BitmapDescriptor? onrideBike;
  BitmapDescriptor? offlineBike;
  List<GoodsData> goodsList = [];
  String? choosenGoods;
  String goodsSize = 'Loose';
  String? loadImage;
  String? unloadImage;
  String? signatureImage;
  String polyString = '';
  Timer? currentPosition;
  Timer? waitingTimer;
  Timer? activeTimer;
  String currentLocation = '';
  String acceptedRideFare = '';
  bool showChat = false;
  bool showOtp = false;
  bool showImagePick = false;
  bool showSignature = false;
  double? distanceBetween;
  bool showGetDropAddress = false;
  int review = 0;
  int choosenCarMenu = 1;
  bool showBiddingPage = false;
  LatLng? currentLatLng;
  List<Marker> markers = [];
  CameraPosition? initialCameraPosition;
  bool vehicleNotUpdated = false;
  List<AddressData> autoCompleteAddress = [];
  List<VehicleTypeData> subVehicleTypes = [];
  List selectedSubVehicleTypes = [];
  List distanceBetweenList = [
    {'name': 2, 'dist': 2.0, 'value': 1.2427},
    {'name': 4, 'dist': 4.0, 'value': 2.48548},
    {'name': 6, 'dist': 6.0, 'value': 3.72823},
    {'name': 8, 'dist': 8.0, 'value': 4.97097}
  ];
  String? instantRideType;
  String? etaDistance;
  String? etaDuration;
  bool isBiddingEnabled = false;
  bool isSubscriptionShown = false;
  double reducedTimeInMinutes = 5;
  bool navigationType = false;
  Timer? biddingRideTimer;

  HomeBloc() : super(HomeInitialState()) {
    on<UpdateEvent>((event, emit) => UpdateState());
    on<GetDirectionEvent>(getDirection);
    on<GetUserDetailsEvent>(getUserDetails);
    on<ChangeOnlineOfflineEvent>(changeOnlineOffline);
    on<DestinationSelectEvent>(destinationUpdate);
    // Location
    on<GetCurrentLocationEvent>(getCurrentLocation);
    on<UpdateLocationEvent>(updateLocation);
    on<UpdateMarkerEvent>(updateMarkerLocation);
    on<AcceptRejectEvent>(respondRequest);
    on<RequestTimerEvent>(rideTimerUpdate);
    on<StreamRequestEvent>(onTripRequest);
    on<RideArrivedEvent>(rideArrived);
    on<RideStartEvent>(rideStart);
    on<WaitingTimeEvent>(waitingTimerEmit);
    on<PolylineEvent>(getPolyline);
    on<PolylineSuccessEvent>(streamPolyline);
    on<RideEndEvent>(rideEnd);
    on<GeocodingLatLngEvent>(getAddressFromLatLng);
    on<PaymentRecievedEvent>(paymentRecieved);
    on<AddReviewEvent>(addReviewFunc);
    on<ReviewUpdateEvent>(changeReview);
    on<UploadReviewEvent>(addRideReview);
    on<OpenAnotherFeatureEvent>(openAnotherFeature);
    on<ShowChatEvent>(showChatFunc);
    on<GetRideChatEvent>(getRideChats);
    on<ChatSeenEvent>(chatSeen);
    on<SendChatEvent>(sendChat);
    on<GetCancelReasonEvent>(getCancelReason);
    on<HideCancelReasonEvent>(cancelReasonChoose);
    on<ChooseCancelReasonEvent>(chooseCancelReason);
    on<CancelRequestEvent>(cancelRequest);
    on<ImageCaptureEvent>(captureImage);
    on<ShowOtpEvent>(showOtpFunc);
    on<ShowImagePickEvent>(showImagePickFunc);
    on<ShowSignatureEvent>(showSignatureFunc);
    on<UpdateSignEvent>(signaturePointUpdate);
    on<BidRideRequestEvent>(bidRequestUpdate);
    on<ShowBiddingPageEvent>(showBiddingPageFunc);
    on<DeclineBidRideEvent>(declineBidRide);
    on<ShowBidRideEvent>(showBidRideFunc);
    on<AcceptBidRideEvent>(acceptBidRide);
    on<RemoveChoosenRideEvent>(removeChoosenRide);
    on<ChangeDistanceEvent>(updateDistanceBetween);
    on<ShowGetDropAddressEvent>(showGetDropAddressFunc);
    on<GetAutoCompleteAddressEvent>(getAutoCompleteAddress);
    on<ClearAutoCompleteEvent>(clearAutoComplete);
    on<GeocodingAddressEvent>(getLatLngFromAddress);
    on<GetEtaRequestEvent>(etaRequest);
    on<CreateInstantRideEvent>(createInstantRequest);
    on<GetGoodsTypeEvent>(getGoodsType);
    on<ChangeGoodsEvent>(changeGoods);
    on<UploadProofEvent>(uploadProof);
    on<ShowChooseStopEvent>(showCompleteStop);
    on<CompleteStopEvent>(stopComplete);
    on<ShowCarMenuEvent>(showCarMenuFunc);
    on<ChooseCarMenuEvent>(chooseCarMenuFunc);
    on<ChangeMenuEvent>(changeMenuFunc);
    on<EnableBiddingEvent>(enableBiddingFunc);
    on<EnableBubbleEvent>(enableBubbleFunc);
    on<UpdatePricePerDistanceEvent>(updatePricePerDistance);
    on<UpdateReducedTimeEvent>(getWaitingTime);
    on<UpdateOnlineTimeEvent>(updateActiveUserTiming);
    on<NavigationTypeEvent>(navigationTypeFunc);
    on<BiddingIncreaseOrDecreaseEvent>(biddingFareIncreaseDecrease);
    on<ShowoutsationpageEvent>(showOutstationPage);
    on<OutstationSuccessEvent>(outStationSuccess);
    on<GetSubVehicleTypesEvent>(getSubVehicleTypes);
    on<UpdateSubVehiclesTypeEvent>(updateSubVehicleTypes);
  }

  FutureOr<void> getWaitingTime(
      UpdateReducedTimeEvent event, Emitter<HomeState> emit) {
    emit(UpdateReducedTimeState(
        reducedTimeInMinutes: event.reducedTimeInMinutes));
  }

  FutureOr<void> showOutstationPage(
      ShowoutsationpageEvent event, Emitter<HomeState> emit) {
    visibleOutStation = event.isVisible;
    emit(ShowoutsationpageState(isVisible: event.isVisible));
    add(UpdateEvent());
  }

  FutureOr<void> outStationSuccess(
      OutstationSuccessEvent event, Emitter<HomeState> emit) {
    emit(OutstationSuccessState());
  }

  FutureOr<void> getSubVehicleTypes(
      GetSubVehicleTypesEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<HomeUsecase>().getSubVehicleTypes(
        serviceLocationId: event.serviceLocationId,
        vehicleType: event.vehicleType);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(HomeDataLoadingStopState());
      },
      (success) {
        emit(HomeDataLoadingStopState());
        subVehicleTypes = success.data;
        if (subVehicleTypes.isNotEmpty) {
          emit(ShowSubVehicleTypesState());
        } else {
          showToast(message: 'Services Not Available');
        }
      },
    );
  }

  FutureOr<void> updateSubVehicleTypes(
      UpdateSubVehiclesTypeEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<HomeUsecase>()
        .updateVehicleTypesApi(subTypes: event.subTypes);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(HomeDataLoadingStopState());
      },
      (success) {
        emit(HomeDataLoadingStopState());
        showToast(message: 'added successfully');
        final data = UserDetail.fromJson(success["data"]);
        userData = data;
        updateFirebaseData();
      },
    );
  }

  final Bubble _bubble =
      Bubble(showCloseButton: false, allowDragToClose: false);
  Future<void> startBubbleHead() async {
    try {
      updateBgLocation(10);
      if (showBubbleIcon) {
        await _bubble.startBubbleHead(sendAppToBackground: false);
      } else {}
    } on PlatformException {
      debugPrint('Failed to call startBubbleHead');
    }
  }

  void updateBgLocation(duration) {
    for (var i = 0; i < duration; i++) {
      Workmanager().registerPeriodicTask('locs_$i', 'update_locs_$i',
          initialDelay: Duration(minutes: i),
          frequency: Duration(minutes: duration),
          constraints: Constraints(
              networkType: NetworkType.connected,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresDeviceIdle: false,
              requiresStorageNotLow: false),
          inputData: {'id': userData!.id.toString()});
    }
  }

  Future<void> stopBubbleHead() async {
    try {
      Workmanager().cancelAll();
      if (showBubbleIcon) {
        await _bubble.stopBubbleHead();
      }
    } on PlatformException {
      debugPrint('Failed to call stopBubbleHead');
    }
  }

  Future<void> getDirection(
      GetDirectionEvent event, Emitter<HomeState> emit) async {
    vsync = event.vsync;
    lightMapString = await rootBundle.loadString('assets/light.json');
    darkMapString = await rootBundle.loadString('assets/dark.json');
    await Permission.location.request();
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
      add(GetCurrentLocationEvent());
    }
    mapType = await AppSharedPreference.getMapType();
    languageCode = await AppSharedPreference.getSelectedLanguageCode();
    emit(HomeDataSuccessState());
  }

  Future<void> showCompleteStop(
      ShowChooseStopEvent event, Emitter<HomeState> emit) async {
    choosenCompleteStop = null;
    emit(ShowChooseStopsState());
  }

  Future<void> changeMenuFunc(
      ChangeMenuEvent event, Emitter<HomeState> emit) async {
    choosenMenu = event.menu;
    if (choosenMenu == 0) {
      lightMapString = await rootBundle.loadString('assets/light.json');
      darkMapString = await rootBundle.loadString('assets/dark.json');
      googleMapController = null;
    }
    emit(ChangedMenuState());
  }

  Future<void> destinationUpdate(
      DestinationSelectEvent event, Emitter<HomeState> emit) async {
    emit(DestinationSelectState(isPickupChange: event.isPickupChange));
  }

  Future<void> enableBiddingFunc(
      EnableBiddingEvent event, Emitter<HomeState> emit) async {
    isBiddingEnabled = event.isEnabled;
    if (bidRequestStream == null && isBiddingEnabled) {
      streamBidRequest();
    } else if (!isBiddingEnabled ||
        (!isBiddingEnabled && bidRequestStream != null)) {
      bidRequestStream?.cancel();
      bidRequestStream = null;
    }
    AppSharedPreference.setBidSettingStatus(event.isEnabled);
    emit(EnableBiddingSettingsState());
  }

  Future<void> enableBubbleFunc(
      EnableBubbleEvent event, Emitter<HomeState> emit) async {
    showBubbleIcon = event.isEnabled;
    if (await DashBubble.instance.hasOverlayPermission() == true) {
      showBubbleIcon = event.isEnabled;
    } else {
      var val = await DashBubble.instance.requestOverlayPermission();
      if (val == true) {
        showBubbleIcon = event.isEnabled;
      } else {
        showBubbleIcon = false;
      }
    }

    AppSharedPreference.setBubbleSettingStatus(event.isEnabled);
    emit(EnableBubbleSettingsState());
  }

  Future<void> showCarMenuFunc(
      ShowCarMenuEvent event, Emitter<HomeState> emit) async {
    if (showCarMenu) {
      showCarMenu = false;
    } else {
      showCarMenu = true;
    }
    emit(ShowCarMenuState());
  }

  Future<void> chooseCarMenuFunc(
      ChooseCarMenuEvent event, Emitter<HomeState> emit) async {
    choosenCarMenu = event.menu;
    showCarMenu = false;
    streamOwnersDriver();
    emit(ShowCarMenuState());
  }

  Future<void> clearAutoComplete(
      ClearAutoCompleteEvent event, Emitter<HomeState> emit) async {
    autoSuggestionSearching = false;
    autoCompleteAddress.clear();
    dropAddressController.clear();
    sessionToken = null;
    emit(StateChangedState());
    emit(UpdateState());
  }

  Future<void> changeGoods(
      ChangeGoodsEvent event, Emitter<HomeState> emit) async {
    choosenGoods = event.id;
    emit(StateChangedState());
  }

  Future<void> showBidRideFunc(
      ShowBidRideEvent event, Emitter<HomeState> emit) async {
    // showBiddingPage = false;
    choosenRide = event.id;
    bidRideAmount.clear();
    outstationRideAmount.clear();
    if (AppConstants.packageName == '' || AppConstants.signKey == '') {
      var val = await PackageInfo.fromPlatform();
      AppConstants.packageName = val.packageName;
      AppConstants.signKey = val.buildSignature;
    }

    add(PolylineEvent(
        pickLat: event.pickLat,
        pickLng: event.pickLng,
        dropLat: event.dropLat,
        dropLng: event.dropLng,
        stops: event.stops,
        packageName: AppConstants.packageName,
        signKey: AppConstants.signKey,
        pickAddress: event.pickAddress,
        dropAddress: event.dropAddress));
    add(ShowoutsationpageEvent(isVisible: false));
    acceptedRideFare = event.acceptedRideFare;
    emit(ShowBiddingPageState());
  }

  Future<void> removeChoosenRide(
      RemoveChoosenRideEvent event, Emitter<HomeState> emit) async {
    polyline.clear();
    fmpoly.clear();
    markers
        .removeWhere((element) => element.markerId != const MarkerId('my_loc'));
    // showBiddingPage = false;
    choosenRide = null;
    emit(ShowBiddingPageState());
  }

  Future<void> declineBidRide(
      DeclineBidRideEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    await FirebaseDatabase.instance
        .ref('bid-meta')
        .child('${event.id}/drivers/driver_${userData!.id}')
        .update({
      'driver_id': userData!.id,
      'driver_name': userData!.name,
      'driver_img': userData!.profilePicture,
      'bid_time': ServerValue.timestamp,
      'is_rejected': 'by_driver'
    });
    if (outStationList.isNotEmpty) {
      fmpoly.clear();
      polyline.clear();
      outStationList
          .removeWhere((element) => element["request_id"] == event.id);
      if (outStationList.isEmpty) {
        showOutstationWidget = false;
      }
      emit(UpdateState());
    }
    emit(HomeDataLoadingStopState());
  }

  Future<void> acceptBidRide(
      AcceptBidRideEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    await FirebaseDatabase.instance
        .ref('bid-meta')
        .child('${event.id}/drivers/driver_${userData!.id}')
        .update({
      'driver_id': userData!.id,
      'price': bidRideAmount.text.toString().replaceAll(
          (rideList.isNotEmpty)
              ? rideList
                  .firstWhere((e) => e['request_id'] == event.id)['currency']
              : (outStationList.isNotEmpty)
                  ? outStationList.firstWhere(
                      (e) => e['request_id'] == event.id)['currency']
                  : rideList.firstWhere(
                      (e) => e['request_id'] == event.id)['currency'],
          ''),
      // 'price':bidRideAmount.text.toString(),
      'driver_name': userData!.name,
      'driver_img': userData!.profilePicture,
      'bid_time': ServerValue.timestamp,
      'is_rejected': 'none',
      'vehicle_make': userData!.carMake,
      'vehicle_model': userData!.carModel,
      'lat': currentLatLng!.latitude,
      'lng': currentLatLng!.longitude,
      'rating': userData!.rating.toString(),
      'mobile': userData!.mobile
    });
    emit(HomeDataLoadingStopState());
    if (showOutstationWidget == true) {
      if (outStationList.isNotEmpty) {
        fmpoly.clear();
        polyline.clear();
        outStationList
            .removeWhere((element) => element["request_id"] == event.id);
        if (outStationList.isEmpty) {
          showOutstationWidget = false;
        }
        emit(UpdateState());
      }
      showOutstationWidget = false;
      emit(UpdateState());
      emit(OutstationSuccessState());
    }
  }

  Future<void> addReviewFunc(
      AddReviewEvent event, Emitter<HomeState> emit) async {
    if (addReview) {
      addReview = false;
    } else {
      reviewController.clear();
      review = 0;
      addReview = true;
    }
    emit(AddReviewState());
  }

  Future<void> showGetDropAddressFunc(
      ShowGetDropAddressEvent event, Emitter<HomeState> emit) async {
    if (showGetDropAddress) {
      pickAddress = '';
      dropAddress = '';
      pickLatLng = null;
      dropLatLng = null;
      markers.removeWhere(
          (element) => element.markerId != const MarkerId('my_loc'));
      polyline.clear();
      fmpoly.clear();
      if (userData!.transportType == 'both') {
        instantRideType = 'taxi';
      } else {
        instantRideType = null;
      }

      showGetDropAddress = false;
      autoCompleteAddress.clear();
      emit(StateChangedState());
    } else {
      pickAddress = '';
      dropAddress = '';
      add(GeocodingLatLngEvent(
          lat: currentLatLng!.latitude, lng: currentLatLng!.longitude));
    }
  }

  Future<void> showBiddingPageFunc(
      ShowBiddingPageEvent event, Emitter<HomeState> emit) async {
    if (showBiddingPage) {
      showBiddingPage = false;
    } else {
      showBiddingPage = true;
    }
    emit(ShowBiddingPageState());
  }

  Future<void> showOtpFunc(ShowOtpEvent event, Emitter<HomeState> emit) async {
    rideOtp.clear();
    if (showOtp) {
      showOtp = false;
    } else {
      showOtp = true;
    }
    emit(ShowOtpState());
  }

  Future<void> showImagePickFunc(
      ShowImagePickEvent event, Emitter<HomeState> emit) async {
    loadImage = null;
    unloadImage = null;
    if (showImagePick) {
      showImagePick = false;
    } else {
      showImagePick = true;
    }

    emit(ShowImagePickState());
  }

  Future<void> showSignatureFunc(
      ShowSignatureEvent event, Emitter<HomeState> emit) async {
    signaturePoints.clear();
    if (showSignature) {
      showSignature = false;
    } else {
      showSignature = true;
    }
    emit(ShowSignatureState());
  }

  Future<void> signaturePointUpdate(
      UpdateSignEvent event, Emitter<HomeState> emit) async {
    if (event.points == null) {
      signaturePoints.clear();
    } else {
      signaturePoints.add(event.points);
    }
    emit(UpdateSignatureState());
  }

  Future<void> captureImage(
      ImageCaptureEvent event, Emitter<HomeState> emit) async {
    ImagePicker image = ImagePicker();
    XFile? imageFile = await image.pickImage(source: ImageSource.camera);
    if (userData!.onTripRequest == null ||
        userData!.onTripRequest!.isTripStart == 0) {
      loadImage = imageFile!.path;
    } else {
      unloadImage = imageFile!.path;
    }
    emit(ImageCaptureSuccessState());
  }

  Future<void> chooseCancelReason(
      ChooseCancelReasonEvent event, Emitter<HomeState> emit) async {
    choosenCancelReason = event.choosen;
    cancelReasonText.clear();
    emit(ChoosenCancelReasonState());
  }

  Future<void> cancelReasonChoose(
      HideCancelReasonEvent event, Emitter<HomeState> emit) async {
    if (showCancelReason) {
      showCancelReason = false;
    }
    emit(CancelReasonSuccessState());
  }

  Future<void> showChatFunc(
      ShowChatEvent event, Emitter<HomeState> emit) async {
    if (showChat) {
      showChat = false;
    } else {
      showChat = true;
    }
    emit(ShowChatState());
  }

  Future<void> updateDistanceBetween(
      ChangeDistanceEvent event, Emitter<HomeState> emit) async {
    distanceBetween = distanceBetweenList
        .firstWhere((e) => e['name'] == event.distance)['dist'];
    emit(DistanceUpdateState());
    await AppSharedPreference.setDistanceBetween(distanceBetween!);
    streamBidRequest();
  }

  Future<void> changeReview(
      ReviewUpdateEvent event, Emitter<HomeState> emit) async {
    review = event.star;
    emit(ReviewUpdateState());
  }

  // UserDetails
  FutureOr<void> getUserDetails(
      GetUserDetailsEvent event, Emitter<HomeState> emit) async {
    // emit(HomeDataLoadingStartState());
    final data = await serviceLocator<HomeUsecase>().userDetails();
    await data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
        if (event.loading == 1) {
          emit(HomeDataLoadingStopState());
        }
      },
      (success) async {
        if (mapType.isEmpty) {
          mapType = success.data.mapType;
          await AppSharedPreference.setMapType(mapType);
        }
        if (userData == null) {
          var val = await AppSharedPreference.getBidSettingStatus();
          isBiddingEnabled = val;
          var bubble = await AppSharedPreference.getBubbleSettingStatus();
          showBubbleIcon = bubble;
          var subscription =
              await AppSharedPreference.getSubscriptionSkipStatus();
          subscriptionSkip = subscription;
        }
        userData = success.data;
        selectedSubVehicleTypes = userData!.vehicleTypes!;

        if (userData!.enableBidding == true ||
            userData!.enableBidOnFare == true) {
          isBiddingEnabled = true;
          AppSharedPreference.setBidSettingStatus(true);
          streamBidRequest();
        }

        if (userData!.onTripRequest == null && userData!.metaRequest == null) {
          addReview = false;
          showSignature = false;
        }

        if (positionSubscription == null && userData!.role == 'driver') {
          streamLocation();
        }
        if (ownersDriver == null && userData!.role == 'owner') {
          streamOwnersDriver();
        }
        if (userData!.serviceLocationId != null &&
            userData!.uploadedDocument == true &&
            userData!.approve == true) {
          addReview = false;
          if (userData!.onTripRequest == null) {
            if (choosenCompleteStop != null) {
              choosenCompleteStop = null;
            }
            if (showChat == true) {
              showChat = false;
            }
            if (chats.isNotEmpty) {
              chats.clear();
            }
            if (showOtp) {
              showOtp = false;
            }
            if (showImagePick) {
              showImagePick = false;
            }
            if (showSignature) {
              showSignature = false;
            }

            waitingTimeBeforeStart = 0;
            waitingTimeAfterStart = 0;

            distance = 0.0;
          }
          if (userData!.metaRequest != null && searchTimer == null) {
            timer = userData!.acceptDuration;
            // rideSearchTimer();
            rideSearchTimer();
          } else if (userData!.metaRequest == null && searchTimer != null) {
            searchTimer?.cancel();
            searchTimer = null;
          }
          if (userData!.metaRequest != null && choosenMenu != 0) {
            choosenMenu = 0;
          }
          if (userData!.onTripRequest != null &&
              userData!.onTripRequest!.arrivedAt != null &&
              waitingTimer == null &&
              userData!.onTripRequest!.isBidRide == "0") {
            waitingTime();
          } else if (userData!.onTripRequest != null) {
            var val = await FirebaseDatabase.instance
                .ref('requests/${userData!.onTripRequest!.id}')
                .get();

            if (val.child('distance').value != null) {
              distance = double.parse(val.child('distance').value.toString());
            }
          }
          if (userData!.onTripRequest == null && waitingTimer != null) {
            waitingTimer?.cancel();
            waitingTimer = null;
          }
          if (userData!.onTripRequest == null) {
            if (showCancelReason) {
              showCancelReason = false;
            }
            if (showChat) {
              showChat = false;
              chats.clear();
            }
          }
          if (userData!.onTripRequest == null && rideStream != null) {
            rideAddStream?.cancel();
            rideAddStream = null;
            rideStream?.cancel();
            rideStream = null;
          }
          if (userData!.onTripRequest != null && rideStream == null) {
            streamRide();
            var val = await FirebaseDatabase.instance
                .ref('requests/${userData!.onTripRequest!.id}')
                .get();
            if (val.child('lat_lng_array').value != null) {
              latlngArray =
                  jsonDecode(jsonEncode(val.child('lat_lng_array').value));
              latlngArray.add({
                "lat": currentLatLng!.latitude,
                'lng': currentLatLng!.longitude
              });
            }
          }
          if ((userData!.metaRequest == null &&
                  userData!.onTripRequest == null) &&
              (polyline.isNotEmpty ||
                  fmpoly.isNotEmpty ||
                  markers
                      .where((element) =>
                          element.markerId != const MarkerId('my_loc'))
                      .isNotEmpty)) {
            polyline.clear();
            fmpoly.clear();
            markers.removeWhere(
                (element) => element.markerId != const MarkerId('my_loc'));
          }
          if (userData!.active == true &&
              userData!.available == true &&
              userData!.metaRequest == null &&
              userData!.onTripRequest == null) {
            if (requestStream == null) {
              streamRequest();
            }
            if (bidRequestStream == null && isBiddingEnabled) {
              streamBidRequest();
            }
            updateFirebaseData();
          } else if ((userData!.active == false ||
              userData!.available == false)) {
            if (requestStream != null) {
              requestStream!.cancel();
              requestStream = null;
            }
            if (bidRequestStream != null) {
              bidRequestStream!.cancel();
              bidRequestStream = null;
            }
            updateFirebaseData();
          }
          if (userData!.onTripRequest != null && showBiddingPage == true) {
            showBiddingPage = false;
          }

          if ((userData!.onTripRequest != null ||
                  userData!.metaRequest != null) &&
              polyline.isEmpty &&
              (userData!.onTripRequest == null ||
                  userData!.onTripRequest!.isCompleted == 0)) {
            if (AppConstants.packageName == '' || AppConstants.signKey == '') {
              var val = await PackageInfo.fromPlatform();
              AppConstants.packageName = val.packageName;
              AppConstants.signKey = val.buildSignature;
            }
            // Meta Request =================================================>
            if (userData!.metaRequest != null &&
                polyline.isEmpty &&
                userData!.metaRequest!.dropAddress != null) {
              if (userData!.metaRequest!.polyline != null &&
                  userData!.metaRequest!.polyline!.isNotEmpty) {
                markers.removeWhere(
                    (element) => element.markerId != const MarkerId('my_loc'));
                markers.add(Marker(
                  markerId: const MarkerId("pick"),
                  position: LatLng(userData!.metaRequest!.pickLat,
                      userData!.metaRequest!.pickLng),
                  icon: await Image.asset(
                    AppImages.pickupIcon,
                    height: 30,
                    width: 30,
                    fit: BoxFit.contain,
                  ).toBitmapDescriptor(
                    logicalSize: const Size(30, 30),
                    imageSize: const Size(200, 200),
                  ),
                ));
                if (userData!.metaRequest!.requestStops.isEmpty &&
                    (userData!.metaRequest!.dropAddress != null &&
                        userData!.metaRequest!.dropAddress != "")) {
                  markers.add(Marker(
                    markerId: const MarkerId("drop"),
                    position: LatLng(userData!.metaRequest!.dropLat!,
                        userData!.metaRequest!.dropLng!),
                    icon: await Directionality(
                        textDirection: TextDirection.ltr,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                        )).toBitmapDescriptor(
                      logicalSize: const Size(30, 30),
                      imageSize: const Size(200, 200),
                    ),
                  ));
                } else if (userData!.metaRequest!.requestStops.isNotEmpty) {
                  for (var i = 0;
                      i < userData!.metaRequest!.requestStops.length;
                      i++) {
                    markers.add(Marker(
                      markerId: MarkerId("drop$i"),
                      position: LatLng(
                          userData!.metaRequest!.requestStops[i]['latitude'],
                          userData!.metaRequest!.requestStops[i]['longitude']),
                      icon:
                          (i == userData!.metaRequest!.requestStops.length - 1)
                              ? await Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                  )).toBitmapDescriptor(
                                  logicalSize: const Size(30, 30),
                                  imageSize: const Size(200, 200),
                                )
                              : await Image.asset(
                                  (i == 0)
                                      ? AppImages.stopOne
                                      : (i == 1)
                                          ? AppImages.stopTwo
                                          : (i == 2)
                                              ? AppImages.stopThree
                                              : AppImages.stopFour,
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.contain,
                                ).toBitmapDescriptor(
                                  logicalSize: const Size(30, 30),
                                  imageSize: const Size(200, 200),
                                ),
                    ));
                  }
                }
                mapBound(
                    userData!.metaRequest!.pickLat,
                    userData!.metaRequest!.pickLng,
                    userData!.metaRequest!.dropLat!,
                    userData!.metaRequest!.dropLng!,
                    userData!.metaRequest!.requestStops);
                decodeEncodedPolyline(userData!.metaRequest!.polyline!);
              } else {
                add(PolylineEvent(
                    pickLat: userData!.metaRequest!.pickLat,
                    pickLng: userData!.metaRequest!.pickLng,
                    dropLat: userData!.metaRequest!.dropLat!,
                    dropLng: userData!.metaRequest!.dropLng!,
                    stops: userData!.metaRequest!.requestStops,
                    packageName: AppConstants.packageName,
                    signKey: AppConstants.signKey,
                    pickAddress: userData!.metaRequest!.pickAddress,
                    dropAddress: userData!.metaRequest!.dropAddress ?? ''));
              }
              // OnTrip Request =================================================>
            } else if (polyline.isEmpty &&
                userData!.onTripRequest != null &&
                userData!.onTripRequest!.dropAddress != null) {
              add(GetRideChatEvent());
              if (userData!.onTripRequest!.polyline != null &&
                  userData!.onTripRequest!.polyline!.isNotEmpty &&
                  (userData!.onTripRequest!.arrivedAt != null &&
                      userData!.onTripRequest!.arrivedAt != "")) {
                mapBound(
                    userData!.onTripRequest!.pickLat,
                    userData!.onTripRequest!.pickLng,
                    userData!.onTripRequest!.dropLat!,
                    userData!.onTripRequest!.dropLng!,
                    userData!.onTripRequest!.requestStops);
                decodeEncodedPolyline(userData!.onTripRequest!.polyline!);
                markers.removeWhere(
                    (element) => element.markerId != const MarkerId('my_loc'));
                markers.add(Marker(
                  markerId: const MarkerId("pick"),
                  position: LatLng(userData!.onTripRequest!.pickLat,
                      userData!.onTripRequest!.pickLng),
                  icon: await Image.asset(
                    AppImages.pickupIcon,
                    height: 30,
                    width: 30,
                    fit: BoxFit.contain,
                  ).toBitmapDescriptor(
                    logicalSize: const Size(30, 30),
                    imageSize: const Size(200, 200),
                  ),
                ));
                if (userData!.onTripRequest!.requestStops.isEmpty &&
                    (userData!.onTripRequest!.dropAddress != null &&
                        userData!.onTripRequest!.dropAddress != "")) {
                  markers.add(Marker(
                    markerId: const MarkerId("drop"),
                    position: LatLng(userData!.onTripRequest!.dropLat!,
                        userData!.onTripRequest!.dropLng!),
                    icon: await Directionality(
                        textDirection: TextDirection.ltr,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                        )).toBitmapDescriptor(
                      logicalSize: const Size(30, 30),
                      imageSize: const Size(200, 200),
                    ),
                  ));
                } else if (userData!.onTripRequest!.requestStops.isNotEmpty) {
                  for (var i = 0;
                      i < userData!.onTripRequest!.requestStops.length;
                      i++) {
                    markers.add(Marker(
                      markerId: MarkerId("drop$i"),
                      position: LatLng(
                          userData!.onTripRequest!.requestStops[i]['latitude'],
                          userData!.onTripRequest!.requestStops[i]
                              ['longitude']),
                      icon: (i ==
                              userData!.onTripRequest!.requestStops.length - 1)
                          ? await Directionality(
                              textDirection: TextDirection.ltr,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                              )).toBitmapDescriptor(
                              logicalSize: const Size(30, 30),
                              imageSize: const Size(200, 200),
                            )
                          : await Image.asset(
                              (i == 0)
                                  ? AppImages.stopOne
                                  : (i == 1)
                                      ? AppImages.stopTwo
                                      : (i == 2)
                                          ? AppImages.stopThree
                                          : AppImages.stopFour,
                              height: 30,
                              width: 30,
                              fit: BoxFit.contain,
                            ).toBitmapDescriptor(
                              logicalSize: const Size(30, 30),
                              imageSize: const Size(200, 200),
                            ),
                    ));
                  }
                }
                if (userData!.onTripRequest != null &&
                    (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.arrivedAt != "")) {
                  if (userData!.onTripRequest!.isTripStart != 1) {
                    FirebaseDatabase.instance
                        .ref('requests')
                        .child(userData!.onTripRequest!.id)
                        .update({
                      'polyline': userData!.onTripRequest!.polyline,
                      'distance': (double.parse(
                              userData!.onTripRequest!.totalDistance) *
                          1000),
                      'duration': userData!.onTripRequest!.totalTime
                    });
                    await addDistanceMarker(
                        LatLng(userData!.onTripRequest!.dropLat!,
                            userData!.onTripRequest!.dropLng!),
                        (double.parse(userData!.onTripRequest!.totalDistance) *
                            1000),
                        time: double.parse(
                            userData!.onTripRequest!.totalTime.toString()));
                  } else {
                    double minPerDistance = double.parse(
                            userData!.onTripRequest!.totalTime.toString()) /
                        double.parse(userData!.onTripRequest!.totalDistance);
                    double dist = calculateDistance(
                        lat1: currentLatLng!.latitude,
                        lon1: currentLatLng!.longitude,
                        lat2: userData!.onTripRequest!.dropLat!,
                        lon2: userData!.onTripRequest!.dropLng!);
                    final dist1 = calculateDistance(
                        lat1: userData!.onTripRequest!.pickLat,
                        lon1: userData!.onTripRequest!.pickLng,
                        lat2: currentLatLng!.latitude,
                        lon2: currentLatLng!.longitude);
                    final calDuration = double.parse(
                            userData!.onTripRequest!.totalTime.toString()) -
                        ((dist1 / 1000) * minPerDistance);
                    FirebaseDatabase.instance
                        .ref('requests')
                        .child(userData!.onTripRequest!.id)
                        .update({'distance': dist, 'duration': calDuration});
                    await addDistanceMarker(
                        LatLng(userData!.onTripRequest!.dropLat!,
                            userData!.onTripRequest!.dropLng!),
                        dist,
                        time: calDuration);
                  }
                  add(UpdateEvent());
                }
              } else if (userData!.onTripRequest!.arrivedAt == null ||
                  userData!.onTripRequest!.arrivedAt == "") {
                add(PolylineEvent(
                    pickLat: currentLatLng!.latitude,
                    pickLng: currentLatLng!.longitude,
                    dropLat: userData!.onTripRequest!.pickLat,
                    dropLng: userData!.onTripRequest!.pickLng,
                    stops: [],
                    packageName: AppConstants.packageName,
                    signKey: AppConstants.signKey,
                    pickAddress: userData!.onTripRequest!.pickAddress,
                    dropAddress: userData!.onTripRequest!.dropAddress ?? ''));
              } else {
                add(PolylineEvent(
                    pickLat: userData!.onTripRequest!.pickLat,
                    pickLng: userData!.onTripRequest!.pickLng,
                    dropLat: userData!.onTripRequest!.dropLat!,
                    dropLng: userData!.onTripRequest!.dropLng!,
                    stops: userData!.onTripRequest!.requestStops,
                    packageName: AppConstants.packageName,
                    signKey: AppConstants.signKey,
                    pickAddress: userData!.onTripRequest!.pickAddress,
                    dropAddress: userData!.onTripRequest!.dropAddress ?? ''));
              }
              // RideWithout Destination =======================================>
            } else if (((userData!.onTripRequest != null &&
                        userData!.onTripRequest!.dropAddress == null) ||
                    (userData!.metaRequest != null &&
                        polyline.isEmpty &&
                        userData!.metaRequest!.dropAddress == null)) &&
                markers
                    .where((e) => e.markerId == const MarkerId("pick"))
                    .isEmpty) {
              markers.add(
                Marker(
                  markerId: const MarkerId("pick"),
                  position: (userData!.onTripRequest != null)
                      ? LatLng(userData!.onTripRequest!.pickLat,
                          userData!.onTripRequest!.pickLng)
                      : LatLng(userData!.metaRequest!.pickLat,
                          userData!.metaRequest!.pickLng),
                  icon: await Image.asset(
                    AppImages.pickupIcon,
                    height: 30,
                    width: 30,
                    fit: BoxFit.contain,
                  ).toBitmapDescriptor(
                    logicalSize: const Size(30, 30),
                    imageSize: const Size(200, 200),
                  ),
                ),
              );

              googleMapController!.animateCamera(CameraUpdate.newLatLng(
                  (userData!.onTripRequest != null)
                      ? LatLng(userData!.onTripRequest!.pickLat,
                          userData!.onTripRequest!.pickLng)
                      : LatLng(userData!.metaRequest!.pickLat,
                          userData!.metaRequest!.pickLng)));
            }
          }
        } else {
          vehicleNotUpdated = true;
          // emit(UpdateState());
        }
        emit(UserDetailsSuccessState());
        if (event.loading == 1) {
          emit(HomeDataLoadingStopState());
        }
      },
    );
  }

  // Accept reject
  FutureOr<void> uploadProof(
      UploadProofEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    searchTimer?.cancel();
    searchTimer = null;

    final data = await serviceLocator<RideUsecases>().uploadProof(
        proofImage: event.image, isBefore: event.isBefore, id: event.id);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        }
        timer = userData!.acceptDuration;
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        if (signatureImage != null) {
          if (userData!.onTripRequest!.requestStops.isNotEmpty &&
              userData!.onTripRequest!.requestStops
                      .where((e) => e['completed_at'] == null)
                      .length >
                  1) {
            signatureImage = null;
            showSignature = false;
            showImagePick = false;
            showOtp = false;
            add(CompleteStopEvent(id: choosenCompleteStop!));
          } else {
            add(GeocodingLatLngEvent(
                lat: currentLatLng!.latitude, lng: currentLatLng!.longitude));
            signatureImage = null;
          }
        } else if (unloadImage != null) {
          if (userData!.onTripRequest!.enableDigitalSignature == '1') {
            add(ShowSignatureEvent());
          } else {
            if (userData!.onTripRequest!.requestStops.isNotEmpty &&
                userData!.onTripRequest!.requestStops
                        .where((e) => e['completed_at'] == null)
                        .length >
                    1) {
              showImagePick = false;
              showOtp = false;
              add(CompleteStopEvent(id: choosenCompleteStop!));
            } else {
              add(GeocodingLatLngEvent(
                  lat: currentLatLng!.latitude, lng: currentLatLng!.longitude));
            }
            add(GeocodingLatLngEvent(
                lat: currentLatLng!.latitude, lng: currentLatLng!.longitude));
          }
          unloadImage = null;
        } else if (loadImage != null) {
          if (userData!.onTripRequest!.isTripStart == 0) {
            add(RideStartEvent(
                requestId: userData!.onTripRequest!.id,
                otp: rideOtp.text,
                pickLat: currentLatLng!.latitude,
                pickLng: currentLatLng!.longitude));
          }
          showImagePick = false;
          loadImage = null;
        }
      },
    );
    emit(HomeDataLoadingStopState());
  }

  // Accept reject
  FutureOr<void> stopComplete(
      CompleteStopEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<RideUsecases>().stopComplete(
      id: event.id,
    );
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(HomeDataLoadingStopState());
      },
      (success) {
        userData!.onTripRequest!.requestStops.firstWhere((e) =>
                e['id'].toString() == choosenCompleteStop)['completed_at'] =
            DateTime.now().toString();
        choosenCompleteStop = null;
        emit(HomeDataLoadingStopState());
      },
    );
  }

  // Accept reject
  FutureOr<void> respondRequest(
      AcceptRejectEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    isLoading = true;
    searchTimer?.cancel();
    searchTimer = null;
    // textDirection = await AppSharedPreference.getLanguageDirection();

    final data = await serviceLocator<RideUsecases>()
        .respondRequest(requestId: event.requestId, status: event.status);
    data.fold(
      (error) {
        timer = userData!.acceptDuration;
        if (error.statusCode == 500 ||
            error.message == "request already cancelled") {
          userData!.metaRequest = null;
          polyline.clear();
          fmpoly.clear();
          latlngArray.clear();
          distance = 0.0;
          waitingTimeBeforeStart = 0;
          waitingTimeAfterStart = 0;
          updateFirebaseData();
          isLoading = false;
          add(GetUserDetailsEvent());
        }
        isLoading = false;
        emit(HomeDataLoadingStopState());
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        if (event.status == 1) {
          userData!.onTripRequest = success.data;
          userData!.metaRequest = null;
          polyline.clear();
          fmpoly.clear();
          latlngArray.clear();
          distance = 0.0;
          waitingTimeBeforeStart = 0;
          waitingTimeAfterStart = 0;
          updateFirebaseData();
          isLoading = false;
          add(GetUserDetailsEvent());
        } else {
          userData!.metaRequest = null;
          polyline.clear();
          fmpoly.clear();
          emit(UpdateState());
        }
        emit(HomeDataLoadingStopState());
        emit(UpdateState());
      },
    );
  }

  // ride arrived
  FutureOr<void> rideArrived(
      RideArrivedEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<RideUsecases>().rideArrived(
      requestId: event.requestId,
    );
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(HomeDataLoadingStopState());
      },
      (success) async {
        FirebaseDatabase.instance.ref('requests').child(event.requestId).update(
            {'trip_arrived': '1', 'modified_by_driver': ServerValue.timestamp});
        polyline.clear();
        fmpoly.clear();

        // add(GetUserDetailsEvent());

        add(GetUserDetailsEvent(loading: 1));
        if (userData!.onTripRequest!.isBidRide == "0") {
          waitingTime();
        }
      },
    );
    // emit(HomeDataLoadingStopState());
  }

  // ride arrived
  FutureOr<void> cancelRequest(
      CancelRequestEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<RideUsecases>().cancelRequest(
        requestId: userData!.onTripRequest!.id,
        reason: (cancelReasonText.text.isNotEmpty)
            ? cancelReasonText.text
            : cancelReasons[choosenCancelReason!].reason);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(HomeDataLoadingStopState());
      },
      (success) async {
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({'cancelled_by_driver': true, 'is_cancelled': true});
        // await getUserDetails(GetUserDetailsEvent(), emit);
        add(HideCancelReasonEvent());
        add(GetUserDetailsEvent(loading: 1));
      },
    );
    // emit(HomeDataLoadingStopState());
  }

  // get ride chats
  FutureOr<void> getRideChats(
      GetRideChatEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<RideUsecases>().getRideChat(
      requestId: userData!.onTripRequest!.id,
    );
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        chats = success.chats;
        emit(RideChatSuccessState());
      },
    );
  }

  // get cancel reason
  FutureOr<void> getCancelReason(
      GetCancelReasonEvent event, Emitter<HomeState> emit) async {
    cancelReasons.clear();
    emit(HomeDataLoadingStartState());
    final data = await serviceLocator<RideUsecases>().getCancelReason(
        transportType: userData!.onTripRequest!.transportType,
        arrived:
            userData!.onTripRequest!.arrivedAt == null ? 'before' : 'after');
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        choosenCancelReason = null;
        cancelReasons = success.data;
        showCancelReason = true;

        emit(CancelReasonSuccessState());
      },
    );
    emit(HomeDataLoadingStopState());
  }

  // chats seen
  FutureOr<void> chatSeen(ChatSeenEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<RideUsecases>().chatSeen(
      requestId: userData!.onTripRequest!.id,
    );
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        chats.where((e) => e['seen'] == 0).forEach((v) {
          v['seen'] = 1;
        });

        emit(RideChatSuccessState());
      },
    );
  }

  // send chat
  FutureOr<void> sendChat(SendChatEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    final data = await serviceLocator<RideUsecases>().sendChat(
        requestId: userData!.onTripRequest!.id, message: chatField.text);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(HomeDataLoadingStopState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({'message_by_driver': chats.length + 1});
        chatField.clear();
        add(GetRideChatEvent());
        emit(HomeDataLoadingStopState());
        emit(RideChatSuccessState());
      },
    );
  }

  // ride start
  FutureOr<void> getGoodsType(
      GetGoodsTypeEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    if (goodsList.isEmpty) {
      final data = await serviceLocator<RideUsecases>().getGoodsType();
      data.fold(
        (error) {
          if (error.statusCode == 401) {
            AppSharedPreference.remove('login');
            AppSharedPreference.remove('token');
            emit(UserUnauthenticatedState());
          } else {
            emit(ShowErrorState(message: error.message.toString()));
          }
        },
        (success) {
          goodsList = success.goods;
        },
      );
    }
    goodsSizeText.clear();
    goodsSize = 'Loose';
    choosenGoods = null;
    emit(HomeDataLoadingStopState());
    emit(GetGoodsSuccessState());
  }

  // ride start
  FutureOr<void> rideStart(
      RideStartEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<RideUsecases>().rideStart(
        requestId: event.requestId,
        otp: event.otp,
        pickLat: event.pickLat,
        pickLng: event.pickLng);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(HomeDataLoadingStopState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) async {
        showOtp = false;
        showImagePick = false;
        audioPlayer.play(AssetSource(AppAudios.started));
        FirebaseDatabase.instance.ref('requests').child(event.requestId).update(
            {'trip_start': '1', 'modified_by_driver': ServerValue.timestamp});
        // add(GetUserDetailsEvent());
        add(GetUserDetailsEvent(loading: 1));
      },
    );
    // emit(HomeDataLoadingStopState());
  }

  // ride end
  FutureOr<void> rideEnd(RideEndEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    final data = await serviceLocator<RideUsecases>().rideEnd(
      requestId: userData!.onTripRequest!.id,
      distance: (distance == 0 || distance == 0.0)
          ? distance
          : double.parse((distance / 1000).toStringAsFixed(2)),
      dropLat: (userData!.onTripRequest!.isRental == false &&
              userData!.onTripRequest!.isOutstation != 1 &&
              userData!.onTripRequest!.dropAddress != null)
          ? userData!.onTripRequest!.dropLat!
          : currentLatLng!.latitude,
      dropLng: (userData!.onTripRequest!.isRental == false &&
              userData!.onTripRequest!.isOutstation != 1 &&
              userData!.onTripRequest!.dropAddress != null)
          ? userData!.onTripRequest!.dropLng!
          : currentLatLng!.longitude,
      dropAddress: (userData!.onTripRequest!.isRental == false &&
              userData!.onTripRequest!.isOutstation != 1 &&
              userData!.onTripRequest!.dropAddress != null)
          ? userData!.onTripRequest!.dropAddress!
          : dropAddress,
      beforeTripStartWaitingTime:
          (int.parse((waitingTimeBeforeStart / 60).toStringAsFixed(0)) >
                  userData!.onTripRequest!.freeWaitingTimeBeforeStart)
              ? int.parse((waitingTimeBeforeStart / 60).toStringAsFixed(0)) -
                  userData!.onTripRequest!.freeWaitingTimeBeforeStart
              : 0,
      afterTripStartWaitingTime:
          (int.parse((waitingTimeBeforeStart / 60).toStringAsFixed(0)) >
                  userData!.onTripRequest!.freeWaitingTimeAfterStart)
              ? int.parse((waitingTimeAfterStart / 60).toStringAsFixed(0)) -
                  userData!.onTripRequest!.freeWaitingTimeAfterStart
              : 0,
      polyString: polyString,
    );
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(HomeDataLoadingStopState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) async {
        audioPlayer.play(AssetSource(AppAudios.ended));
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({
          'is_completed':
              userData!.onTripRequest!.isCompleted == 0 ? false : true,
          'modified_by_driver': ServerValue.timestamp
        });
        addReview = false;
        add(GetUserDetailsEvent(loading: 1));
      },
    );
  }

//  Locations
  Future<void> getCurrentLocation(
      GetCurrentLocationEvent event, Emitter<HomeState> emit) async {
    await Permission.location.request();
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double long = position.longitude;

      if (!isClosed) {
        add(UpdateLocationEvent(latLng: LatLng(lat, long)));
      }

      if (currentPosition == null) {
        currentPositionUpdate();
      }
    } else {
      showToast(
          message: 'allow location permission to get your current location');
      emit(GetLocationPermissionState());
    }
  }

  Future<void> updateLocation(
      UpdateLocationEvent event, Emitter<HomeState> emit) async {
    currentLatLng = event.latLng;
    initialCameraPosition = CameraPosition(target: currentLatLng!, zoom: 15);

    if (userData != null && userData!.role == 'driver') {
      final BitmapDescriptor bikeMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.bikeOffline);

      final BitmapDescriptor carMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.car);

      final BitmapDescriptor autoMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.auto);

      final BitmapDescriptor truckMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.truck);

      final BitmapDescriptor ehcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.ehcv);

      final BitmapDescriptor hatchBack = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.hatchBack);

      final BitmapDescriptor hcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.hcv);

      final BitmapDescriptor lcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.lcv);

      final BitmapDescriptor mcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.mcv);

      final BitmapDescriptor luxury = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.luxury);

      final BitmapDescriptor premium = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.premium);

      final BitmapDescriptor suv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.suv);

      vehicleMarker ??= (userData!.vehicleTypeIcon == 'truck')
          ? truckMarker
          : (userData!.vehicleTypeIcon == 'motor_bike')
              ? bikeMarker
              : (userData!.vehicleTypeIcon == 'auto')
                  ? autoMarker
                  : (userData!.vehicleTypeIcon == 'lcv')
                      ? lcv
                      : (userData!.vehicleTypeIcon == 'ehcv')
                          ? ehcv
                          : (userData!.vehicleTypeIcon == 'hatchback')
                              ? hatchBack
                              : (userData!.vehicleTypeIcon == 'hcv')
                                  ? hcv
                                  : (userData!.vehicleTypeIcon == 'mcv')
                                      ? mcv
                                      : (userData!.vehicleTypeIcon == 'luxury')
                                          ? luxury
                                          : (userData!.vehicleTypeIcon ==
                                                  'premium')
                                              ? premium
                                              : (userData!.vehicleTypeIcon ==
                                                      'suv')
                                                  ? suv
                                                  : carMarker;

      // Remove previous marker if exists
      markers.removeWhere(
          (element) => element.markerId == const MarkerId('my_loc'));
      markers.add(Marker(
          markerId: const MarkerId('my_loc'),
          position: currentLatLng!,
          // infoWindow: const InfoWindow(title: 'Pickup Location'),
          icon: vehicleMarker!,
          anchor: const Offset(0.5, 0.5)));
    } else {}

    // You can also animate the camera to the new position
    if (googleMapController != null) {
      googleMapController
          ?.animateCamera(CameraUpdate.newLatLng(currentLatLng!));
    }

    emit(UpdateLocationState());
  }

  currentPositionUpdate() async {
    currentPosition?.cancel();
    LatLng? recentLocs;
    DateTime? updateTime;
    updateFirebaseData();
    currentPosition = Timer.periodic(const Duration(seconds: 5), (val) {
      if (userData != null &&
          userData!.active == true &&
          (userData!.available == true || userData!.available == false)) {
        if (currentLatLng != null && currentLatLng! != recentLocs) {
          recentLocs = currentLatLng!;
          updateTime = DateTime.now();
          updateFirebaseData();
        } else {
          if (updateTime != null &&
              DateTime.now().difference(updateTime!).inSeconds > 30) {
            updateTime = DateTime.now();
            updateFirebaseData();
          }
          // recentLocs = currentLatLng!;
        }
      }
    });
  }

  waitingTime() async {
    waitingTimer?.cancel();
    LatLng? lastLatLng;
    var val = await FirebaseDatabase.instance
        .ref('requests/${userData!.onTripRequest!.id}')
        .get();
    if (val.child('waiting_time_before_start').value != null) {
      waitingTimeBeforeStart =
          int.parse(val.child('waiting_time_before_start').value.toString());
    }
    if (val.child('distance').value != null) {
      distance = double.parse(val.child('distance').value.toString());
    }
    if (val.child('waiting_time_after_start').value != null) {
      waitingTimeAfterStart =
          int.parse(val.child('waiting_time_after_start').value.toString());
    }
    if (val.child('lat_lng_array').value != null) {
      latlngArray = jsonDecode(jsonEncode(val.child('lat_lng_array').value));
      latlngArray.add(
          {"lat": currentLatLng!.latitude, 'lng': currentLatLng!.longitude});
    }
    add(WaitingTimeEvent());
    waitingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (userData!.onTripRequest!.isTripStart == 0) {
        waitingTimeBeforeStart += 60;
        updateFirebaseData();
        add(WaitingTimeEvent());
      } else {
        if (lastLatLng == null && currentLatLng != null) {
          lastLatLng = currentLatLng;
        } else if (currentLatLng == lastLatLng && currentLatLng != null) {
          waitingTimeAfterStart += 60;
          updateFirebaseData();
          add(WaitingTimeEvent());
        } else if (currentLatLng != null) {
          lastLatLng = currentLatLng;
        }
      }
    });
  }

  FutureOr<void> waitingTimerEmit(
      WaitingTimeEvent event, Emitter<HomeState> emit) async {
    emit(RideUpdateState());
  }

  audioPlay() {
    audioPlayer.play(AssetSource(AppAudios.requestSound));
  }

  rideTimerUpdate(RequestTimerEvent event, Emitter<HomeState> emit) async {
    emit(SearchTimerUpdateStatus());
  }

  rideSearchTimer() async {
    searchTimer?.cancel();
    if (waitingList.isEmpty) {
      searchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        timer--;
        if (audioPlayer.state != PlayerState.playing) {
          audioPlay();
        }
        add(RequestTimerEvent());
      });
    } else {
      searchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (waitingList.isNotEmpty && !showOutstationWidget) {
          var val = DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(waitingList[0]
                  ['drivers']['driver_${userData!.id}']['bid_time']))
              .inSeconds;
          if (int.parse(val.toString()) >=
              int.parse(userData!.maximumTimeForFindDriversForBittingRide)) {
            searchTimer?.cancel();
            searchTimer = null;
            Future.delayed(const Duration(seconds: 2), () {
              if (userData!.onTripRequest == null) {
                FirebaseDatabase.instance
                    .ref()
                    .child(
                        'bid-meta/${waitingList[0]["request_id"]}/drivers/driver_${userData!.id}')
                    .update({"is_rejected": 'by_user'});
              }
            });
          }
          add(RequestTimerEvent());
          // respondRequest(AcceptRejectEvent(requestId: userData!.metaRequest!.id, status: 0),HomeState);
        }
      });
    }
  }

  updateFirebaseData() async {
    try {
      FirebaseDatabase.instance
          .ref()
          .child('drivers/driver_${userData!.id}')
          .update({
        'bearing': 0,
        'date': DateTime.now().toString(),
        'id': userData!.id,
        'g': geo.encode(currentLatLng!.longitude, currentLatLng!.latitude),
        'is_active': userData!.active == true ? 1 : 0,
        'profile_picture': userData!.profilePicture,
        'rating': userData!.rating,
        'is_available': userData!.available == true ? true : false,
        'l': {'0': currentLatLng!.latitude, '1': currentLatLng!.longitude},
        'mobile': userData!.mobile,
        'name': userData!.name,
        'vehicle_type_icon': userData!.vehicleTypeIcon,
        'updated_at': ServerValue.timestamp,
        'vehicle_number': userData!.carNumber,
        'vehicle_type_name': userData!.carMake,
        'vehicle_types': userData!.vehicleTypes,
        'ownerid': userData!.ownerId,
        'service_location_id': userData!.serviceLocationId,
        'transport_type': userData!.transportType
      });
      if (userData!.onTripRequest != null &&
          userData!.onTripRequest!.isCompleted == 0) {
       
        if (userData!.onTripRequest!.tripStartTime != null) {
          if (latlngArray.isNotEmpty &&
              (currentLatLng!.latitude !=
                      latlngArray[latlngArray.length - 1]['lat'] ||
                  currentLatLng!.longitude !=
                      latlngArray[latlngArray.length - 1]['lng'])) {
            var dist = await calculateDistance(
                lat1: latlngArray[latlngArray.length - 1]['lat'],
                lon1: latlngArray[latlngArray.length - 1]['lng'],
                lat2: currentLatLng!.latitude,
                lon2: currentLatLng!.longitude);
            latlngArray.add({
              "lat": currentLatLng!.latitude,
              'lng': currentLatLng!.longitude
            });
            distance = distance + dist;
          } else if (latlngArray.isEmpty) {
            latlngArray.add({
              "lat": currentLatLng!.latitude,
              'lng': currentLatLng!.longitude
            });
          }
        }

        FirebaseDatabase.instance
            .ref()
            .child('requests/${userData!.onTripRequest!.id}')
            .update({
          // 'distance': distance / 1000,
          'driver_id': userData!.id,
          'lat': currentLatLng!.latitude,
          'lng': currentLatLng!.longitude,
          'name': userData!.name,
          'profile_picture': userData!.profilePicture,
          'rating': userData!.rating,
          'lat_lng_array': latlngArray,
          'request_id': userData!.onTripRequest!.id,
          'vehicle_type_icon': userData!.vehicleTypeIcon,
          'transport_type': userData!.transportType,
          'waiting_time_before_start': waitingTimeBeforeStart,
          'waiting_time_after_start': waitingTimeAfterStart
        });
      }
      add(UpdateEvent());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ride arrived
  FutureOr<void> getAddressFromLatLng(
      GeocodingLatLngEvent event, Emitter<HomeState> emit) async {
    dropAddress = '';
    emit(HomeDataLoadingStartState());
    if (AppConstants.packageName == '' || AppConstants.signKey == '') {
      var val = await PackageInfo.fromPlatform();
      AppConstants.packageName = val.packageName;
      AppConstants.signKey = val.buildSignature;
    }
    List<Placemark>? address = await GeocodingPlatform.instance
        ?.placemarkFromCoordinates(event.lat, event.lng);
    if (address != null) {
      dropAddress =
          '${(!address[0].street!.contains('+') || !address[0].street!.contains(RegExp(r'[0-9]'))) ? address[0].street : ''} ${(address[0].subLocality!.contains(address[0].locality!)) ? '' : address[0].subLocality} ${address[0].locality} ${address[0].administrativeArea}, ${address[0].country}';
    }

    dropLatLng = LatLng(event.lat, event.lng);
    if (userData!.onTripRequest != null) {
      add(RideEndEvent());
    } else {
      if (pickAddress == '') {
        pickAddress = dropAddress;
        pickLatLng = LatLng(event.lat, event.lng);
      }
      showGetDropAddress = true;
      emit(StateChangedState());
    }
    emit(UpdateState());
    emit(HomeDataLoadingStopState());
  }

  Future<void> getLatLngFromAddress(
      GeocodingAddressEvent event, Emitter<HomeState> emit) async {
    if (mapType == 'google_map') {
      emit(HomeDataLoadingStartState());
      final cachedPosition = await db.getCachedGeocoding(event.placeId);

      if (cachedPosition != null) {
        dropLatLng = cachedPosition;
        dropAddress = event.address;
        googleMapController!.moveCamera(CameraUpdate.newLatLng(dropLatLng!));
        dropAddressController.clear();
        emit(StateChangedState());
        emit(HomeDataLoadingStopState());
        return;
      }
      // Call the geocoding API if no cache is found
      if (AppConstants.packageName.isEmpty || AppConstants.signKey.isEmpty) {
        final val = await PackageInfo.fromPlatform();
        AppConstants.packageName = val.packageName;
        AppConstants.signKey = val.buildSignature;
      }

      final data = await serviceLocator<RideUsecases>().getGeocodingLatLng(
        sessionToken: sessionToken!,
        placeId: event.placeId,
        packageName: AppConstants.packageName,
        signKey: AppConstants.signKey,
      );

      data.fold(
        (error) {
          if (error.statusCode == 401) {
            AppSharedPreference.remove('login');
            AppSharedPreference.remove('token');
            emit(UserUnauthenticatedState());
          } else {
            emit(ShowErrorState(message: error.message.toString()));
          }
        },
        (success) async {
          // Cache the API result
          final position = success.position;
          await db.cacheGeocodingResult(event.placeId, position);

          // Update the UI with the new position
          dropLatLng = position;
          dropAddress = event.address;
          googleMapController!.moveCamera(CameraUpdate.newLatLng(dropLatLng!));
          dropAddressController.clear();
          emit(StateChangedState());
        },
      );
      emit(HomeDataLoadingStopState());
    } else {
      emit(HomeDataLoadingStartState());
      dropLatLng = event.position;
      dropAddress = event.address;
      fmController.move(
          fmlt.LatLng(event.position!.latitude, event.position!.longitude), 13);
      add(ClearAutoCompleteEvent());
      emit(HomeDataLoadingStopState());
    }
  }

  Future<void> getAutoCompleteAddress(
      GetAutoCompleteAddressEvent event, Emitter<HomeState> emit) async {
    autoSuggestionSearching = true;
    emit(StateChangedState());
    sessionToken ??= const Uuid().v4();
    if (mapType == 'google_map') {
      final cachedPlaces = await db.getAllCachedAddresses();
      final matchingCachedPlaces = cachedPlaces
          .where((element) => element.address!
              .toLowerCase()
              .contains(event.searchText.toLowerCase()))
          .toList();
      if (matchingCachedPlaces.isNotEmpty) {
        autoCompleteAddress.clear();
        autoCompleteAddress.addAll(matchingCachedPlaces
            .map((e) => AddressData(
                  placeId: e.placeId,
                  address: e.address,
                  lat: e.lat,
                  lon: e.lon,
                  displayName: e.displayName,
                ))
            .toList());
        autoSuggestionSearching = false;
        emit(StateChangedState());
        return;
      }
    }
    final data = await serviceLocator<RideUsecases>().getAutoCompleteAddress(
      lat: currentLatLng!.latitude.toString(),
      lng: currentLatLng!.longitude.toString(),
      packageName: AppConstants.packageName,
      signKey: AppConstants.signKey,
      sessionToken: sessionToken!,
      input: event.searchText,
    );
    await data.fold(
      (error) async {
        autoCompleteAddress.clear();
        emit(StateChangedState());
      },
      (success) async {
        autoCompleteAddress.clear();
        autoCompleteAddress = success.predictions;
        if (mapType == 'google_map') {
          for (var address in autoCompleteAddress) {
            await db.insertCachedAddress(
              SearchPlace(
                placeId: address.placeId,
                address: address.address,
                lat: address.lat,
                lon: address.lon,
                displayName: address.displayName,
              ),
            );
          }
        }

        emit(StateChangedState());
      },
    );
    autoSuggestionSearching = false;
    emit(StateChangedState());
  }

  FutureOr<void> createInstantRequest(
      CreateInstantRideEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<RideUsecases>().createInstantRequest(
        pickLat: pickLatLng!.latitude.toString(),
        pickLng: pickLatLng!.longitude.toString(),
        dropLat: dropLatLng!.latitude.toString(),
        dropLng: dropLatLng!.longitude.toString(),
        rideType: '1',
        pickAddress: pickAddress,
        dropAddress: dropAddress,
        name: instantUserName.text,
        mobile: instantUserMobile.text,
        price: instantRidePrice!,
        goodsTypeId: choosenGoods,
        distance: etaDistance!,
        duration: etaDuration!,
        goodsTypeQuantity: goodsSize);

    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
        // emit(HomeDataLoadingStopState());
      },
      (success) async {
        showGetDropAddress = false;
        userData!.onTripRequest = success.ontripData;
        emit(HomeDataLoadingStopState());
        emit(InstantRideSuccessState());
        if ((userData!.onTripRequest != null) &&
            polyline.isEmpty &&
            (userData!.onTripRequest == null ||
                userData!.onTripRequest!.isCompleted == 0)) {
          if (AppConstants.packageName == '' || AppConstants.signKey == '') {
            var val = await PackageInfo.fromPlatform();
            AppConstants.packageName = val.packageName;
            AppConstants.signKey = val.buildSignature;
          }
          if (polyline.isEmpty &&
              userData!.onTripRequest != null &&
              userData!.onTripRequest!.dropAddress != null) {
            add(GetRideChatEvent());
            add(PolylineEvent(
                pickLat: userData!.onTripRequest!.pickLat,
                pickLng: userData!.onTripRequest!.pickLng,
                dropLat: userData!.onTripRequest!.dropLat!,
                dropLng: userData!.onTripRequest!.dropLng!,
                stops: userData!.onTripRequest!.requestStops,
                packageName: AppConstants.packageName,
                signKey: AppConstants.signKey,
                pickAddress: userData!.onTripRequest!.pickAddress,
                dropAddress: userData!.onTripRequest!.dropAddress ?? ''));
          }
        } else if (polyline.isNotEmpty && userData!.onTripRequest != null) {
          // double dist = (userData!.onTripRequest!.totalDistance != '0')
          //     ? double.parse(
          //             userData!.onTripRequest!.totalDistance.toString()) -
          //         distance
          //     : calculateDistance(
          //         lat1: currentLatLng!.latitude,
          //         lon1: currentLatLng!.longitude,
          //         lat2: userData!.onTripRequest!.dropLat!,
          //         lon2: userData!.onTripRequest!.dropLng!);
          double dist = double.parse((etaDistance ?? 0).toString());
          double time = double.parse((etaDuration ?? 0).toString());
          await addDistanceMarker(
              LatLng(userData!.onTripRequest!.dropLat!,
                  userData!.onTripRequest!.dropLng!),
              dist,
              time: time);
        }
        if (userData!.onTripRequest != null && rideStream == null) {
          streamRide();
        }
        if (userData!.onTripRequest != null &&
            userData!.onTripRequest!.arrivedAt != null &&
            waitingTimer == null &&
            userData!.onTripRequest!.isBidRide == "0") {
          waitingTime();
        }

        if (userData!.onTripRequest!.enableShipmentLoad == '1') {
          add(UploadProofEvent(
              image: loadImage!,
              isBefore: true,
              id: userData!.onTripRequest!.id));
        }
        emit(UpdateState());
      },
    );
  }

  Future addDistanceMarker(LatLng position, double distanceMeter,
      {double? time}) async {
    markers.removeWhere(
        (element) => element.markerId == const MarkerId('distance'));
    double duration;
    String totalDistance;
    if (time != null) {
      if (time > 0) {
        duration = time;
      } else {
        duration = 2;
      }
    } else {
      if ((distanceMeter / 1000) > 0) {
        duration = ((distanceMeter / 1000) * 1.5).roundToDouble();
      } else {
        duration = 2;
      }
    }

    if ((distanceMeter / 1000).toStringAsFixed(0) == '0') {
      totalDistance = '0.5';
      duration = 1;
    } else {
      totalDistance = (distanceMeter / 1000).toStringAsFixed(0);
    }

    markers.add(Marker(
      anchor: Offset(0.5, 0.0),
      markerId: const MarkerId("distance"),
      position: position,
      icon: await Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            margin: EdgeInsets.only(top: 10),
            height: 40,
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.primary, width: 1)),
            // padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5)),
                      color: AppColors.primary),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        text: totalDistance,
                        textStyle: AppTextStyle.normalStyle().copyWith(
                            color: ThemeData.light().scaffoldBackgroundColor,
                            fontSize: 12),
                      ),
                      MyText(
                        text: 'KM',
                        textStyle: AppTextStyle.normalStyle().copyWith(
                            color: ThemeData.light().scaffoldBackgroundColor,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5)),
                        color: ThemeData.light().scaffoldBackgroundColor),
                    child: MyText(
                      text: ((duration) > 60)
                          ? '${(duration / 60).toStringAsFixed(0)} hrs'
                          : '${duration.toStringAsFixed(0)} mins',
                      textStyle: AppTextStyle.normalStyle()
                          .copyWith(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          )).toBitmapDescriptor(
        logicalSize: const Size(100, 30),
        imageSize: const Size(100, 30),
      ),
    ));
    add(UpdateEvent());
  }

  FutureOr<void> etaRequest(
      GetEtaRequestEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    if (AppConstants.packageName == '' || AppConstants.signKey == '') {
      var val = await PackageInfo.fromPlatform();
      AppConstants.packageName = val.packageName;
      AppConstants.signKey = val.buildSignature;
    }
    await getPolyline(
        PolylineEvent(
            pickLat: pickLatLng!.latitude,
            pickLng: pickLatLng!.longitude,
            dropLat: dropLatLng!.latitude,
            dropLng: dropLatLng!.longitude,
            stops: [],
            packageName: AppConstants.packageName,
            signKey: AppConstants.signKey,
            pickAddress: pickAddress,
            dropAddress: dropAddress),
        emit);
    final data = await serviceLocator<RideUsecases>().etaRequest(
        pickLat: pickLatLng!.latitude.toString(),
        pickLng: pickLatLng!.longitude.toString(),
        dropLat: dropLatLng!.latitude.toString(),
        dropLng: dropLatLng!.longitude.toString(),
        rideType: '1',
        distance: etaDistance!,
        duration: etaDuration!);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(HomeDataLoadingStopState());
        }
      },
      (success) async {
        instantRidePrice = success.price;
        instantRideCurrency = success.currency;
        instantUserMobile.clear();
        instantUserName.clear();
        goodsSizeText.clear();
        choosenGoods = null;
        goodsSize = 'Loose';
        if (userData!.transportType == 'both') {
          instantRideType = 'taxi';
        } else {
          instantRideType = null;
        }
        autoSuggestionSearching = false;
        emit(HomeDataLoadingStopState());
        emit(InstantEtaSuccessState());
      },
    );
  }

  // ride arrived
  FutureOr<void> getPolyline(
      PolylineEvent event, Emitter<HomeState> emit) async {
    polyline.clear();
    fmpoly.clear();
    markers
        .removeWhere((element) => element.markerId != const MarkerId('my_loc'));
    final data = await serviceLocator<RideUsecases>().getPolyline(
      pickLat: event.pickLat,
      pickLng: event.pickLng,
      dropLat: event.dropLat,
      dropLng: event.dropLng,
      stops: event.stops,
      packageName: event.packageName,
      signKey: event.signKey,
      map: mapType,
    );
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) async {
        etaDistance = success.distance.toString();
        etaDuration = success.duration.toString();
        polyString = success.polyString;
        if (userData!.onTripRequest != null) {
          FirebaseDatabase.instance
              .ref('requests')
              .child(userData!.onTripRequest!.id)
              .update({
            'polyline': success.polyString,
            'distance': etaDistance,
            'duration': etaDuration
          });
        }
        if (mapType == 'google_map') {
          markers.add(Marker(
            markerId: const MarkerId("pick"),
            position: LatLng(event.pickLat, event.pickLng),
            icon: await Image.asset(
              AppImages.pickupIcon,
              height: 30,
              width: 30,
              fit: BoxFit.contain,
            ).toBitmapDescriptor(
              logicalSize: const Size(30, 30),
              imageSize: const Size(200, 200),
            ),
          ));
          if (event.stops.isEmpty && event.dropAddress != '') {
            markers.add(Marker(
              markerId: const MarkerId("drop"),
              position: LatLng(event.dropLat, event.dropLng),
              icon: await Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                  )).toBitmapDescriptor(
                logicalSize: const Size(30, 30),
                imageSize: const Size(200, 200),
              ),
            ));
          } else if (event.stops.isNotEmpty) {
            for (var i = 0; i < event.stops.length; i++) {
              markers.add(Marker(
                markerId: MarkerId("drop$i"),
                position: LatLng(
                    event.stops[i]['latitude'], event.stops[i]['longitude']),
                icon: (i == event.stops.length - 1)
                    ? await Directionality(
                        textDirection: TextDirection.ltr,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                        )).toBitmapDescriptor(
                        logicalSize: const Size(30, 30),
                        imageSize: const Size(200, 200),
                      )
                    : await Image.asset(
                        (i == 0)
                            ? AppImages.stopOne
                            : (i == 1)
                                ? AppImages.stopTwo
                                : (i == 2)
                                    ? AppImages.stopThree
                                    : AppImages.stopFour,
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ).toBitmapDescriptor(
                        logicalSize: const Size(30, 30),
                        imageSize: const Size(200, 200),
                      ),
              ));
            }
          }
          if (userData!.onTripRequest != null &&
              (userData!.onTripRequest!.arrivedAt == null ||
                  userData!.onTripRequest!.arrivedAt == "")) {
            final dist = double.parse(etaDistance!);
            final time = double.parse(etaDuration!);
            await addDistanceMarker(LatLng(event.dropLat, event.dropLng), dist,
                time: time);
            add(UpdateEvent());
          }
        }
        if (mapType == 'google_map') {
          if (userData!.metaRequest != null ||
              (userData!.onTripRequest != null &&
                  userData!.onTripRequest!.arrivedAt != null) ||
              (userData!.metaRequest == null &&
                  userData!.onTripRequest == null &&
                  choosenRide != null) ||
              (userData!.metaRequest == null &&
                  userData!.onTripRequest == null &&
                  showGetDropAddress)) {
            mapBound(event.pickLat, event.pickLng, event.dropLat, event.dropLng,
                event.stops);
          } else {
            mapBound(currentLatLng!.latitude, currentLatLng!.longitude,
                event.pickLat, event.pickLng, event.stops);
          }

          decodeEncodedPolyline(success.polyString);
        } else {
          mapBound(currentLatLng!.latitude, currentLatLng!.longitude,
              event.pickLat, event.pickLng, event.stops);

          decodeEncodedPolyline(success.polyString);
          double lat = (event.pickLat + event.dropLat) / 2;
          double lon = (event.pickLng + event.dropLng) / 2;
          var val = LatLng(lat, lon);
          fmController.move(fmlt.LatLng(val.latitude, val.longitude), 13);
          add(PolylineSuccessEvent());
        }
      },
    );
  }

  LatLngBounds? bound;

  mapBound(pickLat, pickLng, dropLat, dropLng, stops,
      {bool? isInitCall, bool? isRentalRide}) {
    List points = [LatLng(pickLat, pickLng), LatLng(dropLat, dropLng)];
    if (userData!.onTripRequest == null ||
        userData!.onTripRequest!.arrivedAt != null) {
      stops.forEach((e) {
        points.add(LatLng(e['latitude'], e['longitude']));
      });
    }

    double southWestLat =
        points.map((m) => m.latitude).reduce((a, b) => a < b ? a : b);
    double southWestLng =
        points.map((m) => m.longitude).reduce((a, b) => a < b ? a : b);
    double northEastLat =
        points.map((m) => m.latitude).reduce((a, b) => a > b ? a : b);
    double northEastLng =
        points.map((m) => m.longitude).reduce((a, b) => a > b ? a : b);

    bound = LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  List<LatLng> polylist = [];
  List<fmlt.LatLng> fmpoly = [];
  Future<List<PointLatLng>> decodeEncodedPolyline(String encoded) async {
    polylist.clear();
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    polyline.clear();

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      if (mapType == 'google_map') {
        polylist.add(p);
      } else {
        fmpoly.add(fmlt.LatLng(p.latitude, p.longitude));
      }
    }
    if (mapType == 'google_map') {
      polyline.add(
        Polyline(
            polylineId: const PolylineId('1'),
            color: AppColors.primary,
            visible: true,
            width: 4,
            points: polylist),
      );

      if (mapType == 'google_map') {
        googleMapController
            ?.animateCamera(CameraUpdate.newLatLngBounds(bound!, 50));
      } else {
        fmController.move(
            fmlt.LatLng(bound!.northeast.latitude, bound!.northeast.longitude),
            13);
      }
      add(PolylineSuccessEvent());
    }
    return poly;
  }

  Future<void> streamPolyline(
      PolylineSuccessEvent event, Emitter<HomeState> emit) async {
    emit(PolylineSuccessState());
  }

  Future<void> openAnotherFeature(
      OpenAnotherFeatureEvent event, Emitter<HomeState> emit) async {
    if (await launchUrl(Uri.parse(event.value))) {
      await launchUrl(Uri.parse(event.value));
    } else {
      throw 'Could not launch ${event.value}';
    }
  }

  streamLocation() async {
    if (userData != null && userData!.role == 'driver') {
      final BitmapDescriptor bikeMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.bikeOffline);

      final BitmapDescriptor carMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.car);

      final BitmapDescriptor autoMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.auto);

      final BitmapDescriptor truckMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.truck);

      final BitmapDescriptor ehcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.ehcv);

      final BitmapDescriptor hatchBack = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.hatchBack);

      final BitmapDescriptor hcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.hcv);

      final BitmapDescriptor lcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.lcv);

      final BitmapDescriptor mcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.mcv);

      final BitmapDescriptor luxury = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.luxury);

      final BitmapDescriptor premium = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.premium);

      final BitmapDescriptor suv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(16, 30)), AppImages.suv);

      vehicleMarker ??= (userData!.vehicleTypeIcon == 'truck')
          ? truckMarker
          : (userData!.vehicleTypeIcon == 'motor_bike')
              ? bikeMarker
              : (userData!.vehicleTypeIcon == 'auto')
                  ? autoMarker
                  : (userData!.vehicleTypeIcon == 'lcv')
                      ? lcv
                      : (userData!.vehicleTypeIcon == 'ehcv')
                          ? ehcv
                          : (userData!.vehicleTypeIcon == 'hatchback')
                              ? hatchBack
                              : (userData!.vehicleTypeIcon == 'hcv')
                                  ? hcv
                                  : (userData!.vehicleTypeIcon == 'mcv')
                                      ? mcv
                                      : (userData!.vehicleTypeIcon == 'luxury')
                                          ? luxury
                                          : (userData!.vehicleTypeIcon ==
                                                  'premium')
                                              ? premium
                                              : (userData!.vehicleTypeIcon ==
                                                      'suv')
                                                  ? suv
                                                  : carMarker;

      // Remove previous marker if exists
      if (currentLatLng != null) {
        markers.removeWhere(
            (element) => element.markerId == const MarkerId('my_loc'));
        markers.add(Marker(
            markerId: const MarkerId('my_loc'),
            position: currentLatLng!,
            icon: vehicleMarker!,
            anchor: const Offset(0.5, 0.5)));
      }
    }
    positionSubscription?.cancel();
    positionSubscription = positionStream.handleError((onError) {
      positionSubscription?.cancel();
    }).listen((Position? position) async {
      if (position != null) {
        if (vsync != null && currentLatLng != null && vehicleMarker != null) {
          if (markers
              .where((element) => element.markerId == const MarkerId('my_loc'))
              .isNotEmpty) {
            // Dispose of the previous AnimationController if it exists
            // if (animationController != null) animationController?.dispose();
            animationController = AnimationController(
                vsync: vsync, duration: const Duration(milliseconds: 1500));
            animateCar(
                currentLatLng!.latitude,
                currentLatLng!.longitude,
                position.latitude,
                position.longitude,
                vsync,
                (mapType == 'google_map') ? googleMapController! : fmController,
                'my_loc',
                vehicleMarker!,
                mapType);
            currentLatLng = LatLng(position.latitude, position.longitude);
            add(UpdateEvent());
          } else {
            markers.add(Marker(
                markerId: const MarkerId('my_loc'),
                position: currentLatLng!,
                icon: vehicleMarker!,
                anchor: const Offset(0.5, 0.5)));
            currentLatLng = LatLng(position.latitude, position.longitude);
            add(UpdateEvent());
          }
        } else {
          currentLatLng = LatLng(position.latitude, position.longitude);
          add(UpdateEvent());
        }
        updateFirebaseData();
        if (userData!.onTripRequest != null &&
            userData!.onTripRequest!.arrivedAt != null &&
            userData!.onTripRequest!.dropLat != null &&
            userData!.onTripRequest!.dropLng != null) {
          markers.removeWhere(
              (element) => element.markerId == const MarkerId('distance'));
          double minPerDistance =
              double.parse(userData!.onTripRequest!.totalTime.toString()) /
                  double.parse(userData!.onTripRequest!.totalDistance);
          double dist = calculateDistance(
              lat1: currentLatLng!.latitude,
              lon1: currentLatLng!.longitude,
              lat2: userData!.onTripRequest!.dropLat!,
              lon2: userData!.onTripRequest!.dropLng!);
          final dist1 = calculateDistance(
              lat1: userData!.onTripRequest!.pickLat,
              lon1: userData!.onTripRequest!.pickLng,
              lat2: currentLatLng!.latitude,
              lon2: currentLatLng!.longitude);
          final calDuration =
              double.parse(userData!.onTripRequest!.totalTime.toString()) -
                  ((dist1 / 1000) * minPerDistance);
          FirebaseDatabase.instance
              .ref('requests')
              .child(userData!.onTripRequest!.id)
              .update({'distance': dist, 'duration': calDuration});
          await addDistanceMarker(
              LatLng(userData!.onTripRequest!.dropLat!,
                  userData!.onTripRequest!.dropLng!),
              dist,
              time: calDuration);
        }
        add(UpdateEvent());
      } else {
        positionSubscription?.cancel();
      }
    });
  }

  Future<void> updatePricePerDistance(
      UpdatePricePerDistanceEvent event, Emitter<HomeState> emit) async {
    onlineLoader = true;
    emit(HomeDataLoadingStartState());
    final data = await serviceLocator<HomeUsecase>()
        .updatePricePerDistance(price: event.price);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          onlineLoader = false;
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        userData!.pricePerDistance = event.price;
      },
    );
    emit(HomeDataLoadingStopState());
  }

  Future<void> navigationTypeFunc(
      NavigationTypeEvent event, Emitter<HomeState> emit) async {
    if (navigationType) {
      navigationType = false;
    } else {
      navigationType = true;
    }
    emit(NavigationTypeState());
  }

  Future<void> changeOnlineOffline(
      ChangeOnlineOfflineEvent event, Emitter<HomeState> emit) async {
    onlineLoader = true;
    var bubble = await AppSharedPreference.getBubbleSettingStatus();
    emit(OnlineOfflineLoadingState());
    bool status = await WakelockPlus.enabled;
    final data = await serviceLocator<HomeUsecase>().onlineOffline();
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          onlineLoader = false;
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        userData!.active = success.isOnline;
        userData!.available = success.isOnline;
        updateFirebaseData();
        if (success.isOnline == true) {
          if (!status) {
            WakelockPlus.enable();
          }
          if (bubble) {
            showBubbleIcon = true;
          }
          if (activeTimer == null || !activeTimer!.isActive) {
            activeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
              userData!.totalMinutesOnline =
                  (int.parse(userData!.totalMinutesOnline!) + 1).toString();
              add(UpdateOnlineTimeEvent(
                  minutes: int.parse(userData!.totalMinutesOnline!)));
            });
          }
          if (requestStream == null) {
            streamRequest();
          }
          if (bidRequestStream == null) {
            streamBidRequest();
          }
        } else {
          if (status) {
            WakelockPlus.disable();
          }
          if (bubble) {
            showBubbleIcon = false;
          }
          if (activeTimer != null) {
            activeTimer!.cancel();
            activeTimer = null;
          }
          if (requestStream != null) {
            requestStream?.cancel();
            requestStream = null;
          }
          if (bidRequestStream != null) {
            bidRequestStream?.cancel();
            bidRequestStream = null;
          }
        }

        onlineLoader = false;
        emit(OnlineOfflineSuccessState());
      },
    );
  }

  FutureOr updateActiveUserTiming(
      UpdateOnlineTimeEvent event, Emitter<HomeState> emit) async {
    emit(UpdateOnlineTimeState(minutes: event.minutes));
  }

  Future<void> paymentRecieved(
      PaymentRecievedEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    final data = await serviceLocator<RideUsecases>()
        .paymentRecieved(requestId: userData!.onTripRequest!.id);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        userData!.onTripRequest!.isPaid = 1;
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({'modified_by_driver': ServerValue.timestamp});
      },
    );
    emit(HomeDataLoadingStopState());
  }

  Future<void> addRideReview(
      UploadReviewEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    final data = await serviceLocator<RideUsecases>().addReview(
        requestId: userData!.onTripRequest!.id,
        rating: review,
        comment: reviewController.text);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(HomeDataLoadingStopState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        add(GetUserDetailsEvent(loading: 1));
      },
    );
    // emit(HomeDataLoadingStopState());
  }

  Future<void> onTripRequest(
      StreamRequestEvent event, Emitter<HomeState> emit) async {
    emit(RideUpdateState());
  }

  streamRequest() async {
    requestStream?.cancel();
    requestStream = FirebaseDatabase.instance
        .ref('request-meta')
        .orderByChild('driver_id')
        .equalTo(userData!.id)
        .onValue
        .listen((onData) {
      if (onData.snapshot.value != null || userData!.metaRequest != null) {
        add(GetUserDetailsEvent());
      } else {}
    });
  }

  bidRequestUpdate(BidRideRequestEvent event, Emitter<HomeState> emit) async {
    emit(BidRideRequestState());
  }

  streamBidRequest() async {
    bidRequestStream?.cancel();
    if (distanceBetween == null) {
      var val = await AppSharedPreference.getDistanceBetween();
      distanceBetween = (val != null) ? val : 2.0;
    }
    if (currentLatLng != null) {
      bidRequestStream = FirebaseDatabase.instance
          .ref('bid-meta')
          .orderByChild('g')
          .startAt(geo.encode(
              currentLatLng!.longitude -
                  (lon *
                      (distanceBetweenList.firstWhere(
                          (e) => e['dist'] == distanceBetween!)['value'])),
              currentLatLng!.latitude -
                  (lat *
                      (distanceBetweenList.firstWhere(
                          (e) => e['dist'] == distanceBetween!)['value']))))
          .endAt(geo.encode(
              currentLatLng!.longitude +
                  (lon *
                      (distanceBetweenList.firstWhere(
                          (e) => e['dist'] == distanceBetween!)['value'])),
              currentLatLng!.latitude +
                  (lat *
                      (distanceBetweenList.firstWhere(
                          (e) => e['dist'] == distanceBetween!)['value']))))
          .onValue
          .handleError((onError) {
        bidRequestStream?.cancel();
        bidRequestStream = null;
      }).listen((DatabaseEvent event) {
        rideList.clear();
        outStationList.clear();
        List waitingData = [];
        if (event.snapshot.value != null) {
          Map list = jsonDecode(jsonEncode(event.snapshot.value));

          list.forEach((key, value) {
            if (value['drivers'] != null &&
                (userData!.vehicleTypeId == value['vehicle_type'] ||
                    userData!.vehicleTypes!.contains(value['vehicle_type']))) {
              if (value['drivers']['driver_${userData!.id}'] != null) {
                if (value['drivers']['driver_${userData!.id}']["is_rejected"] ==
                        'none' &&
                    value['is_out_station'] == false) {
                  rideList.add(value);
                  waitingData.add(value);
                } else if (value['drivers']['driver_${userData!.id}']
                            ["is_rejected"] !=
                        'by_driver' &&
                    value['is_out_station'] == false) {
                  rideList.add(value);
                }
                add(UpdateEvent());
              }
              // else {
              //   if (value['is_out_station'] == false) {
              //     showOutstationWidget = true;
              //     outStationList.add(value);
              //   } else {
              //     rideList.add(value);
              //   }
              // }
              if (value['drivers']['driver_${userData!.id}'] != null) {
                if (value['drivers']['driver_${userData!.id}']["is_rejected"] !=
                    'by_driver') {
                  if ((waitingData.isEmpty)) {
                    if (oldRides.contains(value['request_id']) == false &&
                        isBiddingEnabled &&
                        value['is_out_station'] == false) {
                      // showOutstationWidget = false;
                      audioPlayer.play(AssetSource(AppAudios.requestSound));
                      oldRides.add(value['request_id']);
                      if (showBiddingPage == false &&
                          value['is_out_station'] == false) {
                        // showOutstationWidget = false;
                        showBiddingPage = true;
                        add(UpdateEvent());
                      }
                    }
                    if (value['is_out_station'] == true &&
                        userData!.showOutstationRideFeature == '1') {
                      showOutstationWidget = true;
                      // oldRides.add(value['request_id']);
                      outStationList.add(value);
                      add(UpdateEvent());
                    }
                  }
                }
              }
              add(UpdateEvent());
            } else if (userData!.vehicleTypeId == value['vehicle_type'] ||
                userData!.vehicleTypes!.contains(value['vehicle_type'])) {
              if (value['is_out_station'] == false) {
                rideList.add(value);
              }

              if ((waitingData.isEmpty)) {
                if (oldRides.contains(value['request_id']) == false &&
                    isBiddingEnabled &&
                    value['is_out_station'] == false) {
                  // showOutstationWidget = false;
                  audioPlayer.play(AssetSource(AppAudios.requestSound));
                  oldRides.add(value['request_id']);
                  if (showBiddingPage == false &&
                      value['is_out_station'] == false) {
                    showBiddingPage = true;
                    // showOutstationWidget = false;
                    add(UpdateEvent());
                  }
                }
                if (value['is_out_station'] == true &&
                    userData!.showOutstationRideFeature == '1') {
                  audioPlayer.play(AssetSource(AppAudios.requestSound));
                  showOutstationWidget = true;
                  visibleOutStation = true;
                  outStationList.add(value);
                  add(UpdateEvent());
                }
              }
              add(UpdateEvent());
            }
          });
          if (rideList.isNotEmpty) {
            rideList.sort((a, b) => b['updated_at'].compareTo(a["updated_at"]));
          }
          add(UpdateEvent());
        }
        if (waitingData.isNotEmpty && searchTimer == null) {
          waitingList = waitingData;
          rideSearchTimer();
        } else if (waitingData.isEmpty && waitingList.isNotEmpty) {
          searchTimer?.cancel();
          searchTimer = null;
          if (rideList
              .where((e) => waitingList[0]['request_id'] == e['request_id'])
              .isEmpty) {
            choosenRide = null;

            add(GetUserDetailsEvent());
          } else {
            bidDeclined = true;
          }
          waitingList = waitingData;
        }
        if (choosenRide != null &&
            rideList.where((e) => e['request_id'] == choosenRide).isEmpty) {
          polyline.clear();
          fmpoly.clear();
          markers.removeWhere(
              (element) => element.markerId != const MarkerId('my_loc'));
          choosenRide = null;
        } else {}
        add(BidRideRequestEvent());
      });
    }
  }

  streamRide() {
    requestStream?.cancel();
    requestStream = null;
    bidRequestStream?.cancel();
    bidRequestStream = null;
    rideStream?.cancel();
    rideAddStream?.cancel();
    rideStream = FirebaseDatabase.instance
        .ref('requests')
        .child(userData!.onTripRequest!.id)
        .onChildChanged
        .listen((data) {
      if (data.snapshot.key == 'cancelled_by_user') {
        isUserCancelled = true;
        rideStream?.cancel();
        rideStream = null;
        rideAddStream?.cancel();
        rideAddStream = null;
        FirebaseDatabase.instance
            .ref()
            .child('requests/${userData!.onTripRequest!.id}')
            .remove();
        add(UpdateEvent());
        add(GetUserDetailsEvent());
      } else if (data.snapshot.key == 'modified_by_user') {
        add(GetUserDetailsEvent());
      } else if (data.snapshot.key == 'message_by_user') {
        add(GetRideChatEvent());
      } else if (data.snapshot.key == 'lat_lng_array') {
        latlngArray =
            jsonDecode(jsonEncode(data.snapshot.child('lat_lng_array').value));
        add(UpdateEvent());
      }
    });

    rideAddStream = FirebaseDatabase.instance
        .ref('requests')
        .child(userData!.onTripRequest!.id)
        .onChildAdded
        .listen((data) {
      if (data.snapshot.key == 'cancelled_by_user') {
        isUserCancelled = true;
        rideStream?.cancel();
        rideStream = null;
        rideAddStream?.cancel();
        rideAddStream = null;
        add(UpdateEvent());
        add(GetUserDetailsEvent());
      } else if (data.snapshot.key == 'modified_by_user') {
        add(GetUserDetailsEvent());
      } else if (data.snapshot.key == 'message_by_user') {
        add(GetRideChatEvent());
      }
    });
  }

  streamOwnersDriver() async {
    ownersDriver?.cancel();
    onlineCar ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.carOnline);

    offlineCar ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.carOffline);

    onrideCar ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.carOnride);

    onlineTruck ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.deliveryOnline);

    offlineTruck ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.deliveryOffline);

    onrideTruck ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.deliveryOnride);

    onlineBike ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.bikeOnline);

    offlineBike ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.bikeOffline);

    onrideBike ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.bikeOnride);

    markers.removeWhere(
        (element) => element.markerId.toString().contains('owner_'));
    ownersDriver = FirebaseDatabase.instance
        .ref('drivers')
        .orderByChild('ownerid')
        .equalTo(userData!.id.toString())
        .onValue
        .listen((data) {
      if (data.snapshot.exists) {
        Map<String, dynamic> datas =
            jsonDecode(jsonEncode(data.snapshot.value));

        datas.forEach((k, v) {
          if (choosenCarMenu == 0 ||
              (choosenCarMenu == 1 &&
                  v['is_active'] == 1 &&
                  v['is_available'] == true) ||
              (choosenCarMenu == 3 &&
                  v['is_active'] == 1 &&
                  v['is_available'] == false) ||
              (choosenCarMenu == 2 && v['is_active'] == 0)) {
            if (v['vehicle_types'] != null) {
              if (markers
                  .where((element) =>
                      element.markerId.toString().contains('owner_${v['id']}'))
                  .isEmpty) {
                markers.add(Marker(
                    markerId: (v['is_active'] == 1 && v['is_available'] == true)
                        ? MarkerId('owner_${v['id']}_1')
                        : (v['is_active'] == 1 && v['is_available'] == false)
                            ? MarkerId('owner_${v['id']}_3')
                            : MarkerId('owner_${v['id']}_2'),
                    position: LatLng(v['l'][0], v['l'][1]),
                    icon: (v['vehicle_type_icon'] == 'car')
                        ? (v['is_active'] == 1 && v['is_available'] == true)
                            ? onlineCar!
                            : (v['is_active'] == 1 &&
                                    v['is_available'] == false)
                                ? onrideCar!
                                : offlineCar!
                        : (v['vehicle_type_icon'] == 'motor_bike')
                            ? (v['is_active'] == 1 && v['is_available'] == true)
                                ? onlineBike!
                                : (v['is_active'] == 1 &&
                                        v['is_available'] == false)
                                    ? onrideBike!
                                    : offlineBike!
                            : (v['is_active'] == 1 && v['is_available'] == true)
                                ? onlineTruck!
                                : (v['is_active'] == 1 &&
                                        v['is_available'] == false)
                                    ? onrideTruck!
                                    : offlineTruck!,
                    anchor: const Offset(0.5, 0.5)));
              } else if ((v['is_active'] == 1 &&
                      v['is_available'] == true &&
                      markers
                          .where((element) =>
                              element.markerId !=
                              MarkerId('owner_${v['id']}_1'))
                          .isNotEmpty) ||
                  (v['is_active'] == 1 &&
                      v['is_available'] == false &&
                      markers
                          .where((element) =>
                              element.markerId !=
                              MarkerId('owner_${v['id']}_3'))
                          .isNotEmpty) ||
                  (v['is_active'] == 0 &&
                      markers
                          .where((element) =>
                              element.markerId !=
                              MarkerId('owner_${v['id']}_2'))
                          .isNotEmpty)) {
                markers.removeWhere((element) =>
                    element.markerId.toString().contains('owner_${v['id']}'));
                markers.add(Marker(
                    markerId: (v['is_active'] == 1 && v['is_available'] == true)
                        ? MarkerId('owner_${v['id']}_1')
                        : (v['is_active'] == 1 && v['is_available'] == false)
                            ? MarkerId('owner_${v['id']}_3')
                            : MarkerId('owner_${v['id']}_2'),
                    position: LatLng(v['l'][0], v['l'][1]),
                    icon: (v['vehicle_type_icon'] == 'car')
                        ? (v['is_active'] == 1 && v['is_available'] == true)
                            ? onlineCar!
                            : (v['is_active'] == 1 &&
                                    v['is_available'] == false)
                                ? onrideCar!
                                : offlineCar!
                        : (v['vehicle_type_icon'] == 'motor_bike')
                            ? (v['is_active'] == 1 && v['is_available'] == true)
                                ? onlineBike!
                                : (v['is_active'] == 1 &&
                                        v['is_available'] == false)
                                    ? onrideBike!
                                    : offlineBike!
                            : (v['is_active'] == 1 && v['is_available'] == true)
                                ? onlineTruck!
                                : (v['is_active'] == 1 &&
                                        v['is_available'] == false)
                                    ? onrideTruck!
                                    : offlineTruck!,
                    anchor: const Offset(0.5, 0.5)));
              } else {
                if (vsync != null) {
                  animationController = AnimationController(
                      vsync: vsync,
                      duration: const Duration(milliseconds: 1500));
                  animateCar(
                      currentLatLng!.latitude,
                      currentLatLng!.longitude,
                      v['l'][0],
                      v['l'][1],
                      vsync,
                      (mapType == 'google_map')
                          ? googleMapController!
                          : fmController,
                      (v['is_active'] == 1 && v['is_available'] == true)
                          ? 'owner_${v['id']}_1'
                          : (v['is_active'] == 1 && v['is_available'] == false)
                              ? 'owner_${v['id']}_3'
                              : 'owner_${v['id']}_2',
                      (v['vehicle_type_icon'] == 'car')
                          ? (v['is_active'] == 1 && v['is_available'] == true)
                              ? onlineCar!
                              : (v['is_active'] == 1 &&
                                      v['is_available'] == false)
                                  ? onrideCar!
                                  : offlineCar!
                          : (v['vehicle_type_icon'] == 'motor_bike')
                              ? (v['is_active'] == 1 &&
                                      v['is_available'] == true)
                                  ? onlineBike!
                                  : (v['is_active'] == 1 &&
                                          v['is_available'] == false)
                                      ? onrideBike!
                                      : offlineBike!
                              : (v['is_active'] == 1 &&
                                      v['is_available'] == true)
                                  ? onlineTruck!
                                  : (v['is_active'] == 1 &&
                                          v['is_available'] == false)
                                      ? onrideTruck!
                                      : offlineTruck!,
                      mapType);
                }
              }
            }
          }
        });
      } else {
        markers.removeWhere(
            (element) => element.markerId.toString().contains('owner_'));
      }
    });
  }

  Future<void> updateMarkerLocation(
      UpdateMarkerEvent event, Emitter<HomeState> emit) async {
    if (markers
        .where((e) => e.markerId == const MarkerId('pickup'))
        .isNotEmpty) {
      markers
          .firstWhere((e) => e.markerId == const MarkerId('pickup'))
          .copyWith(positionParam: event.latLng);
    }
    List<Placemark>? address = await GeocodingPlatform.instance
        ?.placemarkFromCoordinates(
            event.latLng.latitude, event.latLng.longitude);

    currentLocation =
        '${address![0].street} ${address[0].thoroughfare} ${(address[0].subLocality == address[0].locality) ? '' : address[0].subLocality} ${address[0].locality} ${address[0].administrativeArea} ${address[0].country} ${address[0].postalCode}';

    final BitmapDescriptor customMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(200, 200)), // Replace with your image size
        AppImages.pickupIcon);
    if (markers
        .where((e) => e.markerId == const MarkerId('pickup'))
        .isNotEmpty) {
    } else {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: event.latLng,
        infoWindow: const InfoWindow(title: 'Pickup Location'),
        icon: customMarker,
      ));
    }

    emit(UpdateLocationState());
  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();

    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return vector.degrees(atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - vector.degrees(atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return vector.degrees(atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - vector.degrees(atan(lng / lat))) + 270;
    }

    return -1;
  }

  animateCar(
    double fromLat, //Starting latitude

    double fromLong, //Starting longitude

    double toLat, //Ending latitude

    double toLong, //Ending longitude

    TickerProvider
        provider, //Ticker provider of the widget. This is used for animation

    dynamic controller, //Google map controller of our widget

    markerid,
    icon,
    map,
  ) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    dynamic carMarker;
    // if (name == '' && number == '') {
    carMarker = Marker(
        markerId: MarkerId(markerid),
        position: LatLng(fromLat, fromLong),
        icon: icon,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        draggable: false);

    Tween<double> tween = Tween(begin: 0, end: 1);
    List<LatLng> polyList = [];

    _animation = tween.animate(animationController!)
      ..addListener(() async {
        markers.removeWhere(
            (element) => element.markerId == MarkerId(markerid.toString()));

        final v = _animation!.value;

        double lng = v * toLong + (1 - v) * fromLong;

        double lat = v * toLat + (1 - v) * fromLat;

        LatLng newPos = LatLng(lat, lng);

        //New marker location
        if (polyline.isNotEmpty) {
          polyList = polyline
              .firstWhere((e) => e.mapsId == const PolylineId('1'))
              .points;
          List polys = [];
          dynamic nearestLat;
          dynamic pol;
          for (var e in polyList) {
            var dist = calculateDistance(
                lat1: newPos.latitude,
                lon1: newPos.longitude,
                lat2: e.latitude,
                lon2: e.longitude);
            if (pol == null) {
              polys.add(dist);
              pol = dist;
              nearestLat = e;
            } else {
              if (dist < pol) {
                polys.add(dist);
                pol = dist;
                nearestLat = e;
              }
            }
          }
          int currentNumber =
              polyList.indexWhere((element) => element == nearestLat);
          for (var i = 0; i < currentNumber; i++) {
            polyList.removeAt(0);
          }
          polyline.clear();
          polyline.add(
            Polyline(
                polylineId: const PolylineId('1'),
                color: AppColors.primary,
                visible: true,
                width: 4,
                points: polyList),
          );
        }

        carMarker = Marker(
            markerId: MarkerId(markerid),
            position: newPos,
            icon: icon,
            rotation: bearing,
            anchor: const Offset(0.5, 0.5),
            flat: true,
            draggable: false);

        markers.add(carMarker);
        add(UpdateEvent());
      });

    //Starting the animation
    await animationController!.forward();
    if (userData!.onTripRequest != null) {
      if (map == 'google_map') {
        controller.getVisibleRegion().then((value) {
          if (value.contains(markers
                  .firstWhere(
                      (element) => element.markerId == MarkerId(markerid))
                  .position) ==
              false) {
            debugPrint('Animating correctly');
            controller.animateCamera(CameraUpdate.newLatLngZoom(
                markers
                    .firstWhere(
                        (element) => element.markerId == MarkerId(markerid))
                    .position,
                14));
            add(UpdateEvent());
          } else {
            debugPrint('Animating wrongly');
            add(UpdateEvent());
          }
        });
      } else {
        final latLng = markers
            .firstWhere((element) => element.markerId == MarkerId(markerid))
            .position;
        controller!.move(
            fmlt.LatLng(
                latLng.latitude.toDouble(), latLng.longitude.toDouble()),
            13);
      }
    }

    if (userData!.onTripRequest != null &&
        (((userData!.onTripRequest!.arrivedAt != null &&
                    userData!.onTripRequest!.arrivedAt != "") &&
                userData!.onTripRequest!.dropLat != null &&
                userData!.onTripRequest!.dropLng != null) ||
            (userData!.onTripRequest!.arrivedAt == null ||
                userData!.onTripRequest!.arrivedAt == ""))) {
      if (userData!.onTripRequest!.isTripStart != 1 &&
          (userData!.onTripRequest!.arrivedAt == null ||
              userData!.onTripRequest!.arrivedAt == "")) {
        double minPerDistance = double.parse((etaDuration ?? 1).toString()) /
            double.parse((etaDistance ?? 1).toString());
        final newDistance = await calculateDistance(
            lat1: toLat,
            lon1: toLong,
            lat2: userData!.onTripRequest!.pickLat,
            lon2: userData!.onTripRequest!.pickLng);
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({
          if (polyList.isNotEmpty) 'polyline': encodePolyline(polyList),
          'distance': (newDistance).toStringAsFixed(0),
          'duration': (double.parse((newDistance / 1000).toStringAsFixed(0)) *
                  minPerDistance)
              .toStringAsFixed(0)
        });
        await addDistanceMarker(
            LatLng(
                (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.arrivedAt != "")
                    ? userData!.onTripRequest!.dropLat!
                    : userData!.onTripRequest!.pickLat,
                (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.arrivedAt != "")
                    ? userData!.onTripRequest!.dropLng!
                    : userData!.onTripRequest!.pickLng),
            newDistance,
            time: (double.parse((newDistance / 1000).toStringAsFixed(0)) *
                    minPerDistance)
                .roundToDouble());
      } else if (userData!.onTripRequest!.isTripStart == 1 &&
          (userData!.onTripRequest!.arrivedAt != null &&
              userData!.onTripRequest!.arrivedAt != "")) {
        double minPerDistance =
            double.parse(userData!.onTripRequest!.totalTime.toString()) /
                double.parse(userData!.onTripRequest!.totalDistance);
        double dist = calculateDistance(
            lat1: toLat,
            lon1: toLong,
            lat2: userData!.onTripRequest!.dropLat!,
            lon2: userData!.onTripRequest!.dropLng!);
        final dist1 = calculateDistance(
            lat1: userData!.onTripRequest!.pickLat,
            lon1: userData!.onTripRequest!.pickLng,
            lat2: toLat,
            lon2: toLong);
        final calDuration =
            double.parse(userData!.onTripRequest!.totalTime.toString()) -
                ((dist1 / 1000) * minPerDistance);
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({
          if (polyList.isNotEmpty) 'polyline': encodePolyline(polyList),
          'distance': dist,
          'duration': calDuration
        });
        await addDistanceMarker(
            LatLng(userData!.onTripRequest!.dropLat!,
                userData!.onTripRequest!.dropLng!),
            dist,
            time: calDuration);
      }
    }

    animationController = null;
    add(UpdateEvent());
  }

  String encodePolyline(List<LatLng> polyline) {
    StringBuffer encoded = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (LatLng point in polyline) {
      int lat = (point.latitude * 1E5).round();
      int lng = (point.longitude * 1E5).round();

      // Encode the difference in latitude and longitude
      encoded.write(encodeValue(lat - prevLat));
      encoded.write(encodeValue(lng - prevLng));

      prevLat = lat;
      prevLng = lng;
    }

    return encoded.toString();
  }

  String encodeValue(int value) {
    int encode = value < 0 ? ~(value << 1) : value << 1;
    StringBuffer result = StringBuffer();

    while (encode >= 0x20) {
      result.writeCharCode((0x20 | (encode & 0x1f)) + 63);
      encode >>= 5;
    }
    result.writeCharCode(encode + 63);

    return result.toString();
  }

  Future<void> biddingFareIncreaseDecrease(
      BiddingIncreaseOrDecreaseEvent event, Emitter<HomeState> emit) async {
    if (event.isIncrease) {
      if ((double.parse(bidRideAmount.text.toString()) +
              (double.parse(
                  userData!.biddingAmountIncreaseOrDecrease.toString()))) <=
          (double.parse(acceptedRideFare) +
              ((double.parse(userData!.biddingHighPercentage) / 100) *
                  double.parse(acceptedRideFare)))) {
        isBiddingIncreaseLimitReach = false;
        isBiddingDecreaseLimitReach = false;
        bidRideAmount.text = (double.parse(bidRideAmount.text.toString()) +
                (double.parse(
                    userData!.biddingAmountIncreaseOrDecrease.toString())))
            .toStringAsFixed(2);
        if (!((double.parse(bidRideAmount.text.toString()) +
                (double.parse(
                    userData!.biddingAmountIncreaseOrDecrease.toString()))) <=
            (double.parse(acceptedRideFare) +
                ((double.parse(userData!.biddingHighPercentage) / 100) *
                    double.parse(acceptedRideFare))))) {
          bidRideAmount.text = (double.parse(bidRideAmount.text.toString()) +
                  (double.parse(
                      userData!.biddingAmountIncreaseOrDecrease.toString())))
              .toStringAsFixed(2);
          isBiddingIncreaseLimitReach = true;
          isBiddingDecreaseLimitReach = false;
        }
      } else {
        isBiddingIncreaseLimitReach = true;
        isBiddingDecreaseLimitReach = false;
      }
      emit(UpdateState());
    } else {
      if (bidRideAmount.text.isNotEmpty &&
          double.parse(bidRideAmount.text.toString()) >
              double.parse(acceptedRideFare) &&
          ((userData!.biddingLowPercentage == "0") ||
              (double.parse(bidRideAmount.text.toString()) -
                      double.parse(
                          userData!.biddingAmountIncreaseOrDecrease)) >=
                  (double.parse(acceptedRideFare) -
                      ((double.parse(userData!.biddingLowPercentage) / 100) *
                          double.parse(acceptedRideFare))))) {
        isBiddingDecreaseLimitReach = false;
        isBiddingIncreaseLimitReach = false;
        bidRideAmount.text = (double.parse(bidRideAmount.text.toString()) -
                (double.parse(
                    userData!.biddingAmountIncreaseOrDecrease.toString())))
            .toStringAsFixed(2);
        if (double.parse(bidRideAmount.text.toString()) ==
            double.parse(acceptedRideFare)) {
          isBiddingDecreaseLimitReach = true;
          isBiddingIncreaseLimitReach = false;
        }
      } else {
        isBiddingDecreaseLimitReach = true;
        isBiddingIncreaseLimitReach = false;
      }
      emit(UpdateState());
    }
  }

  @override
  Future<void> close() {
    animationController?.dispose();
    positionSubscription?.cancel();
    return super.close();
  }
}

class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
      // ignore: unnecessary_null_comparison
      : assert(latitude != null),
        // ignore: unnecessary_null_comparison
        assert(longitude != null),
        // ignore: unnecessary_this, prefer_initializing_formals
        this.latitude = latitude,
        // ignore: unnecessary_this, prefer_initializing_formals
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}
