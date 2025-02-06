// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/features/loading/application/usecase/loading_usecase.dart';
import '../../../common/common.dart';
import '../../../di/locator.dart';
import '../../auth/application/usecases/auth_usecase.dart';

part 'loading_event.dart';
part 'loading_state.dart';

class LoaderBloc extends Bloc<LoaderEvent, LoaderState> {
  LoaderBloc() : super(LoaderInitialState()) {
    on<CheckPermissionEvent>(checkPermission);
    on<LoaderGetLocalDataEvent>(loadData);
    on<UpdateUserLocationEvent>(updateUserLocation);
  }

  bool? locationApproved;
  bool isOwnerEnabled = false;

  recheckLocationPerm() {
    add(LoaderGetLocalDataEvent());
  }

  Future<void> checkPermission(
      CheckPermissionEvent event, Emitter<LoaderState> emit) async {
    PermissionStatus permission;
    permission = await Permission.location.status;
    if (permission == PermissionStatus.denied ||
        permission == PermissionStatus.permanentlyDenied) {
      locationApproved = false;
    } else {
      final loginStatus = await AppSharedPreference.getLoginStatus();
      if (loginStatus) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);
        double lat = position.latitude;
        double long = position.longitude;
        await serviceLocator<LoaderUsecase>()
            .updateUserLocation(currentLocation: LatLng(lat, long));
      }
      locationApproved = true;
      add(LoaderGetLocalDataEvent());
    }
    emit(LoaderUpdateState());
  }

  Future<void> loadData(
      LoaderGetLocalDataEvent event, Emitter<LoaderState> emit) async {
    locationApproved = null;
    final landingStatus = await AppSharedPreference.getLandingStatus();
    final loginStatus = await AppSharedPreference.getLoginStatus();
    final userType = await AppSharedPreference.getUserType();
    final direction = await AppSharedPreference.getLanguageDirection();
    final selectedLanguage =
        await AppSharedPreference.getSelectedLanguageCode();
    if (selectedLanguage.isNotEmpty) {
      choosenLanguage = selectedLanguage;
    }
    if (direction.isNotEmpty) {
      languageDirection = direction;
    }

    final data = await serviceLocator<AuthUsecase>().commonModuleCheck();
   await data.fold(
      (error) {
        debugPrint(error.toString());
        emit(LoaderUpdateState());
      },
      (success) async {
        if (success.enableOwnerLogin == '0') {
          isOwnerEnabled = false;
        } else {
          isOwnerEnabled = true;
        }
        emit(LoaderSuccessState(
            loginStatus: loginStatus,
            landingStatus: landingStatus,
            isOwnerEnabled: isOwnerEnabled,
            selectedLanguage: selectedLanguage,
            userType: userType));
      },
    );
  }

  Future<void> updateUserLocation(
      UpdateUserLocationEvent event, Emitter<LoaderState> emit) async {
    PermissionStatus permission;
    permission = await Permission.location.status;
    if (permission == PermissionStatus.granted ||
        permission == PermissionStatus.limited) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      double lat = position.latitude;
      double long = position.longitude;
      final data = await serviceLocator<LoaderUsecase>()
          .updateUserLocation(currentLocation: LatLng(lat, long));
      data.fold((error) {
        if (kDebugMode) {
          log("Location Api error ${error.toString()}");
        }
      }, (success) {});
    }
  }
}
