import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/crop_image_custom.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/driverprofile/application/usecases/driver_profile_usecase.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/needed_documents_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/service_location_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_types_model.dart';
import '../../../common/common.dart';
import '../../../di/locator.dart';
part 'driver_profile_event.dart';
part 'driver_profile_state.dart';

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final formKey = GlobalKey<FormState>();

  bool showVehiclePage = false;
  List<ServiceLocationData> serviceLocations = [];
  List<VehicleTypeData> vehicleType = [];
  String? registerFor;
  String? choosenServiceLocation;
  String? choosenVehicleType;
  List<NeededDocumentsData> neededDocuments = [];
  String? choosenDocument;
  TextEditingController vehicleYear = TextEditingController();
  TextEditingController vehicleNumber = TextEditingController();
  TextEditingController vehicleColor = TextEditingController();
  TextEditingController customMake = TextEditingController();
  TextEditingController customModel = TextEditingController();
  TextEditingController documentId = TextEditingController();
  TextEditingController documentExpiry = TextEditingController();
  TextEditingController companyName = TextEditingController();
  TextEditingController companyAddress = TextEditingController();
  TextEditingController companyCity = TextEditingController();
  TextEditingController companyPostalCode = TextEditingController();
  TextEditingController companyTaxNumber = TextEditingController();
  String? docImage;
  String? docImageBack;
  ImagePicker picker = ImagePicker();
  bool showSubmitButton = false;
  bool modifyDocument = true;
  StreamSubscription? approvalStream;
  bool approved = false;
  bool isLoading = false;
  bool isEditable = false;
  String? fleetId;
  AccBloc accBloc = AccBloc();

  List vehicleRegisterFor = ['Taxi', 'Delivery', 'Both'];

  DriverProfileBloc() : super(DriverProfileInitialState()) {
    // Auth
    on<OpenVehicleInformationEvent>(openVehicleInfoPage);
    on<GetServiceLocationEvent>(getServiceLocation);
    on<GetVehicleTypeEvent>(getVehicleType);
    on<UpdateVehicleTypeEvent>(updateVehicleType);
    on<UpdateVehicleEvent>(updateVehicle);
    on<DataChangeEvent>(dataChanged);
    on<GetNeededDocumentsEvent>(getDocuments);
    on<GetInitialDataEvent>(getInitialData);
    on<ChooseDocumentEvent>(chooseDocument);
    on<PickImageEvent>(getDocImage);
    on<ChooseDateEvent>(pickDate);
    on<UploadDocumentEvent>(uploadDocument);
    on<ModifyDocEvent>(modifyDocumentFunc);
    on<EnableEditEvent>(enableEditingDocument);
  }

  Future<void> dataChanged(
      DataChangeEvent event, Emitter<DriverProfileState> emit) async {
    emit(DataChangedState());
  }

  Future<void> openVehicleInfoPage(
      DriverProfileEvent event, Emitter<DriverProfileState> emit) async {
    if (showVehiclePage) {
      showVehiclePage = false;
    } else {
      showVehiclePage = true;
    }
    emit(PageChangeState());
  }

  Future<void> modifyDocumentFunc(
      ModifyDocEvent event, Emitter<DriverProfileState> emit) async {
    if (modifyDocument) {
      modifyDocument = false;
      if (approvalStream == null) {
        streamApproval();
      }
    } else {
      modifyDocument = true;
      streamApproval();
    }
    emit(PageChangeState());
  }

  Future<void> chooseDocument(
      ChooseDocumentEvent event, Emitter<DriverProfileState> emit) async {
    documentId.clear();
    documentExpiry.clear();
    docImage = null;
    if (event.id == null) {
      isEditable = false;
      choosenDocument = null;
    } else {
      choosenDocument = event.id;
    }
    emit(PageChangeState());
  }

  Future<void> uploadDocument(
      UploadDocumentEvent event, Emitter<DriverProfileState> emit) async {
    emit(LoadingStartState());
    final data = await serviceLocator<DriverProfileUsecase>().uploadDocuments(
        id: event.id,
        identifyNumber: documentId.text.isNotEmpty ? documentId.text : null,
        expiryDate: documentExpiry.text.isNotEmpty
            ? "${documentExpiry.text} 00:00:00"
            : null,
        fleetId: event.fleetId,
        document: docImage!,
        documentBack: docImageBack ?? '');

    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        choosenDocument = null;
        add(GetNeededDocumentsEvent(fleetId: fleetId));
      },
    );

    emit(LoadingStopState());
  }

  // get cancel reason
  FutureOr<void> getServiceLocation(
      GetServiceLocationEvent event, Emitter<DriverProfileState> emit) async {
    emit(LoadingStartState());
    registerFor = event.type;
    choosenServiceLocation = null;
    choosenVehicleType = null;
    vehicleYear.clear();
    customMake.clear();
    customModel.clear();
    vehicleNumber.clear();
    vehicleColor.clear();

    companyName.clear();
    companyCity.clear();
    companyAddress.clear();
    companyPostalCode.clear();
    companyTaxNumber.clear();
    if (serviceLocations.isEmpty) {
      final data =
          await serviceLocator<DriverProfileUsecase>().getServiceLocation();

      data.fold(
        (error) {
          emit(ShowErrorState(message: error.message.toString()));
        },
        (success) {
          serviceLocations = success.data;
        },
      );
    } else {}
    emit(LoadingStopState());
  }

  // get cancel reason
  FutureOr<void> getVehicleType(
      GetVehicleTypeEvent event, Emitter<DriverProfileState> emit) async {
    emit(LoadingStartState());
    choosenVehicleType = null;
    customMake.clear();
    customModel.clear();
    vehicleYear.clear();
    vehicleNumber.clear();
    vehicleColor.clear();

    companyName.clear();
    companyCity.clear();
    companyAddress.clear();
    companyPostalCode.clear();
    companyTaxNumber.clear();
    choosenServiceLocation = event.id;
    if (userData!.role == 'driver' || event.from == 'owner') {
      final data = await serviceLocator<DriverProfileUsecase>()
          .getVehicleType(id: event.id, type: event.type);
      data.fold(
        (error) {
          emit(ShowErrorState(message: error.message.toString()));
        },
        (success) {
          vehicleType = success.data;
        },
      );
    }
    emit(LoadingStopState());
  }

  Future<void> getDocImage(
      PickImageEvent event, Emitter<DriverProfileState> emit) async {
    final XFile? image = await picker.pickImage(source: event.source);

    if (image != null) {
      // Add Image Cropper functionality
      final CroppedFile? croppedImage =
          await ImageCropper().cropImage(sourcePath: image.path, uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          minimumAspectRatio: 1.0,
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPresetCustom(),
          ],
        ),
      ]);

      if (croppedImage != null) {
        // If cropping is successful, update the paths accordingly
        if (event.isFront) {
          docImage = croppedImage.path;
        } else {
          docImageBack = croppedImage.path;
        }
        emit(DataChangedState());
      }
    }
  }

  FutureOr<void> getDocuments(
      GetNeededDocumentsEvent event, Emitter<DriverProfileState> emit) async {
    emit(LoadingStartState());
    final data = await serviceLocator<DriverProfileUsecase>()
        .getDocuments(fleetId: event.fleetId);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        neededDocuments = success.data;

        if (success.enableSubmitButton) {
          showSubmitButton = true;
          if (!isClosed && userData!.approve == false) {
            add(ModifyDocEvent());
          }
        } else {
          showSubmitButton = false;
        }
      },
    );
    emit(LoadingStopState());
  }

  FutureOr<void> getInitialData(
      GetInitialDataEvent event, Emitter<DriverProfileState> emit) async {
    if (event.fleetId != null) {
      fleetId = event.fleetId;
    } else {
      fleetId = null;
    }
    if (userData!.enableModulesForApplications != 'both') {
      registerFor = userData!.enableModulesForApplications;
      emit(DataChangedState());
    }
    if (event.from == 'owner') {
      registerFor = userData!.transportType;
      choosenServiceLocation = userData!.serviceLocationId;
      add(GetVehicleTypeEvent(
          id: choosenServiceLocation!, type: registerFor!, from: event.from!));
    }
    if (userData!.serviceLocationId != null &&
        event.from != 'vehicle' &&
        event.from != 'owner') {
      add(GetNeededDocumentsEvent(fleetId: event.fleetId));
    }
    if (userData!.declinedReason != '' &&
        userData!.declinedReason != null &&
        userData!.uploadedDocument == true &&
        event.from != 'vehicle' &&
        event.from != 'docs' &&
        event.from != 'owner') {
      modifyDocument = false;
      if (approvalStream == null) {
        streamApproval();
      }
    } else if (userData!.approve != true &&
        userData!.uploadedDocument == true &&
        modifyDocument == true &&
        event.from != 'vehicle' &&
        event.from != 'docs' &&
        event.from != 'owner') {
      if (approvalStream == null) {
        streamApproval();
      }
    }

    emit(DataChangedState());
  }

  FutureOr<void> pickDate(
      ChooseDateEvent event, Emitter<DriverProfileState> emit) async {
    DateTime? picker = await showDatePicker(
      context: event.context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    documentExpiry.text = picker != null ? picker.toString().split(" ")[0] : '';

    emit(DataChangedState());
  }

  FutureOr<void> updateVehicleType(
      UpdateVehicleTypeEvent event, Emitter<DriverProfileState> emit) async {
    choosenVehicleType = event.id;
    customMake.clear();
    customModel.clear();
    vehicleYear.clear();
    vehicleNumber.clear();
    vehicleColor.clear();
    emit(DataChangedState());
  }

  streamApproval() async {
    approvalStream?.cancel();
    approvalStream = null;
    var driverState = await FirebaseDatabase.instance
        .ref()
        .child((userData!.role == 'driver')
            ? 'drivers/driver_${userData!.id}'
            : 'owners/owner_${userData!.id}')
        .get();
    if (driverState.child('approve').value == 1) {
      approved = true;
      if (!isClosed) {
        add(DataChangeEvent());
      }
    } else {
      approvalStream = FirebaseDatabase.instance
          .ref()
          .child((userData!.role == 'driver')
              ? 'drivers/driver_${userData!.id}'
              : 'owners/owner_${userData!.id}')
          .onValue
          .handleError((onError) {
        approvalStream?.cancel();
        approvalStream = null;
      }).listen((DatabaseEvent event) {
        if (!isClosed && event.snapshot.value != null) {
          Map data = jsonDecode(jsonEncode(event.snapshot.value));
          if (data['approve'] == 1) {
            approved = true;
          } else {
            approved = false;
          }
          add(DataChangeEvent());
        }
      });
    }
  }

  FutureOr<void> updateVehicle(
      UpdateVehicleEvent event, Emitter<DriverProfileState> emit) async {
    emit(LoadingStartState());
    final data = await serviceLocator<DriverProfileUsecase>().updateVehicle(
        serviceLocation: choosenServiceLocation!,
        customMake: customMake.text,
        customModel: customModel.text,
        carColor: vehicleColor.text,
        carNumber: vehicleNumber.text,
        vehicleType: choosenVehicleType,
        vehicleYear: vehicleYear.text,
        transportType: registerFor!,
        companyAddress: companyAddress.text,
        companyCity: companyCity.text,
        companyName: companyName.text,
        companyPostalCode: companyPostalCode.text,
        companyTaxNumber: companyTaxNumber.text,
        from: event.from);

    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(LoadingStopState());
      },
      (success) {
        if (userData!.role == 'driver') {
          userData!.serviceLocationId = success.data!['service_location_id'];
          userData!.vehicleTypeId = success.data!['vehicle_type_id'];
          userData!.vehicleTypeName = success.data!['vehicle_type_name'];
          userData!.vehicleTypeIcon = success.data!['vehicle_type_icon_for'];
          userData!.carMake = success.data!['car_make_name'];
          userData!.carModel = success.data!['car_model_name'];
          userData!.carColor = success.data!['car_color'];
          userData!.approve = success.data!['approve'];
          userData!.carNumber = success.data!['car_number'];
        } else if (success.data != null) {
          userData!.serviceLocationId = choosenServiceLocation!;
          userData!.companyName = success.data!['company_name'];
          userData!.companyAddress = success.data!['address'];
          userData!.companyPostalCode = success.data!['postal_code'].toString();
          userData!.companyCity = success.data!['city'];
          userData!.companyTaxNumber = success.data!['tax_number'];
        }

        if (event.from == 'vehicle') {
          modifyDocument = false;

          if (userData!.approve) {
            emit(LoadingStopState());
            emit(VehicleUpdateSuccessState());
          } else {
            modifyDocument = false;
            if (approvalStream == null) {
              streamApproval();
            }
            emit(LoadingStopState());
            emit(VehicleUpdateSuccessState());
          }
        } else if (event.from == 'owner') {
          emit(LoadingStopState());
          emit(VehicleAddedState());
        } else {
          add(GetNeededDocumentsEvent(fleetId: null));
          emit(LoadingStopState());
        }
      },
    );
  }

  FutureOr<void> enableEditingDocument(
      EnableEditEvent event, Emitter<DriverProfileState> emit) {
    isEditable = event.isEditable;
    emit(EnableEditState(isEditable: isEditable));
  }

  @override
  Future<void> close() {
    approvalStream?.cancel();
    return super.close();
  }
}
