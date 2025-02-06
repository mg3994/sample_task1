// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pincodeanime;
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_divider.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/account/presentation/pages/account_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/admin_chat.dart';
import 'package:restart_tagxi/features/account/presentation/pages/earnings_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/leaderboard_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/owner_dashboard.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/top_bar.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/bidding_request_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/bidding_ride_list_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/cancel_reason_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/chat_page_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/custom_timer.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/on_ride_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/accept_reject_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/outstation_request_page.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/outstation_ride_list_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/signature_painter_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/avatar_glow.dart';

import 'package:restart_tagxi/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/endpoints.dart';
import '../../../../core/utils/custom_dialoges.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart' as fmlt;

import '../../../account/presentation/pages/history_page.dart';

double bottomSize = 0.0;
double? bidRideTop;
Widget? _animatedWidget;
double deliveryLength = 0.0;
dynamic length = 1;
Widget mapWidget(
  BuildContext context,
  Size size,
) {
  bidRideTop ??= (size.height - size.width * 0.2) - (size.width * 0.8);
  LatLng? mapPoint;
  bool confirmPinAddress = false;

  dynamic later = 0;
  var screenshotImage = GlobalKey();

  if (userData?.metaRequest != null) {
    length = userData?.metaRequest!.requestStops.length ?? 1;
    if (userData?.metaRequest!.transportType == 'delivery') {
      deliveryLength = 0.1;
    }
    if (userData!.metaRequest!.isLater == true) {
      later = 0.1;
    }
    if (userData!.metaRequest!.isRental) {
      later = later + 0.1;
    }
  } else if (context.read<HomeBloc>().choosenRide != null &&
      context.read<HomeBloc>().rideList.isNotEmpty &&
      !context.read<HomeBloc>().showOutstationWidget) {
    length = (context
                .read<HomeBloc>()
                .rideList
                .firstWhere((e) =>
                    e['request_id'] ==
                    context.read<HomeBloc>().choosenRide)['trip_stops']
                .toString() !=
            'null')
        ? jsonDecode(context.read<HomeBloc>().rideList.firstWhere((e) =>
                e['request_id'] ==
                context.read<HomeBloc>().choosenRide)['trip_stops'])
            .length
        : 1;
    if (context
            .read<HomeBloc>()
            .rideList
            .firstWhere((e) =>
                e['request_id'] ==
                context.read<HomeBloc>().choosenRide)['goods']
            .toString() !=
        'null') {
      deliveryLength = 0.1;
    }
  }
  if (context.read<HomeBloc>().showBiddingPage) {
    if (bidRideTop == (size.height - size.width * 0.2) - (size.width * 0.8)) {
      bidRideTop = MediaQuery.of(context).padding.top + size.width * 0.05;
    }
  }
      
return StatefulBuilder(builder: (_, set) {    
  return Stack(
        children: [
          (context.read<HomeBloc>().choosenMenu == 0)
              ? Stack(
                  children: [
                    if (context.read<HomeBloc>().currentLatLng != null)
                      (mapType == 'google_map')
                          ? GoogleMap(
                                padding: EdgeInsets.fromLTRB(
                                    size.width * 0.05,
                                    (context.read<HomeBloc>().choosenRide !=
                                                null ||
                                            context
                                                .read<HomeBloc>()
                                                .showGetDropAddress)
                                        ? size.width * 0.15 +
                                            MediaQuery.of(context).padding.top
                                        : size.width * 0.05 +
                                            MediaQuery.of(context).padding.top,
                                    size.width * 0.05,
                                    (userData != null &&
                                            (userData!.metaRequest != null ||
                                                userData!.onTripRequest !=
                                                    null ||
                                                context
                                                        .read<HomeBloc>()
                                                        .choosenRide !=
                                                    null ||
                                                context
                                                    .read<HomeBloc>()
                                                    .showGetDropAddress))
                                        ? size.width
                                        : size.width * 0.05),
                                gestureRecognizers: {
                                  Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer(),
                                  ),
                                },
                                onMapCreated: (GoogleMapController controller) {
                                  context.read<HomeBloc>().googleMapController =
                                      controller;                                  
                                  if (Theme.of(context).brightness ==
                                      Brightness.dark) {
                                    context
                                        .read<HomeBloc>()
                                        .googleMapController!
                                        .setMapStyle(context
                                            .read<HomeBloc>()
                                            .darkMapString);
                                  } else {
                                    context
                                        .read<HomeBloc>()
                                        .googleMapController!
                                        .setMapStyle(context
                                            .read<HomeBloc>()
                                            .lightMapString);
                                  }
                                  context.read<HomeBloc>().add(UpdateEvent());
                                },
                                compassEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  target:
                                      context.read<HomeBloc>().currentLatLng ??
                                          const LatLng(0, 0),
                                  zoom: 15.0,
                                ),
                                onCameraMove: (CameraPosition position) {
                                  mapPoint = position.target;
                                },
                                onCameraIdle: () {
                                  if (context
                                          .read<HomeBloc>()
                                          .showGetDropAddress &&
                                      mapPoint != null &&
                                      context
                                          .read<HomeBloc>()
                                          .autoCompleteAddress
                                          .isEmpty &&
                                      context
                                          .read<HomeBloc>()
                                          .polyline
                                          .isEmpty) {
                                    set(() {
                                      confirmPinAddress = true;
                                    });
                                  } else if (context
                                          .read<HomeBloc>()
                                          .showGetDropAddress &&
                                      mapPoint != null &&
                                      context
                                          .read<HomeBloc>()
                                          .autoCompleteAddress
                                          .isNotEmpty &&
                                      !confirmPinAddress) {
                                    context
                                        .read<HomeBloc>()
                                        .add(ClearAutoCompleteEvent());
                                  }
                                  context.read<HomeBloc>().add(UpdateEvent());
                                },
                                markers: Set<Marker>.from(context.read<HomeBloc>().markers),
                                minMaxZoomPreference:
                                    const MinMaxZoomPreference(0, 20),
                                buildingsEnabled: false,
                                zoomControlsEnabled: false,
                                myLocationEnabled: false,
                                myLocationButtonEnabled: false,
                                polylines: context.read<HomeBloc>().polyline,
                              )
                          : fm.FlutterMap(
                              mapController:
                                  context.read<HomeBloc>().fmController,
                              options: fm.MapOptions(
                                  onMapEvent: (v) {
                                    if (v.source ==
                                            fm.MapEventSource.dragEnd ||
                                        v.source ==
                                            fm.MapEventSource.mapController) {
                                      if (context
                                              .read<HomeBloc>()
                                              .showGetDropAddress &&
                                          context
                                              .read<HomeBloc>()
                                              .autoCompleteAddress
                                              .isEmpty &&
                                          context
                                              .read<HomeBloc>()
                                              .fmpoly
                                              .isEmpty) {
                                        context.read<HomeBloc>().add(
                                            GeocodingLatLngEvent(
                                                lat: v.camera.center.latitude,
                                                lng: v.camera.center
                                                    .longitude));
                                      } else if (context
                                              .read<HomeBloc>()
                                              .showGetDropAddress &&
                                          mapPoint != null &&
                                          context
                                              .read<HomeBloc>()
                                              .autoCompleteAddress
                                              .isNotEmpty) {
                                        context
                                            .read<HomeBloc>()
                                            .add(ClearAutoCompleteEvent());
                                      }
                                    }
                                  },
                                  initialCenter: fmlt.LatLng(
                                      context
                                          .read<HomeBloc>()
                                          .currentLatLng!
                                          .latitude,
                                      context
                                          .read<HomeBloc>()
                                          .currentLatLng!
                                          .longitude),
                                  initialZoom: 16,
                                  onTap: (P, L) {}),
                              children: [
                                fm.TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                // fm.TileLayer(
                                //   urlTemplate: Theme.of(context).brightness ==
                                //           Brightness.dark
                                //       ? 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/{z}/{x}/{y}@4x.png'
                                //       : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                //   fallbackUrl: Theme.of(context).brightness ==
                                //           Brightness.dark
                                //       ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                                //       : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                //   subdomains: const ['a', 'b', 'c', 'd', 'e'],
                                //   userAgentPackageName: 'com.example.app',
                                // ),
                                fm.PolylineLayer(
                                  polylines: [
                                    fm.Polyline(
                                        points:
                                            context.read<HomeBloc>().fmpoly,
                                        color: Theme.of(context).primaryColor,
                                        strokeWidth: 4),
                                  ],
                                ),
                                fm.MarkerLayer(markers: [
                                  for (var i = 0;
                                      i <
                                          context
                                              .read<HomeBloc>()
                                              .markers
                                              .length;
                                      i++)
                                    fm.Marker(
                                      alignment: Alignment.center,
                                      point: fmlt.LatLng(
                                          context
                                              .read<HomeBloc>()
                                              .markers[i]
                                              .position
                                              .latitude,
                                          context
                                              .read<HomeBloc>()
                                              .markers[i]
                                              .position
                                              .longitude),
                                      width: 18,
                                      height: 30,
                                      child: Image.asset(
                                        (userData!.role == 'driver')
                                            ? (userData!.vehicleTypeIcon
                                                    .toString()
                                                    .contains('truck'))
                                                ? AppImages.truck
                                                : userData!.vehicleTypeIcon
                                                        .toString()
                                                        .contains(
                                                            'motor_bike')
                                                    ? AppImages.bikeOffline
                                                    : userData!
                                                            .vehicleTypeIcon
                                                            .toString()
                                                            .contains('auto')
                                                        ? AppImages.auto
                                                        : userData!
                                                                .vehicleTypeIcon
                                                                .toString()
                                                                .contains(
                                                                    'lcv')
                                                            ? AppImages.lcv
                                                            : userData!
                                                                    .vehicleTypeIcon
                                                                    .toString()
                                                                    .contains(
                                                                        'ehcv')
                                                                ? AppImages
                                                                    .ehcv
                                                                : userData!
                                                                        .vehicleTypeIcon
                                                                        .toString()
                                                                        .contains(
                                                                            'hatchback')
                                                                    ? AppImages
                                                                        .hatchBack
                                                                    : userData!
                                                                            .vehicleTypeIcon
                                                                            .toString()
                                                                            .contains('hcv')
                                                                        ? AppImages.hcv
                                                                        : userData!.vehicleTypeIcon.toString().contains('mcv')
                                                                            ? AppImages.mcv
                                                                            : userData!.vehicleTypeIcon.toString().contains('luxury')
                                                                                ? AppImages.luxury
                                                                                : userData!.vehicleTypeIcon.toString().contains('premium')
                                                                                    ? AppImages.premium
                                                                                    : userData!.vehicleTypeIcon.toString().contains('suv')
                                                                                        ? AppImages.suv
                                                                                        : AppImages.car
                                            : (context.read<HomeBloc>().markers[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('_')[3] == 'car')
                                                ? (context.read<HomeBloc>().markers[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('_')[2] == '1')
                                                    ? AppImages.carOnline
                                                    : (context.read<HomeBloc>().markers[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('_')[2] == '2')
                                                        ? AppImages.carOffline
                                                        : AppImages.carOnride
                                                : (context.read<HomeBloc>().markers[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('_')[3] == 'motor_bike')
                                                    ? (context.read<HomeBloc>().markers[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('_')[2] == '1')
                                                        ? AppImages.bikeOnline
                                                        : (context.read<HomeBloc>().markers[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('_')[2] == '2')
                                                            ? AppImages.bikeOffline
                                                            : AppImages.bikeOnride
                                                    : (context.read<HomeBloc>().markers[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('_')[2] == '1')
                                                        ? AppImages.deliveryOnline
                                                        : (context.read<HomeBloc>().markers[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('_')[2] == '2')
                                                            ? AppImages.deliveryOffline
                                                            : AppImages.deliveryOnride,
                                        width: 16,
                                        height: 25,
                                      ),
                                    ),
                                  if ((userData != null &&
                                          userData!.metaRequest != null) ||
                                      (userData != null &&
                                          userData!.onTripRequest != null))
                                    (userData != null &&
                                            userData!.metaRequest != null)
                                        ? fm.Marker(
                                            width: 100,
                                            height: 20,
                                            alignment: Alignment.topCenter,
                                            point: fmlt.LatLng(
                                                userData!
                                                    .metaRequest!.pickLat,
                                                userData!
                                                    .metaRequest!.pickLng),
                                            // child: MarkerWidget(
                                            //   text: userData!
                                            //       .metaRequest!.pickAddress)
                                            child: Image.asset(
                                              AppImages.pickupIcon,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        : fm.Marker(
                                            width: 100,
                                            height: 30,
                                            alignment: Alignment.topCenter,
                                            point: fmlt.LatLng(
                                                userData!
                                                    .onTripRequest!.pickLat,
                                                userData!
                                                    .onTripRequest!.pickLng),
                                            // child: MarkerWidget(
                                            //   text: userData!
                                            //       .onTripRequest!.pickAddress,
                                            // )
                                            child: Image.asset(
                                              AppImages.pickupIcon,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                  if ((userData != null &&
                                          userData!.metaRequest != null &&
                                          userData!
                                                  .metaRequest!.dropAddress !=
                                              null &&
                                          userData!.metaRequest!.requestStops
                                              .isEmpty) ||
                                      (userData != null &&
                                          userData!.onTripRequest != null &&
                                          userData!.onTripRequest!
                                                  .dropAddress !=
                                              null &&
                                          userData!.onTripRequest!
                                              .requestStops.isEmpty))
                                    (userData != null &&
                                            userData!.metaRequest != null &&
                                            userData!.metaRequest!
                                                    .dropAddress !=
                                                null)
                                        ? fm.Marker(
                                            width: 100,
                                            height: 30,
                                            alignment: Alignment.topCenter,
                                            point: fmlt.LatLng(
                                                userData!
                                                    .metaRequest!.dropLat!,
                                                userData!
                                                    .metaRequest!.dropLng!),
                                            // child: MarkerWidget(
                                            //   text: userData!
                                            //       .metaRequest!.dropAddress!,
                                            // )
                                            child: Image.asset(
                                              AppImages.dropIcon,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        : fm.Marker(
                                            width: 100,
                                            height: 30,
                                            alignment: Alignment.topCenter,
                                            point: fmlt.LatLng(
                                                userData!
                                                    .onTripRequest!.dropLat!,
                                                userData!
                                                    .onTripRequest!.dropLng!),
                                            // child: MarkerWidget(
                                            //   text: userData!
                                            //       .onTripRequest!.dropAddress!,
                                            // )
                                            child: Image.asset(
                                              AppImages.dropIcon,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                  if ((userData != null &&
                                      userData!.metaRequest != null &&
                                      userData!.metaRequest!.requestStops
                                          .isNotEmpty))
                                    for (var i = 0;
                                        i <
                                            userData!.metaRequest!
                                                .requestStops.length;
                                        i++)
                                      fm.Marker(
                                        width: 100,
                                        height: 30,
                                        alignment: Alignment.center,
                                        point: fmlt.LatLng(
                                            userData!.metaRequest!
                                                .requestStops[i]['latitude'],
                                            userData!.metaRequest!
                                                    .requestStops[i]
                                                ['longitude']),
                                        // child: MarkerWidget(
                                        //   text: userData!.metaRequest!
                                        //       .requestStops[i]['address'],
                                        // )
                                        child: Image.asset(
                                          (i == 0)
                                              ? AppImages.stopOne
                                              : (i == 1)
                                                  ? AppImages.stopTwo
                                                  : (i == 2)
                                                      ? AppImages.stopThree
                                                      : AppImages.stopFour,
                                          height: 15,
                                          width: 15,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                  if (userData != null &&
                                      userData!.onTripRequest != null &&
                                      userData!.onTripRequest!.requestStops
                                          .isNotEmpty)
                                    for (var i = 0;
                                        i <
                                            userData!.onTripRequest!
                                                .requestStops.length;
                                        i++)
                                      fm.Marker(
                                        width: 100,
                                        height: 30,
                                        alignment: Alignment.center,
                                        point: fmlt.LatLng(
                                            userData!.onTripRequest!
                                                .requestStops[i]['latitude'],
                                            userData!.onTripRequest!
                                                    .requestStops[i]
                                                ['longitude']),
                                        // child: MarkerWidget(
                                        //   text: userData!.onTripRequest!
                                        //       .requestStops[i]['address'],
                                        // )
                                        child: Image.asset(
                                          (i == 0)
                                              ? AppImages.stopOne
                                              : (i == 1)
                                                  ? AppImages.stopTwo
                                                  : (i == 2)
                                                      ? AppImages.stopThree
                                                      : AppImages.stopFour,
                                          height: 15,
                                          width: 15,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                ])
                              ],
                            ),
                    if (context.read<HomeBloc>().showGetDropAddress &&
                        context.read<HomeBloc>().polyline.isEmpty) ...[
                      Positioned(
                          top: (size.height - size.width * 0.72) / 2,
                          child: SizedBox(
                              width: size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AvatarGlow(
                                    glowRadiusFactor: 1.0,
                                    glowColor: AppColors.primary,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          bottom: size.width * 0.075),
                                      child: Image.asset(
                                        AppImages.pickupIcon,
                                        height: 20,
                                        width: 20,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ))),
                      if (confirmPinAddress)
                      Positioned(
                        top: (size.height - size.width) / 2,
                        right: size.width * 0.38,
                        child: Container(
                          height: size.height * 0.8,
                          alignment: Alignment.center,
                          child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: size.width * 0.6 + 25),
                              child: Row(
                                children: [
                                  CustomButton(
                                      height: size.width * 0.08,
                                      width: size.width * 0.25,
                                      onTap: () {
                                        set(() {
                                          confirmPinAddress = false;
                                        });
                                        if (mapPoint != null) {
                                          context.read<HomeBloc>().add(
                                              GeocodingLatLngEvent(
                                                  lat: mapPoint!
                                                      .latitude,
                                                  lng: mapPoint!
                                                      .longitude));
                                        }
                                      },
                                      textSize: 12,
                                      buttonName:
                                          AppLocalizations.of(context)!
                                              .confirm)
                                ],
                              )),
                        ),
                      ),
                    ],
                    if (context.read<HomeBloc>().autoSuggestionSearching ||
                        context
                            .read<HomeBloc>()
                            .autoCompleteAddress
                            .isNotEmpty)
                      Positioned(
                        top: 0,
                        child: Container(
                          height: size.height,
                          width: size.width,
                          padding: EdgeInsets.all(size.width * 0.05),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).padding.top +
                                    size.width * 0.15,
                              ),
                              SizedBox(
                                width: size.width * 0.9,
                                child: MyText(
                                  text: (context
                                          .read<HomeBloc>()
                                          .autoSuggestionSearching)
                                      ? AppLocalizations.of(context)!
                                          .searching
                                      : AppLocalizations.of(context)!
                                          .searchResult,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(height: size.width * 0.05),
                              Expanded(
                                  child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    for (var i = 0;
                                        i <
                                            context
                                                .read<HomeBloc>()
                                                .autoCompleteAddress
                                                .length;
                                        i++)
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            final address = context
                                                .read<HomeBloc>()
                                                .autoCompleteAddress[i];

                                            if (mapType == 'google_map') {
                                              context.read<HomeBloc>().add(
                                                  GeocodingAddressEvent(
                                                      placeId:
                                                          address.placeId,
                                                      address:
                                                          address.address!));
                                            } else {
                                              if (address.lat != null &&
                                                  address.lon != null &&
                                                  double.tryParse(address.lat
                                                          .toString()) !=
                                                      null &&
                                                  double.tryParse(address.lon
                                                          .toString()) !=
                                                      null) {
                                                context.read<HomeBloc>().add(
                                                    GeocodingAddressEvent(
                                                        placeId:
                                                            address.placeId,
                                                        address: address
                                                            .displayName!,
                                                        position: LatLng(
                                                          double.parse(address
                                                              .lat
                                                              .toString()),
                                                          double.parse(address
                                                              .lon
                                                              .toString()),
                                                        )));
                                              } else {
                                                debugPrint(
                                                    "Invalid latitude or longitude for address: ${address.displayName}");
                                              }
                                            }
                                          },
                                          child: Container(
                                            width: size.width * 0.9,
                                            padding: EdgeInsets.fromLTRB(
                                                0,
                                                size.width * 0.05,
                                                0,
                                                size.width * 0.05),
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: AppColors
                                                            .darkGrey))),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: size.width * 0.07,
                                                  height: size.width * 0.07,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              AppColors.grey),
                                                  child: Icon(
                                                    Icons.location_on_sharp,
                                                    size: size.width * 0.05,
                                                    color: AppColors.darkGrey,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.05,
                                                ),
                                                Expanded(
                                                    child: MyText(
                                                  text: (mapType ==
                                                          'google_map')
                                                      ? context
                                                          .read<HomeBloc>()
                                                          .autoCompleteAddress[
                                                              i]
                                                          .address
                                                      : context
                                                          .read<HomeBloc>()
                                                          .autoCompleteAddress[
                                                              i]
                                                          .displayName,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color: AppColors
                                                              .darkGrey,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w400),
                                                  maxLines: 5,
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                    if (context.read<HomeBloc>().choosenRide != null)
                      Positioned(
                        top: MediaQuery.of(context).padding.top +
                            size.width * 0.05,
                        left: size.width * 0.05,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context).shadowColor,
                                    spreadRadius: 1,
                                    blurRadius: 1)
                              ]),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                context
                                    .read<HomeBloc>()
                                    .add(RemoveChoosenRideEvent());
                              },
                              child: Container(
                                height: size.width * 0.1,
                                width: size.width * 0.1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  size: size.width * 0.07,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (userData != null && userData!.role == 'owner')
                      ClipPath(
                        clipper: ShapePainter(),
                        child: Container(
                          height: size.width * 0.75,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              image: const DecorationImage(
                                  alignment: Alignment.topCenter,
                                  image: AssetImage(AppImages.map))),
                        ),
                      ),
                    if (userData != null && userData!.role == 'owner')
                      Positioned(
                          top: size.width * 0.3,
                          child: Container(
                              margin: EdgeInsets.only(
                                  left: size.width * 0.075,
                                  right: size.width * 0.075),
                              padding: EdgeInsets.all(size.width * 0.015),
                              height: size.width * 0.15,
                              width: size.width * 0.85,
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).dividerColor)),
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: size.width * 0.02,
                                    right: size.width * 0.02),
                                decoration: BoxDecoration(
                                  color: AppColors.darkGrey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        context
                                            .read<HomeBloc>()
                                            .add(ChooseCarMenuEvent(menu: 1));
                                      },
                                      child: Container(
                                          width: size.width * 0.24,
                                          padding: EdgeInsets.all(
                                              size.width * 0.01),
                                          decoration: BoxDecoration(
                                            color: (context
                                                        .read<HomeBloc>()
                                                        .choosenCarMenu ==
                                                    1)
                                                ? AppColors.green
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: MyText(
                                            text:
                                                AppLocalizations.of(context)!
                                                    .onlineSmall,
                                            textStyle: TextStyle(
                                              fontSize:
                                                  (choosenLanguage == 'ta')
                                                      ? 11
                                                      : 14,
                                              fontWeight: FontWeight.bold,
                                              color: (context
                                                          .read<HomeBloc>()
                                                          .choosenCarMenu ==
                                                      1)
                                                  ? AppColors.white
                                                  : AppColors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        context
                                            .read<HomeBloc>()
                                            .add(ChooseCarMenuEvent(menu: 2));
                                      },
                                      child: Container(
                                          width: size.width * 0.24,
                                          padding: EdgeInsets.all(
                                              size.width * 0.01),
                                          decoration: BoxDecoration(
                                            color: (context
                                                        .read<HomeBloc>()
                                                        .choosenCarMenu ==
                                                    2)
                                                ? AppColors.red
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: MyText(
                                            text:
                                                AppLocalizations.of(context)!
                                                    .offlineSmall,
                                            textStyle: TextStyle(
                                              fontSize:
                                                  (choosenLanguage == 'ta')
                                                      ? 11
                                                      : 14,
                                              fontWeight: FontWeight.bold,
                                              color: (context
                                                          .read<HomeBloc>()
                                                          .choosenCarMenu ==
                                                      2)
                                                  ? AppColors.white
                                                  : AppColors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        context
                                            .read<HomeBloc>()
                                            .add(ChooseCarMenuEvent(menu: 3));
                                      },
                                      child: Container(
                                          width: size.width * 0.24,
                                          padding: EdgeInsets.all(
                                              size.width * 0.01),
                                          decoration: BoxDecoration(
                                            color: (context
                                                        .read<HomeBloc>()
                                                        .choosenCarMenu ==
                                                    3)
                                                ? Colors.orange
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: MyText(
                                            text:
                                                AppLocalizations.of(context)!
                                                    .onrideSmall,
                                            textStyle: TextStyle(
                                              fontSize:
                                                  (choosenLanguage == 'ta')
                                                      ? 11
                                                      : 14,
                                              fontWeight: FontWeight.bold,
                                              color: (context
                                                          .read<HomeBloc>()
                                                          .choosenCarMenu ==
                                                      3)
                                                  ? AppColors.white
                                                  : AppColors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                  ],
                                ),
                              ))),
                    if (userData != null &&
                        userData!.role == 'driver' &&
                        userData!.metaRequest == null &&
                        userData!.onTripRequest == null)
                      Positioned(
                          top: 0,
                          child: Container(
                            width: size.width,
                            padding: EdgeInsets.all(size.width * 0.05),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).padding.top,
                                ),
                                Row(
                                  children: [
                                    (context.read<HomeBloc>().choosenRide !=
                                                null ||
                                            context
                                                .read<HomeBloc>()
                                                .showGetDropAddress)
                                        ? InkWell(
                                            onTap: () {
                                              if (context
                                                      .read<HomeBloc>()
                                                      .choosenRide !=
                                                  null) {
                                                context.read<HomeBloc>().add(
                                                    RemoveChoosenRideEvent());
                                              } else if (context
                                                  .read<HomeBloc>()
                                                  .showGetDropAddress) {
                                                context.read<HomeBloc>().add(
                                                    ShowGetDropAddressEvent());
                                              } else {
                                                Navigator.pushNamed(context,
                                                    AccountPage.routeName,
                                                    arguments:
                                                        AccountPageArguments(
                                                            userData:
                                                                userData!));
                                              }
                                              context
                                                  .read<HomeBloc>()
                                                  .dropAddressController
                                                  .clear();
                                            },
                                            child: Icon(
                                              (context
                                                              .read<
                                                                  HomeBloc>()
                                                              .choosenRide !=
                                                          null ||
                                                      context
                                                          .read<HomeBloc>()
                                                          .showGetDropAddress)
                                                  ? Icons.arrow_back
                                                  : Icons.menu,
                                              size: size.width * 0.07,
                                              color: Theme.of(context).primaryColorDark,
                                            ),
                                          )
                                        : SizedBox(
                                            width: size.width * 0.07,
                                          ),
                                    (context
                                            .read<HomeBloc>()
                                            .showGetDropAddress)
                                        ? Row(
                                            children: [
                                              SizedBox(
                                                width: size.width * 0.05,
                                              ),
                                              SizedBox(
                                                width: size.width * 0.7,
                                                height: size.width * 0.1,
                                                child: CustomTextField(
                                                  controller: context
                                                      .read<HomeBloc>()
                                                      .dropAddressController,
                                                  fillColor: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                  filled: true,
                                                  hintText:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .searchPlace,
                                                  onChange: (v) {
                                                    context
                                                        .read<HomeBloc>()
                                                        .debouncer
                                                        .run(() {
                                                      if (v.length >= 4) {
                                                        context
                                                            .read<HomeBloc>()
                                                            .add(GetAutoCompleteAddressEvent(
                                                                searchText:
                                                                    v));
                                                      } else if (v.isEmpty) {
                                                        context
                                                            .read<HomeBloc>()
                                                            .add(
                                                                ClearAutoCompleteEvent());
                                                      }
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          )
                                        : Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ((userData!.driverMode !=
                                                                'subscription' &&
                                                            ((userData!.ownerId ==
                                                                        null &&
                                                                    userData!
                                                                            .lowBalance ==
                                                                        false) ||
                                                                (userData!.ownerId !=
                                                                        null &&
                                                                    userData!
                                                                            .vehicleTypeName !=
                                                                        '' &&
                                                                    userData!
                                                                            .lowBalance ==
                                                                        false))) ||
                                                        (userData!.driverMode ==
                                                                'subscription' &&
                                                            (userData!.ownerId !=
                                                                    null &&
                                                                userData!
                                                                        .vehicleTypeName !=
                                                                    '')))
                                                    ? AnimatedToggleSwitch<
                                                        bool>.dual(
                                                        current:
                                                            userData!.active,
                                                        first: false,
                                                        second: true,
                                                        spacing:
                                                            size.width * 0.1,
                                                        borderWidth: 2.0,
                                                        height:
                                                            size.width * 0.12,
                                                        onChanged: (value) {
                                                          if (value ==
                                                              false) {
                                                            set(() {
                                                              userData!
                                                                      .active =
                                                                  false;
                                                            });
                                                            // Check if switching to offline
                                                            showDialog(
                                                              barrierDismissible:
                                                                  false,
                                                              context:
                                                                  context,
                                                              builder:
                                                                  (BuildContext
                                                                      ctx) {
                                                                return CustomDoubleButtonDialoge(
                                                                  title: AppLocalizations.of(
                                                                          context)!
                                                                      .confirmation,
                                                                  content: AppLocalizations.of(
                                                                          context)!
                                                                      .offlineConfirmation,
                                                                  yesBtnName:
                                                                      AppLocalizations.of(context)!
                                                                          .confirm,
                                                                  noBtnName: AppLocalizations.of(
                                                                          context)!
                                                                      .cancel,
                                                                  yesBtnFunc:
                                                                      () {
                                                                    context
                                                                        .read<
                                                                            HomeBloc>()
                                                                        .add(
                                                                            ChangeOnlineOfflineEvent());
                                                                    Navigator
                                                                        .pop(
                                                                            ctx);
                                                                  },
                                                                  noBtnFunc:
                                                                      () {
                                                                    set(() {
                                                                      userData!.active =
                                                                          true;
                                                                    });
                                                                    Navigator
                                                                        .pop(
                                                                            ctx);
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            userData!.active =
                                                                value;
                                                            context
                                                                .read<
                                                                    HomeBloc>()
                                                                .add(
                                                                    ChangeOnlineOfflineEvent());
                                                          }
                                                        },
                                                        style:
                                                            const ToggleStyle(
                                                          borderColor: Colors
                                                              .transparent,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              spreadRadius: 1,
                                                              blurRadius: 2,
                                                              offset: Offset(
                                                                  0, 1.5),
                                                            ),
                                                          ],
                                                        ),
                                                        styleBuilder:
                                                            (value) =>
                                                                ToggleStyle(
                                                          indicatorColor: value
                                                              ? const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  117,
                                                                  218,
                                                                  0)
                                                              : AppColors.red,
                                                        ),
                                                        indicatorSize:
                                                            const Size(
                                                                40, 40),
                                                        iconBuilder:
                                                            (value) => value
                                                                ? Icon(
                                                                    Icons
                                                                        .done,
                                                                    size: size
                                                                            .width *
                                                                        0.05,
                                                                    color: AppColors
                                                                        .white,
                                                                  )
                                                                : AvatarGlow(
                                                                    glowColor:
                                                                        AppColors
                                                                            .red,
                                                                    animate:
                                                                        true,
                                                                    child:
                                                                        Material(
                                                                      elevation:
                                                                          8.0,
                                                                      shape:
                                                                          const CircleBorder(),
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            AppColors.red,
                                                                        radius:
                                                                            50.0,
                                                                        child:
                                                                            Icon(
                                                                          Icons.arrow_forward_ios,
                                                                          size:
                                                                              size.width * 0.05,
                                                                          color:
                                                                              AppColors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                        textBuilder:
                                                            (value) => Center(
                                                          child: MyText(
                                                            text: value
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .onlineCaps
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .offlineCaps,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  color: value
                                                                      ? const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          117,
                                                                          218,
                                                                          0)
                                                                      : AppColors
                                                                          .red,
                                                                  fontSize:
                                                                      14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                      )
                                                    : (userData!.vehicleTypeName ==
                                                            '')
                                                        ? Container(
                                                            width:
                                                                size.width *
                                                                    0.32,
                                                            height:
                                                                size.width *
                                                                    0.11,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        3,
                                                                    vertical:
                                                                        2),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                              color: AppColors
                                                                  .white,
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  height: size
                                                                          .width *
                                                                      0.09,
                                                                  width: size
                                                                          .width *
                                                                      0.09,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(5),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppColors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                  ),
                                                                  child:
                                                                      Image(
                                                                    image: AssetImage(
                                                                        AppImages
                                                                            .lock),
                                                                    height: size
                                                                            .width *
                                                                        0.08,
                                                                    width: size
                                                                            .width *
                                                                        0.08,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      size.width *
                                                                          0.2,
                                                                  child:
                                                                      MyText(
                                                                    text: AppLocalizations.of(
                                                                            context)!
                                                                        .fleetsUnassigned,
                                                                    textStyle: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    maxLines:
                                                                        2,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        : SizedBox(
                                                            width:
                                                                size.width *
                                                                    0.6,
                                                            child: MyText(
                                                                text: AppLocalizations.of(
                                                                        context)!
                                                                    .lowBalance,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                textStyle: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium!
                                                                    .copyWith(
                                                                        color: AppColors
                                                                            .primary,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w600)),
                                                          ),
                                                if (!userData!.active)
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.07),
                                              ],
                                            ),
                                          ),
                                    // SizedBox(width: size.width * 0.07),
                                    if (userData!.active != false &&
                                        userData!.hasLater == true)
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, HistoryPage.routeName,
                                              arguments:
                                                  HistoryAccountPageArguments(
                                                      isFrom: 'home'));
                                        },
                                        child: AvatarGlow(
                                          glowColor: AppColors.primary
                                              .withOpacity(0.7),
                                          animate: true,
                                          child: Material(
                                            elevation: 3.0,
                                            shape: const CircleBorder(),
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Theme.of(context)
                                                      .primaryColor,
                                              radius: 17.0,
                                              child: Image.asset(
                                                AppImages.upComingRides,
                                                height: size.width * 0.1,
                                                width: 200,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          )),
                    if (context.read<HomeBloc>().autoSuggestionSearching ==
                            false &&
                        context.read<HomeBloc>().autoCompleteAddress.isEmpty)
                      Positioned(
                          right: (languageDirection == 'rtl')
                              ? null
                              : size.width * 0.05,
                          left: (languageDirection == 'ltr')
                              ? null
                              : size.width * 0.05,
                          bottom: (userData != null &&
                                  context
                                          .read<HomeBloc>()
                                          .showGetDropAddress ==
                                      false &&
                                  userData!.metaRequest == null &&
                                  userData!.onTripRequest == null &&
                                  userData!.role == 'driver')
                              ? size.width * 0.75
                              : size.height * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (userData != null &&
                                  userData!.onTripRequest != null &&
                                  userData!.onTripRequest!.isTripStart == 1)
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context)
                                                    .shadowColor,
                                                spreadRadius: 1,
                                                blurRadius: 1)
                                          ]),
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        color: AppColors.white,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (builder) {
                                                  return AlertDialog(
                                                    content: Container(
                                                      height: size.width,
                                                      width: size.width * 0.9,
                                                      padding: EdgeInsets.all(
                                                          size.width * 0.05),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            InkWell(
                                                              onTap:
                                                                  () async {
                                                                await FirebaseDatabase
                                                                    .instance
                                                                    .ref()
                                                                    .child(
                                                                        'SOS/${userData!.onTripRequest!.id}')
                                                                    .update({
                                                                  "is_driver":
                                                                      "1",
                                                                  "is_user":
                                                                      "0",
                                                                  "req_id":
                                                                      userData!
                                                                          .onTripRequest!
                                                                          .id,
                                                                  "serv_loc_id":
                                                                      userData!
                                                                          .serviceLocationId,
                                                                  "updated_at":
                                                                      ServerValue
                                                                          .timestamp
                                                                });
                                                                showToast(
                                                                    message: AppLocalizations.of(
                                                                            context)!
                                                                        .notifiedToAdmin);
                                                              },
                                                              child: SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.8,
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          MyText(
                                                                        text:
                                                                            AppLocalizations.of(context)!.notifyAdmin,
                                                                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                                            color: Theme.of(context).primaryColorDark,
                                                                            fontSize: 14,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .notification_add,
                                                                      size: size.width *
                                                                          0.07,
                                                                      color: Theme.of(context)
                                                                          .primaryColorDark,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  size.width *
                                                                      0.05,
                                                            ),
                                                            Column(
                                                              children: [
                                                                for (var i =
                                                                        0;
                                                                    i <
                                                                        userData!
                                                                            .sos!
                                                                            .data
                                                                            .length;
                                                                    i++)
                                                                  InkWell(
                                                                    onTap:
                                                                        () {
                                                                      context
                                                                          .read<HomeBloc>()
                                                                          .add(OpenAnotherFeatureEvent(value: 'tel:${userData!.sos!.data[i].number}'));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: size.width *
                                                                          0.8,
                                                                      padding: EdgeInsets.fromLTRB(
                                                                          0,
                                                                          size.width *
                                                                              0.025,
                                                                          0,
                                                                          size.width *
                                                                              0.025),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                MyText(
                                                                                  text: userData!.sos!.data[i].name,
                                                                                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColorDark, fontSize: 14, fontWeight: FontWeight.w400),
                                                                                ),
                                                                                MyText(
                                                                                  text: userData!.sos!.data[i].number,
                                                                                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColorDark, fontSize: 14, fontWeight: FontWeight.w400),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Icon(
                                                                            Icons.call,
                                                                            size: size.width * 0.07,
                                                                            color: Theme.of(context).primaryColorDark,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Container(
                                            height: size.width * 0.1,
                                            width: size.width * 0.1,
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.sos,
                                              size: size.width * 0.07,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.width * 0.05,
                                    )
                                  ],
                                ),
                              (userData != null &&
                                      userData!.onTripRequest != null &&
                                      userData!.onTripRequest!.acceptedAt !=
                                          null &&
                                      userData!.onTripRequest!.dropAddress !=
                                          null)
                                  ? Row(
                                      children: [
                                        (userData != null &&
                                                context
                                                        .read<HomeBloc>()
                                                        .navigationType ==
                                                    true)
                                            ? Container(
                                                padding: EdgeInsets.all(
                                                    size.width * 0.02),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: AppColors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Theme.of(
                                                                  context)
                                                              .shadowColor,
                                                          spreadRadius: 1,
                                                          blurRadius: 1)
                                                    ]),
                                                child: Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (userData!
                                                                .onTripRequest!
                                                                .isTripStart ==
                                                            0) {
                                                          context
                                                              .read<
                                                                  HomeBloc>()
                                                              .add(OpenAnotherFeatureEvent(
                                                                  value:
                                                                      '${ApiEndpoints.openMap}${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}'));
                                                        } else {
                                                          context
                                                              .read<
                                                                  HomeBloc>()
                                                              .add(OpenAnotherFeatureEvent(
                                                                  value:
                                                                      '${ApiEndpoints.openMap}${userData!.onTripRequest!.dropLat},${userData!.onTripRequest!.dropLng}'));
                                                        }
                                                      },
                                                      child: SizedBox(
                                                        width:
                                                            size.width * 0.07,
                                                        child: Image.asset(
                                                          AppImages
                                                              .googleMaps,
                                                          height: size.width *
                                                              0.07,
                                                          width: 200,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          size.width * 0.02,
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        var browseUrl = (userData!
                                                                    .onTripRequest!
                                                                    .isTripStart ==
                                                                0)
                                                            ? 'https://waze.com/ul?ll=${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}&navigate=yes'
                                                            : 'https://waze.com/ul?ll=${userData!.onTripRequest!.dropLat},${userData!.onTripRequest!.dropLng}&navigate=yes';
                                                        if (browseUrl
                                                            .isNotEmpty) {
                                                          await launchUrl(
                                                              Uri.parse(
                                                                  browseUrl));
                                                        } else {
                                                          throw 'Could not launch $browseUrl';
                                                        }
                                                      },
                                                      child: SizedBox(
                                                        width:
                                                            size.width * 0.07,
                                                        child: Image.asset(
                                                          AppImages.wazeMap,
                                                          height: size.width *
                                                              0.07,
                                                          width: 200,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          width: size.width * 0.01,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: AppColors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Theme.of(context)
                                                        .shadowColor,
                                                    spreadRadius: 1,
                                                    blurRadius: 1)
                                              ]),
                                          child: Material(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: AppColors.white,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () {
                                                if (userData!.enableWazeMap ==
                                                    '1') {
                                                  context.read<HomeBloc>().add(
                                                      NavigationTypeEvent());
                                                } else {
                                                  if (userData!.onTripRequest!
                                                          .isTripStart ==
                                                      0) {
                                                    context.read<HomeBloc>().add(
                                                        OpenAnotherFeatureEvent(
                                                            value:
                                                                '${ApiEndpoints.openMap}${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}'));
                                                  } else {
                                                    context.read<HomeBloc>().add(
                                                        OpenAnotherFeatureEvent(
                                                            value:
                                                                '${ApiEndpoints.openMap}${userData!.onTripRequest!.dropLat},${userData!.onTripRequest!.dropLng}'));
                                                  }
                                                }
                                              },
                                              child: Container(
                                                height: size.width * 0.1,
                                                width: size.width * 0.1,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                  color: AppColors.white,
                                                ),
                                                child: Icon(
                                                  Icons.near_me_rounded,
                                                  size: size.width * 0.07,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                height: size.width * 0.025,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Theme.of(context).shadowColor,
                                          spreadRadius: 1,
                                          blurRadius: 1)
                                    ]),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.white,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () async {
                                      PermissionStatus status =
                                          await Permission.location.status;
                                      if (status.isGranted ||
                                          status.isLimited) {
                                        if (mapType == 'google_map') {
                                          if (context
                                                  .read<HomeBloc>()
                                                  .googleMapController !=
                                              null) {
                                            context
                                                .read<HomeBloc>()
                                                .googleMapController!
                                                .moveCamera(
                                                    CameraUpdate.newLatLng(
                                                        context
                                                            .read<HomeBloc>()
                                                            .currentLatLng!));
                                          }
                                        } else {
                                          context
                                              .read<HomeBloc>()
                                              .fmController
                                              .move(
                                                  fmlt.LatLng(
                                                      context
                                                          .read<HomeBloc>()
                                                          .currentLatLng!
                                                          .latitude,
                                                      context
                                                          .read<HomeBloc>()
                                                          .currentLatLng!
                                                          .longitude),
                                                  13);
                                        }
                                      } else {
                                        context
                                            .read<HomeBloc>()
                                            .add(GetCurrentLocationEvent());
                                      }
                                    },
                                    child: Container(
                                      height: size.width * 0.1,
                                      width: size.width * 0.1,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        color: AppColors.white,
                                      ),
                                      child: Icon(
                                        Icons.my_location_sharp,
                                        size: size.width * 0.07,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    if (userData != null &&
                        userData!.role == 'driver' &&
                        userData!.metaRequest == null &&
                        userData!.onTripRequest == null &&
                        context.read<HomeBloc>().choosenRide == null &&
                        context.read<HomeBloc>().showGetDropAddress == false)
                      AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          bottom: (bottomSize == size.height)
                              ? 0 + size.width * 0.25
                              : -((size.height - size.width * 0.65) -
                                  bottomSize),
                          child: GestureDetector(
                            onVerticalDragUpdate: (v) {
                              set(() {
                                bottomSize = (v.primaryDelta! < 0.0)
                                    ? (bottomSize <
                                            (size.height - size.width * 0.30))
                                        ? bottomSize +
                                            ((v.primaryDelta! * -1))
                                        : bottomSize
                                    : bottomSize - ((v.primaryDelta!));

                                if (bottomSize > 250 &&
                                    _animatedWidget !=
                                        quickActions(size, context, set)) {
                                  _animatedWidget =
                                      quickActions(size, context, set);
                                } else if (bottomSize <= 250 &&
                                    (_animatedWidget != null ||
                                        _animatedWidget !=
                                            earningsWidget(size, context))) {
                                  _animatedWidget =
                                      earningsWidget(size, context);
                                }
                                // }
                              });
                            },
                            onVerticalDragEnd: (v) {
                              set(() {
                                if (bottomSize > 250) {
                                  bottomSize =
                                      size.height - size.width * 0.65;
                                  _animatedWidget =
                                      quickActions(size, context, set);
                                } else {
                                  bottomSize = 0.0;
                                  _animatedWidget =
                                      earningsWidget(size, context);
                                }
                              });
                            },
                            child: Container(
                              width: size.width,
                              height: size.height,
                              padding: EdgeInsets.all((bottomSize <= 250)
                                  ? size.width * 0.05
                                  : 0),
                              decoration: BoxDecoration(
                                  borderRadius: (bottomSize <= 250)
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(
                                              size.width * 0.1),
                                          topRight: Radius.circular(
                                              size.width * 0.1))
                                      : BorderRadius.circular(0),
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: (_animatedWidget == null)
                                      ? earningsWidget(size, context)
                                      : _animatedWidget!),
                            ),
                          )),
                    if (userData != null &&
                        context.read<HomeBloc>().isBiddingEnabled == true &&
                        context.read<HomeBloc>().choosenRide == null &&
                        userData!.onTripRequest == null &&
                        userData!.metaRequest == null &&
                        context.read<HomeBloc>().showGetDropAddress ==
                            false &&
                        userData!.active &&
                        bottomSize == 0.0)
                      AnimatedPositioned(
                        right: 0,
                        top: bidRideTop,
                        duration: const Duration(milliseconds: 250),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(right: size.width * 0.05),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context).shadowColor,
                                        spreadRadius: 1,
                                        blurRadius: 1)
                                  ]),
                              child: Material(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.white,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    set(() {
                                      if (bidRideTop ==
                                          (size.height - size.width * 0.2) -
                                              (size.width * 0.8)) {
                                        bidRideTop = MediaQuery.of(context)
                                                .padding
                                                .top +
                                            size.width * 0.05;
                                      } else {
                                        bidRideTop =
                                            (size.height - size.width * 0.2) -
                                                (size.width * 0.8);
                                      }
                                    });
                                    context
                                        .read<HomeBloc>()
                                        .add(ShowBiddingPageEvent());
                                  },
                                  child: Container(
                                    height: size.width * 0.1,
                                    width: size.width * 0.1,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.white,
                                    ),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      AppImages.biddingCar,
                                      width: size.width * 0.07,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                                firstChild: Container(),
                                secondChild:
                                    biddingRideListWidget(size, context),
                                crossFadeState: (bidRideTop ==
                                        (size.height - size.width * 0.2) -
                                            (size.width * 0.8))
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: const Duration(milliseconds: 250))
                          ],
                        ),
                      ),
                    if (context.read<HomeBloc>().showGetDropAddress)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          height: size.width * 0.5,
                          padding: EdgeInsets.all(size.width * 0.05),
                          width: size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MyText(
                                text: context.read<HomeBloc>().dropAddress,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                maxLines: 4,
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                              CustomButton(
                                  buttonName: AppLocalizations.of(context)!
                                      .confirmLocation,
                                  onTap: () {
                                    context
                                        .read<HomeBloc>()
                                        .add(GetEtaRequestEvent());
                                  })
                            ],
                          ),
                        ),
                      ),
                    if (userData != null && userData!.metaRequest != null)
                      Positioned(
                          bottom: 0,
                          child: acceptRejectWidget(size, context)),
                    if (context.read<HomeBloc>().choosenRide != null &&
                        (context.read<HomeBloc>().outStationList.isNotEmpty ||
                            context.read<HomeBloc>().rideList.isNotEmpty))
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: size.width,
                          padding: EdgeInsets.all(size.width * 0.05),
                          decoration: BoxDecoration(
                              color:
                                  Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              )),
                          child: Column(
                            children: [
                              (context.read<HomeBloc>().choosenRide != null &&
                                      context
                                          .read<HomeBloc>()
                                          .showOutstationWidget &&
                                      context
                                          .read<HomeBloc>()
                                          .outStationList
                                          .isNotEmpty)
                                  ? outstationRequestWidget(context, size)
                                  : biddingRequestWidget(size, context),
                            ],
                          ),
                        ),
                      ),
                    if (userData != null && (userData!.onTripRequest != null))
                      Positioned(
                          bottom: 0,
                          child: SizedBox(
                            height: size.height,
                            width: size.width,
                            child: DraggableScrollableSheet(

                                // controller: controller,
                                initialChildSize:
                                    0.45, // Start at half screen
                                minChildSize: 0.4, // Minimum height
                                maxChildSize: 1.0,
                                builder: (BuildContext ctx,
                                    ScrollController scrollController) {
                                  return Container(
                                    height: size.height,
                                    width: size.width,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30))),
                                    child: SingleChildScrollView(
                                        controller: scrollController,
                                        child: (userData != null &&
                                                userData?.onTripRequest !=
                                                    null)
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            30)),
                                                child: onRideWidget(
                                                    size, context))
                                            : Container()),
                                  );
                                }),
                          ))
                  ],
                )
              : (context.read<HomeBloc>().choosenMenu == 1)
                  ? (userData!.role == 'driver')
                      ? const LeaderboardPage()
                      : OwnerDashboard(
                          args: OwnerDashboardArguments(from: 'home'),
                        )
                  : (context.read<HomeBloc>().choosenMenu == 2)
                      ? const EarningsPage()
                      : AccountPage(
                          arg: AccountPageArguments(userData: userData!),
                        ),

          if (context.read<HomeBloc>().visibleOutStation && userData!.active)
            Positioned(child: biddingoutStationListWidget(size, context)),
          if (context.read<HomeBloc>().showGetDropAddress)
            Positioned(bottom: 0, child: Container()),
          // bidding widget
          if (context.read<HomeBloc>().waitingList.isNotEmpty &&
              !context.read<HomeBloc>().showOutstationWidget)
            Positioned(
                top: 0,
                child: Container(
                  height: size.height,
                  width: size.width,
                  color: Colors.transparent.withOpacity(0.4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.8,
                        padding: EdgeInsets.all(size.width * 0.06),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.white),
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.width * 0.03,
                            ),
                            SizedBox(
                                width: size.width * 0.8,
                                child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .waitingForUserResponse)),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            if (DateTime.now()
                                    .difference(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            context
                                                            .read<HomeBloc>()
                                                            .waitingList[0]
                                                        ['drivers']
                                                    ['driver_${userData!.id}']
                                                ['bid_time']))
                                    .inSeconds <
                                int.parse(userData!
                                    .maximumTimeForFindDriversForBittingRide))
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    painter: CustomTimer(
                                      width: size.width * 0.01,
                                      color: AppColors.white,
                                      backgroundColor: AppColors.primary,
                                      values: (DateTime.now()
                                                  .difference(DateTime.fromMillisecondsSinceEpoch(context
                                                                  .read<HomeBloc>()
                                                                  .waitingList[0]
                                                              ['drivers']
                                                          ['driver_${userData!.id}']
                                                      ['bid_time']))
                                                  .inSeconds <
                                              int.parse(userData!
                                                  .maximumTimeForFindDriversForBittingRide))
                                          ? 1 -
                                              ((int.parse(userData!.maximumTimeForFindDriversForBittingRide) -
                                                      DateTime.now()
                                                          .difference(DateTime.fromMillisecondsSinceEpoch(context.read<HomeBloc>().waitingList[0]['drivers']['driver_${userData!.id}']['bid_time']))
                                                          .inSeconds) /
                                                  int.parse(userData!.maximumTimeForFindDriversForBittingRide))
                                          : 1,
                                    ),
                                    child: Container(
                                      height: size.width * 0.2,
                                      width: size.width * 0.2,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${(int.parse(userData!.maximumTimeForFindDriversForBittingRide) - DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(context.read<HomeBloc>().waitingList[0]['drivers']['driver_${userData!.id}']['bid_time'])).inSeconds).clamp(0, int.parse(userData!.maximumTimeForFindDriversForBittingRide))} s',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: size.width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          if (context.read<HomeBloc>().showChat == true)
            Positioned(top: 0, child: chatPageWidget(size, context)),
          if (context.read<HomeBloc>().showCancelReason == true)
            Positioned(top: 0, child: cancelReasonWidget(size, context)),
          // Showing OTP ente, image pick
          if (context.read<HomeBloc>().showOtp == true ||
              (context.read<HomeBloc>().showImagePick &&
                  userData!.onTripRequest != null) ||
              (context.read<HomeBloc>().showImagePick == true &&
                  userData!.onTripRequest == null))
            Positioned(
                top: 0,
                child: Container(
                  height: size.height,
                  width: size.width,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TopBarDesign(
                    isHistoryPage: false,
                    isOngoingPage: false,
                    title: (userData!.onTripRequest != null &&
                            userData!.onTripRequest!.transportType ==
                                'delivery')
                        ? AppLocalizations.of(context)!.shipmentVerification
                        : AppLocalizations.of(context)!.rideVerification,
                    onTap: () {
                      if (context.read<HomeBloc>().showImagePick) {
                        context.read<HomeBloc>().add(ShowImagePickEvent());
                      } else {
                        context.read<HomeBloc>().add(ShowOtpEvent());
                      }
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.width * 0.2,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  width: size.width * 0.9,
                                  height: size.width * 0.65,
                                  padding: EdgeInsets.all(size.width * 0.05),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withOpacity(0.3),
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .disabledColor)),
                                  child:
                                      (context.read<HomeBloc>().showImagePick)
                                          ? Column(
                                              children: [
                                                SizedBox(
                                                    width: size.width * 0.8,
                                                    child: MyText(
                                                      text: AppLocalizations
                                                              .of(context)!
                                                          .uploadShipmentProof,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: AppColors
                                                                  .blackText,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                                SizedBox(
                                                  height: size.width * 0.05,
                                                ),

                                                // Loading & unloading Image
                                                InkWell(
                                                  onTap: () {
                                                    context.read<HomeBloc>().add(
                                                        ImageCaptureEvent());
                                                  },
                                                  child: SizedBox(
                                                    height: size.width * 0.35,
                                                    width: size.width * 0.35,
                                                    child: DottedBorder(
                                                        color: AppColors.white
                                                            .withOpacity(0.5),
                                                        strokeWidth: 1,
                                                        dashPattern: const [
                                                          6,
                                                          3
                                                        ],
                                                        borderType:
                                                            BorderType.RRect,
                                                        radius: const Radius
                                                            .circular(5),
                                                        child: (context
                                                                        .read<
                                                                            HomeBloc>()
                                                                        .loadImage ==
                                                                    null &&
                                                                context
                                                                        .read<
                                                                            HomeBloc>()
                                                                        .unloadImage ==
                                                                    null)
                                                            ? SizedBox(
                                                                height:
                                                                    size.width *
                                                                        0.35,
                                                                width:
                                                                    size.width *
                                                                        0.35,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .upload,
                                                                      size: size.width *
                                                                          0.05,
                                                                      color: AppColors
                                                                          .black,
                                                                    ),
                                                                    SizedBox(
                                                                      height: size.width *
                                                                          0.025,
                                                                    ),
                                                                    MyText(
                                                                      text: AppLocalizations.of(context)!
                                                                          .dropImageHere,
                                                                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                                          color: AppColors.white.withOpacity(
                                                                              0.5),
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      textAlign:
                                                                          TextAlign.center,
                                                                    ),
                                                                    SizedBox(
                                                                      height: size.width *
                                                                          0.025,
                                                                    ),
                                                                    MyText(
                                                                      text: AppLocalizations.of(context)!
                                                                          .supportedImage
                                                                          .toString()
                                                                          .replaceAll('1111',
                                                                              'jpg,png'),
                                                                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                                          color: AppColors.white.withOpacity(
                                                                              0.5),
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      textAlign:
                                                                          TextAlign.center,
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            : Container(
                                                                height:
                                                                    size.width *
                                                                        0.35,
                                                                width:
                                                                    size.width *
                                                                        0.35,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(5),
                                                                  image: (userData?.onTripRequest ==
                                                                              null ||
                                                                          userData!.onTripRequest!.isTripStart ==
                                                                              0)
                                                                      ? (context.read<HomeBloc>().loadImage !=
                                                                              null
                                                                          ? DecorationImage(
                                                                              image: FileImage(File(context.read<HomeBloc>().loadImage!)),
                                                                              fit: BoxFit.cover)
                                                                          : null)
                                                                      : (context.read<HomeBloc>().unloadImage != null ? DecorationImage(image: FileImage(File(context.read<HomeBloc>().unloadImage!)), fit: BoxFit.cover) : null),
                                                                ),
                                                              )),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.width * 0.05,
                                                )
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                SizedBox(
                                                    height:
                                                        size.width * 0.05),
                                                SizedBox(
                                                    width: size.width * 0.8,
                                                    child: MyText(
                                                      text:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .enterOtp,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: AppColors
                                                                  .blackText,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                                SizedBox(
                                                  height: size.width * 0.05,
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.8,
                                                    child: MyText(
                                                      text: AppLocalizations
                                                              .of(context)!
                                                          .enterRideOtpDesc,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: AppColors
                                                                  .blackText,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                      maxLines: 4,
                                                    )),
                                                SizedBox(
                                                  height: size.width * 0.05,
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.7,
                                                  child: pincodeanime
                                                      .PinCodeTextField(
                                                    appContext: (context),
                                                    length: 4,
                                                    controller: context
                                                        .read<HomeBloc>()
                                                        .rideOtp,
                                                    textStyle: Theme.of(
                                                            context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor),
                                                    obscureText: false,
                                                    blinkWhenObscuring: false,
                                                    animationType:
                                                        pincodeanime
                                                            .AnimationType
                                                            .fade,
                                                    pinTheme:
                                                        pincodeanime.PinTheme(
                                                      shape: pincodeanime
                                                          .PinCodeFieldShape
                                                          .box,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                      fieldHeight:
                                                          size.width * 0.13,
                                                      fieldWidth:
                                                          size.width * 0.12,
                                                      activeFillColor: Theme
                                                              .of(context)
                                                          .scaffoldBackgroundColor,
                                                      inactiveFillColor: Theme
                                                              .of(context)
                                                          .scaffoldBackgroundColor,
                                                      inactiveColor:
                                                          Theme.of(context)
                                                              .disabledColor,
                                                      selectedFillColor: Theme
                                                              .of(context)
                                                          .scaffoldBackgroundColor,
                                                      selectedColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      selectedBorderWidth: 1,
                                                      inactiveBorderWidth: 1,
                                                      activeBorderWidth: 1,
                                                      activeColor:
                                                          Theme.of(context)
                                                              .disabledColor,
                                                    ),
                                                    cursorColor:
                                                        Theme.of(context)
                                                            .dividerColor,
                                                    animationDuration:
                                                        const Duration(
                                                            milliseconds:
                                                                300),
                                                    enableActiveFill: true,
                                                    enablePinAutofill: false,
                                                    autoDisposeControllers:
                                                        false,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    boxShadows: const [
                                                      BoxShadow(
                                                        offset: Offset(0, 1),
                                                        color: Colors.black12,
                                                        blurRadius: 10,
                                                      )
                                                    ],
                                                    onChanged: (_) => context
                                                        .read<HomeBloc>()
                                                        .add(UpdateEvent()),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                ),
                                if (userData!.onTripRequest != null &&
                                    userData!.onTripRequest!.isTripStart ==
                                        0 &&
                                    userData!.onTripRequest!.transportType ==
                                        'delivery' &&
                                    userData!.onTripRequest!
                                            .enableShipmentLoad ==
                                        '1' &&
                                    context.read<HomeBloc>().showOtp)
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: size.width * 0.05,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (context
                                                            .read<HomeBloc>()
                                                            .showImagePick ==
                                                        false)
                                                    ? AppColors.primary
                                                    : Theme.of(context)
                                                        .disabledColor),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.015,
                                          ),
                                          Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (context
                                                        .read<HomeBloc>()
                                                        .showImagePick)
                                                    ? AppColors.primary
                                                    : Theme.of(context)
                                                        .disabledColor),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        CustomButton(
                            width: size.width * 0.8,
                            buttonName:
                                AppLocalizations.of(context)!.continueText,
                            onTap: () {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (currentFocus.hasFocus) {
                                currentFocus.unfocus();
                              }
                              if (userData!.onTripRequest != null &&
                                  userData!.onTripRequest!.isTripStart == 0) {
                                if (context
                                        .read<HomeBloc>()
                                        .rideOtp
                                        .text
                                        .isNotEmpty ||
                                    context.read<HomeBloc>().showOtp ==
                                        false) {
                                  if (userData!
                                              .onTripRequest!.transportType ==
                                          'delivery' &&
                                      userData!.onTripRequest!
                                              .enableShipmentLoad ==
                                          '1') {
                                    if (context
                                            .read<HomeBloc>()
                                            .showImagePick ==
                                        false) {
                                      context
                                          .read<HomeBloc>()
                                          .add(ShowImagePickEvent());
                                    } else {
                                      if (userData!.onTripRequest == null ||
                                          userData!.onTripRequest!
                                                  .isTripStart ==
                                              0) {
                                        if (context
                                                .read<HomeBloc>()
                                                .loadImage !=
                                            null) {
                                          if (userData!.onTripRequest ==
                                              null) {
                                            context.read<HomeBloc>().add(
                                                CreateInstantRideEvent());
                                          } else {
                                            context.read<HomeBloc>().add(
                                                UploadProofEvent(
                                                    image: context
                                                        .read<HomeBloc>()
                                                        .loadImage!,
                                                    isBefore: false,
                                                    id: userData!
                                                        .onTripRequest!.id));
                                          }
                                        }
                                      } else {
                                        if (context
                                                .read<HomeBloc>()
                                                .unloadImage !=
                                            null) {
                                          Navigator.pop(context);
                                          context.read<HomeBloc>().add(
                                              UploadProofEvent(
                                                  image: context
                                                      .read<HomeBloc>()
                                                      .unloadImage!,
                                                  isBefore: false,
                                                  id: userData!
                                                      .onTripRequest!.id));
                                        }
                                      }
                                    }
                                  } else {
                                    context.read<HomeBloc>().add(
                                        RideStartEvent(
                                            requestId:
                                                userData!.onTripRequest!.id,
                                            otp: context
                                                .read<HomeBloc>()
                                                .rideOtp
                                                .text,
                                            pickLat: userData!
                                                .onTripRequest!.pickLat,
                                            pickLng: userData!
                                                .onTripRequest!.pickLng));
                                  }
                                } else {
                                  showToast(
                                      message: AppLocalizations.of(context)!
                                          .enterOTPText);
                                }
                              } else {
                                if (context.read<HomeBloc>().unloadImage !=
                                    null) {
                                  context.read<HomeBloc>().add(
                                      UploadProofEvent(
                                          image: context
                                              .read<HomeBloc>()
                                              .unloadImage!,
                                          isBefore: false,
                                          id: userData!.onTripRequest!.id));
                                }
                              }
                            }),
                        SizedBox(
                          height: size.width * 0.05,
                        )
                      ],
                    ),
                  ),
                )),
          // Showing signature field
          if (context.read<HomeBloc>().showSignature == true)
            Positioned(
                top: 0,
                child: Container(
                  height: size.height,
                  width: size.width,
                  color: Colors.transparent.withOpacity(0.4),
                  child: TopBarDesign(
                    isHistoryPage: false,
                    isOngoingPage: false,
                    title: AppLocalizations.of(context)!.getUserSignature,
                    onTap: () {
                      context.read<HomeBloc>().add(ShowSignatureEvent());
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: size.width * 0.1,
                                ),
                                SizedBox(
                                  width: size.width * 0.8,
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .drawSignature,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * 0.05,
                                ),
                                Stack(
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.8,
                                      height: size.width * 0.8,
                                      child: DottedBorder(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          strokeWidth: 1,
                                          dashPattern: const [6, 3],
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(5),
                                          child: Container()),
                                    ),
                                    Positioned(
                                      top: 0,
                                      child: SizedBox(
                                        width: size.width * 0.8,
                                        height: size.width * 0.8,
                                        child: RepaintBoundary(
                                          key: screenshotImage,
                                          child: CustomPaint(
                                            painter: SignaturePainterWidget(
                                                pointlist: context
                                                    .read<HomeBloc>()
                                                    .signaturePoints,
                                                color: Theme.of(context)
                                                    .primaryColorDark),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      child: GestureDetector(
                                        onTapDown: (val) {
                                          final box =
                                              context.findRenderObject()
                                                  as RenderBox;
                                          final point = box.globalToLocal(
                                              val.globalPosition);
                                          context
                                              .read<HomeBloc>()
                                              .add(UpdateSignEvent(points: {
                                                'point': Offset(
                                                    point.dx -
                                                        size.width * 0.15,
                                                    point.dy -
                                                        (((size.height -
                                                                size.width *
                                                                    1.65)) /
                                                            2) -
                                                        size.width * 0.425),
                                                'action': 'dot to'
                                              }));
                                        },
                                        onTapUp: (val) {
                                          final box =
                                              context.findRenderObject()
                                                  as RenderBox;
                                          final point = box.globalToLocal(
                                              val.globalPosition);

                                          context
                                              .read<HomeBloc>()
                                              .add(UpdateSignEvent(points: {
                                                'point': Offset(
                                                    point.dx -
                                                        size.width * 0.15,
                                                    point.dy -
                                                        (((size.height -
                                                                size.width *
                                                                    1.65)) /
                                                            2) -
                                                        size.width * 0.425),
                                                'action': 'setstate'
                                              }));
                                        },
                                        onPanStart: (val) {
                                          final box =
                                              context.findRenderObject()
                                                  as RenderBox;
                                          final point = box.globalToLocal(
                                              val.globalPosition);

                                          context
                                              .read<HomeBloc>()
                                              .add(UpdateSignEvent(points: {
                                                'point': Offset(
                                                    point.dx -
                                                        size.width * 0.15,
                                                    point.dy -
                                                        (((size.height -
                                                                size.width *
                                                                    1.65)) /
                                                            2) -
                                                        size.width * 0.425),
                                                'action': 'move to'
                                              }));
                                        },
                                        onPanUpdate: (val) {
                                          final box =
                                              context.findRenderObject()
                                                  as RenderBox;
                                          final point = box.globalToLocal(
                                              val.globalPosition);
                                          if (point.dx < size.width * 0.85 &&
                                              point.dx > size.width * 0.15 &&
                                              point.dy >
                                                  (((size.height -
                                                              size.width *
                                                                  1.65)) /
                                                          2) +
                                                      size.width * 0.425 &&
                                              point.dy <
                                                  (((size.height -
                                                              size.width *
                                                                  1.65)) /
                                                          2) +
                                                      size.width * 1.125) {
                                            context
                                                .read<HomeBloc>()
                                                .add(UpdateSignEvent(points: {
                                                  'point': Offset(
                                                      point.dx -
                                                          size.width * 0.15,
                                                      point.dy -
                                                          (((size.height -
                                                                  size.width *
                                                                      1.65)) /
                                                              2) -
                                                          size.width * 0.425),
                                                  'action': 'line to'
                                                }));
                                          }
                                        },
                                        onPanEnd: (val) {
                                          context.read<HomeBloc>().add(
                                                  UpdateSignEvent(points: {
                                                'point': 'point',
                                                'action': 'setstate'
                                              }));
                                        },
                                        child: Container(
                                          width: size.width * 0.8,
                                          height: size.width * 0.8,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            CustomButton(
                                width: size.width * 0.7,
                                buttonName: AppLocalizations.of(context)!
                                    .confirmSignature,
                                onTap: () async {
                                  if (context
                                      .read<HomeBloc>()
                                      .signaturePoints
                                      .isNotEmpty) {
                                    RenderRepaintBoundary boundary =
                                        screenshotImage.currentContext!
                                                .findRenderObject()
                                            as RenderRepaintBoundary;
                                    var image =
                                        await boundary.toImage(pixelRatio: 2);
                                    var file = await image.toByteData(
                                        format: ImageByteFormat.png);
                                    var uintImage =
                                        file!.buffer.asUint8List();
                                    Directory paths =
                                        await getTemporaryDirectory();
                                    var path = paths.path;
                                    var name = DateTime.now();
                                    var _signatureImage =
                                        File('$path/$name.png');

                                    _signatureImage
                                        .writeAsBytesSync(uintImage);
                                    context.read<HomeBloc>().signatureImage =
                                        _signatureImage.path;
                                    context.read<HomeBloc>().add(
                                        UploadProofEvent(
                                            image: context
                                                .read<HomeBloc>()
                                                .signatureImage!,
                                            isBefore: false,
                                            id: userData!.onTripRequest!.id));
                                  } else {
                                    showToast(
                                        message: AppLocalizations.of(context)!
                                            .getSignatureError);
                                  }
                                }),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            CustomButton(
                                width: size.width * 0.7,
                                buttonName: AppLocalizations.of(context)!
                                    .clearSignature,
                                onTap: () {
                                  context
                                      .read<HomeBloc>()
                                      .add(UpdateSignEvent(points: null));
                                }),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          if (context.read<HomeBloc>().choosenRide == null &&
              (userData == null ||
                  userData!.onTripRequest == null &&
                      userData!.metaRequest == null) &&
              context.read<HomeBloc>().showGetDropAddress == false)
            Positioned(
                bottom: 0,
                child: SizedBox(
                  height: size.width * 0.2,
                  child: Container(
                    margin: const EdgeInsets.only(top: 1),
                    height: size.width * 0.2 - 1,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                              color: Theme.of(context).shadowColor,
                              spreadRadius: 2,
                              blurRadius: 1)
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            if (context.read<HomeBloc>().choosenMenu != 0) {
                              context
                                  .read<HomeBloc>()
                                  .add(ChangeMenuEvent(menu: 0));
                            }
                          },
                          child: SizedBox(
                            height: size.width * 0.2,
                            width: size.width * 0.25,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.homeMenu,
                                  height: size.width * 0.07,
                                  color:
                                      (context.read<HomeBloc>().choosenMenu ==
                                              0)
                                          ? Theme.of(context).primaryColorDark
                                          : AppColors.darkGrey,
                                ),
                                MyText(
                                  text: AppLocalizations.of(context)!.home,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: (context
                                                      .read<HomeBloc>()
                                                      .choosenMenu ==
                                                  0)
                                              ? Theme.of(context)
                                                  .primaryColorDark
                                              : AppColors.darkGrey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              if (context.read<HomeBloc>().choosenMenu != 1) {
                                context
                                    .read<HomeBloc>()
                                    .add(ChangeMenuEvent(menu: 1));
                              }
                            },
                            child: SizedBox(
                              height: size.width * 0.2,
                              width: size.width * 0.25,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.warrantyMenu,
                                    height: size.width * 0.07,
                                    color: (context
                                                .read<HomeBloc>()
                                                .choosenMenu ==
                                            1)
                                        ? Theme.of(context).primaryColorDark
                                        : AppColors.darkGrey,
                                  ),
                                  MyText(
                                    text: (userData != null &&
                                            userData!.role == 'driver')
                                        ? AppLocalizations.of(context)!
                                            .leaderboard
                                        : AppLocalizations.of(context)!
                                            .dashboard,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: (context
                                                        .read<HomeBloc>()
                                                        .choosenMenu ==
                                                    1)
                                                ? Theme.of(context)
                                                    .primaryColorDark
                                                : AppColors.darkGrey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            )),
                        InkWell(
                            onTap: () {
                              if (context.read<HomeBloc>().choosenMenu != 2) {
                                context
                                    .read<HomeBloc>()
                                    .add(ChangeMenuEvent(menu: 2));
                              }
                            },
                            child: SizedBox(
                              height: size.width * 0.2,
                              width: size.width * 0.25,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.walletMenu,
                                    height: size.width * 0.07,
                                    color: (context
                                                .read<HomeBloc>()
                                                .choosenMenu ==
                                            2)
                                        ? Theme.of(context).primaryColorDark
                                        : AppColors.darkGrey,
                                  ),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .earnings,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: (context
                                                        .read<HomeBloc>()
                                                        .choosenMenu ==
                                                    2)
                                                ? Theme.of(context)
                                                    .primaryColorDark
                                                : AppColors.darkGrey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            )),
                        InkWell(
                            onTap: () {
                              if (context.read<HomeBloc>().choosenMenu != 3) {
                                context
                                    .read<HomeBloc>()
                                    .add(ChangeMenuEvent(menu: 3));
                              }
                            },
                            child: SizedBox(
                              height: size.width * 0.2,
                              width: size.width * 0.25,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.profileMenu,
                                    height: size.width * 0.07,
                                    color: (context
                                                .read<HomeBloc>()
                                                .choosenMenu ==
                                            3)
                                        ? Theme.of(context).primaryColorDark
                                        : AppColors.darkGrey,
                                  ),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .accounts,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: (context
                                                        .read<HomeBloc>()
                                                        .choosenMenu ==
                                                    3)
                                                ? Theme.of(context)
                                                    .primaryColorDark
                                                : AppColors.darkGrey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                )),
        ],
      );
});

}

Column earningsWidget(Size size, BuildContext context) {
  return Column(
    key: const Key('switcher'),
    children: [
      Container(
        width: size.width * 0.15,
        height: size.width * 0.01,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).disabledColor.withOpacity(0.2),
        ),
      ),
      SizedBox(
        height: size.width * 0.05,
      ),
      if (context.read<HomeBloc>().outStationList.isNotEmpty) ...[
        InkWell(
          onTap: () {
            context
                .read<HomeBloc>()
                .add(ShowoutsationpageEvent(isVisible: true));
          },
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                      text: AppLocalizations.of(context)!.outstationRides,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGreen)),
                  MyText(
                      text: AppLocalizations.of(context)!.textView,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                ],
              ),
            ),
          ),
        ),
      ],
      SizedBox(
        height: size.width * 0.02,
      ),
      Row(
        children: [
          Expanded(
            child: MyText(
              text: AppLocalizations.of(context)!.todaysEarnings,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: AppConstants().subHeaderSize,
                    // fontWeight: FontWeight.w400),
                  ),
            ),
          ),
          MyText(
            text: '${userData!.currencySymbol}${userData!.totalEarnings}',
            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: const Color(0xff09CE1D),
                fontSize: AppConstants().buttonTextSize,
                fontWeight: FontWeight.w600),
          )
        ],
      ),
      SizedBox(
        height: size.width * 0.03,
      ),
      const HorizontalDotDividerWidget(),
      SizedBox(
        height: size.width * 0.05,
      ),
      Row(
        children: [
          SizedBox(
            width: size.width * 0.3,
            child: Column(
              children: [
                // MyText(
                //   text:
                //       '${(Duration(minutes: (int.parse(userData!.totalMinutesOnline!))).inHours.toString().padLeft(2, '0'))} : ${((Duration(minutes: (int.parse(userData!.totalMinutesOnline!))).inMinutes - (Duration(minutes: (int.parse(userData!.totalMinutesOnline!))).inHours * 60)).toString().padLeft(2, '0'))} hr',
                //   textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                //       color: AppColors.primary,
                //       fontSize: 16,
                //       fontWeight: FontWeight.w600),
                // ),
                MyText(
                  text:
                      '${(Duration(minutes: int.parse(userData!.totalMinutesOnline!)).inHours.toString().padLeft(2, '0'))} : ${((Duration(minutes: int.parse(userData!.totalMinutesOnline!)).inMinutes % 60).toString().padLeft(2, '0'))} ${(Duration(minutes: int.parse(userData!.totalMinutesOnline!)).inHours == 0 ? 'min' : 'hr')}',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),

                MyText(
                  text: AppLocalizations.of(context)!.active,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(color: AppColors.darkGrey),
                    left: BorderSide(color: AppColors.darkGrey))),
            width: size.width * 0.3,
            child: Column(
              children: [
                MyText(
                  text: '${userData!.totalKms} Km',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                MyText(
                  text: AppLocalizations.of(context)!.distance,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(
            width: size.width * 0.3,
            child: Column(
              children: [
                MyText(
                  text: userData!.totalRidesTaken!,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                MyText(
                  text: AppLocalizations.of(context)!.ridesTaken,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      )
    ],
  );
}

StatefulBuilder quickActions(Size size, BuildContext context, Function state) {
  return StatefulBuilder(builder: (context, st) {
    return BlocProvider.value(
      value: BlocProvider.of<HomeBloc>(context),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeDataLoadingStopState ||
              state is EnableBiddingSettingsState ||
              state is EnableBubbleSettingsState) {
            st(() {});
          }
        },
        child: Column(
          key: const Key('switcher1'),
          children: [
            Container(
              width: size.width,
              padding: EdgeInsets.fromLTRB(size.width * 0.05, size.width * 0.05,
                  size.width * 0.05, size.width * 0.05),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            state(() {
                              bottomSize = 0.0;
                              _animatedWidget = null;
                            });
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: size.width * 0.05,
                            color: Theme.of(context).disabledColor,
                          )),
                      SizedBox(
                        width: size.width * 0.05,
                      ),
                      MyText(
                        text: AppLocalizations.of(context)!.instantActivity,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                fontSize: 16, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ],
              ),
            ),
            if (userData!.showInstantRideFeatureForMobileApp == '1') ...[
              SizedBox(height: size.width * 0.05),
              InkWell(
                onTap: () {
                  state(() {
                    bottomSize = 0.0;
                    _animatedWidget = null;
                  });
                  context.read<HomeBloc>().add(ShowGetDropAddressEvent());
                },
                child: Container(
                  width: size.width * 0.9,
                  padding: EdgeInsets.all(size.width * 0.025),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              Theme.of(context).disabledColor.withOpacity(0.5),
                          width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).disabledColor.withOpacity(0.5),
                          offset: const Offset(
                            5.0,
                            5.0,
                          ),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ), //BoxShadow
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).scaffoldBackgroundColor),
                  child: Row(
                    children: [
                      Container(
                        height: size.width * 0.1,
                        width: size.width * 0.1,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor),
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.instantCar,
                          width: size.width * 0.05,
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.05,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.instantRide,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                      )),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: size.width * 0.05,
                        color: Theme.of(context).primaryColorDark,
                      )
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: size.width * 0.05),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AdminChat.routeName);
              },
              child: Container(
                width: size.width * 0.9,
                padding: EdgeInsets.all(size.width * 0.025),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).disabledColor.withOpacity(0.5),
                        width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).disabledColor.withOpacity(0.5),
                        offset: const Offset(
                          5.0,
                          5.0,
                        ),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ), //BoxShadow
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).scaffoldBackgroundColor),
                child: Row(
                  children: [
                    Container(
                      height: size.width * 0.1,
                      width: size.width * 0.1,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).dividerColor),
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppImages.helpCenter,
                        width: size.width * 0.05,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.05,
                    ),
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.helpCenter,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                    )),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: size.width * 0.05,
                      color: Theme.of(context).primaryColorDark,
                    )
                  ],
                ),
              ),
            ),
            // userData!.enableBidOnFare == true &&
            //         userData!.enableBidding == false
            //     ? SizedBox(
            //         height: size.width * 0.05,
            //       )
            //     : const SizedBox(),
            // userData!.enableBidOnFare == true &&
            //         userData!.enableBidding == false
            //     ? Container(
            //         width: size.width * 0.9,
            //         padding: EdgeInsets.all(size.width * 0.015),
            //         decoration: BoxDecoration(
            //             border: Border.all(
            //                 color: Theme.of(context)
            //                     .disabledColor
            //                     .withOpacity(0.5),
            //                 width: 0.5),
            //             boxShadow: [
            //               BoxShadow(
            //                 color: Theme.of(context)
            //                     .disabledColor
            //                     .withOpacity(0.5),
            //                 offset: const Offset(
            //                   5.0,
            //                   5.0,
            //                 ),
            //                 blurRadius: 10.0,
            //                 spreadRadius: 2.0,
            //               ), //BoxShadow
            //               const BoxShadow(
            //                 color: Colors.white,
            //                 offset: Offset(0.0, 0.0),
            //                 blurRadius: 0.0,
            //                 spreadRadius: 0.0,
            //               ), //BoxShadow
            //             ],
            //             borderRadius: BorderRadius.circular(5),
            //             color: Theme.of(context).scaffoldBackgroundColor),
            //         child: Row(
            //           children: [
            //             Container(
            //               height: size.width * 0.1,
            //               width: size.width * 0.1,
            //               decoration: const BoxDecoration(
            //                   shape: BoxShape.circle, color: AppColors.primary),
            //               alignment: Alignment.center,
            //               child: Image.asset(
            //                 AppImages.bidSettings,
            //                 width: size.width * 0.05,
            //               ),
            //             ),
            //             SizedBox(width: size.width * 0.05),
            //             Expanded(
            //                 child: MyText(
            //               text: AppLocalizations.of(context)!.bidOnFare,
            //               textStyle: Theme.of(context)
            //                   .textTheme
            //                   .bodyMedium!
            //                   .copyWith(
            //                       color: AppColors.primary,
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.w400),
            //             )),
            //             Switch(
            //                 activeColor: AppColors.primary,
            //                 inactiveTrackColor: AppColors.darkGrey,
            //                 value: context.read<HomeBloc>().isBiddingEnabled,
            //                 onChanged: (v) {
            //                   context
            //                       .read<HomeBloc>()
            //                       .add(EnableBiddingEvent(isEnabled: v));
            //                 })
            //           ],
            //         ),
            //       )
            //     : const SizedBox(),
            SizedBox(height: size.width * 0.05),
            if (Platform.isAndroid)...[
              Container(
                width: size.width * 0.9,
                padding: EdgeInsets.all(size.width * 0.015),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).disabledColor.withOpacity(0.5),
                        width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).disabledColor.withOpacity(0.5),
                        offset: const Offset(
                          5.0,
                          5.0,
                        ),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ), //BoxShadow
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).scaffoldBackgroundColor),
                child: Row(
                  children: [
                    Container(
                      height: size.width * 0.1,
                      width: size.width * 0.1,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).dividerColor),
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppImages.icon,
                        width: size.width * 0.1,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.05,
                    ),
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.showBubbleIcon,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                    )),
                    Switch(
                        activeColor: AppColors.green,
                        inactiveTrackColor: AppColors.darkGrey,
                        value: showBubbleIcon,
                        onChanged: (v) {
                          context
                              .read<HomeBloc>()
                              .add(EnableBubbleEvent(isEnabled: v));
                        })
                  ],
                ),
              ),
              SizedBox(height: size.width * 0.05),
              ],  
              if(userData!.enableSubVehicleFeature =="1")            
              InkWell(
                onTap: () {
                  context.read<HomeBloc>().add(
                    GetSubVehicleTypesEvent(serviceLocationId: userData!.serviceLocationId!,vehicleType: userData!.vehicleTypes![0]));
                },
                child: Container(
                  width: size.width * 0.9,
                  padding: EdgeInsets.all(size.width * 0.025),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              Theme.of(context).disabledColor.withOpacity(0.5),
                          width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).disabledColor.withOpacity(0.5),
                          offset: const Offset(
                            5.0,
                            5.0,
                          ),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ), //BoxShadow
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).scaffoldBackgroundColor),
                  child: Row(
                    children: [
                      Container(
                        height: size.width * 0.1,
                        width: size.width * 0.1,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor),
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.myServices,
                          width: size.width * 0.05,
                        ),
                      ),
                      SizedBox(width: size.width * 0.05),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.myServices,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                      )),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: size.width * 0.05,
                        color: Theme.of(context).primaryColorDark,
                      )
                    ],
                  ),
                ),
              ),
            
          ],
        ),
      ),
    );
  });
}

class ShapePainter extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.675);
    path.quadraticBezierTo(size.width * 0.0, size.height * 0.5,
        size.width * 0.15, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(
        size.width, size.height * 0.5, size.width, size.height * 0.5);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
