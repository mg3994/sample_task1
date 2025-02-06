import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:restart_tagxi/features/account/domain/models/admin_chat_model.dart';
import 'package:restart_tagxi/features/account/domain/models/bank_details_model.dart';
import 'package:restart_tagxi/features/account/domain/models/bank_details_update_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_data_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_level_models.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_performance_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_points_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_rewards_model.dart';
import 'package:restart_tagxi/features/account/domain/models/earnings_model.dart';
import 'package:restart_tagxi/features/account/domain/models/faq_model.dart';
import 'package:restart_tagxi/features/account/domain/models/incentive_model.dart';
import 'package:restart_tagxi/features/account/domain/models/leader_board_model.dart';
import 'package:restart_tagxi/features/account/domain/models/owner_vehicle_model.dart';
import 'package:restart_tagxi/features/account/domain/models/fleet_dashboard_model.dart';
import 'package:restart_tagxi/features/account/domain/models/subcription_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/withdraw_model.dart';
import 'package:restart_tagxi/features/account/domain/models/withdraw_request_model.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/failure.dart';
import '../../domain/models/admin_chat_history_model.dart';
import '../../domain/models/owner_dashboard_model.dart';
import '../../domain/models/history_model.dart';
import '../../domain/models/logout_model.dart';
import '../../domain/models/makecomplaint_model.dart';
import '../../domain/models/notifications_model.dart';
import '../../domain/models/walletpage_model.dart';
import '../../domain/repositories/acc_repo.dart';
import '../repository/acc_api.dart';

class AccRepositoryImpl implements AccRepository {
  final AccApi _accApi;

  AccRepositoryImpl(this._accApi);

  // Notification
  @override
  Future<Either<Failure, NotificationResponseModel>>
      getUserNotificationsDetails({String? pageNo}) async {
    try {
      Response response = await _accApi.getNotificationsApi(pageNo: pageNo);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(
            GetDataFailure(message: response.data["message"].toString()));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        final notificationResponseModel =
            NotificationResponseModel.fromJson(response.data);
        return Right(notificationResponseModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // logout
  @override
  Future<Either<Failure, LogoutResponseModel>> logout() async {
    try {
      Response response = await _accApi.logoutApi();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else {
        final logoutResponseModel = LogoutResponseModel.fromJson(response.data);
        return Right(logoutResponseModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // delete account
  @override
  Future<Either<Failure, dynamic>> deleteAccount() async {
    try {
      Response response = await _accApi.deleteAccountApi();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else {
        return Right(response);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  //incentive
  @override
  Future<Either<Failure, IncentiveModel>> getIncentive(
      {required int type}) async {
    IncentiveModel incentiveModel;
    try {
      Response response = await _accApi.getIncentive(type: type);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          incentiveModel = IncentiveModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(incentiveModel);
  }

  // make complaint
  @override
  Future<Either<Failure, ComplaintResponseModel>> makeComplaintList(
      {String? complaintType}) async {
    try {
      Response response =
          await _accApi.makeComplaintsApi(complaintType: complaintType);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        final complaintResponseModel =
            ComplaintResponseModel.fromJson(response.data);
        return Right(complaintResponseModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // Outstation
  @override
  Future<Either<Failure, dynamic>> readyToPickup(
      {required String requestId}) async {
    dynamic result;
    try {
      Response response = await _accApi.readyToPickup(requestId: requestId);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        result = response.data;
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(result);
  }

  // add driver
  @override
  Future<Either<Failure, DriverDataModel>> addDrivers({
    required String name,
    required String email,
    required String mobile,
    required String address,
  }) async {
    try {
      Response response = await _accApi.addDriverApi(
          name: name, email: email, mobile: mobile, address: address);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(
            message: response.data['error'], statusCode: response.statusCode!));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else {
        final driverDataModel = DriverDataModel.fromJson(response.data);
        return Right(driverDataModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // get driver
  @override
  Future<Either<Failure, DriverDataModel>> getDrivers() async {
    try {
      Response response = await _accApi.getDriverApi();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        final driverDataModel = DriverDataModel.fromJson(response.data);
        return Right(driverDataModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // get driver
  @override
  Future<Either<Failure, DriverDataModel>> deleteDrivers(
      {required String driverId}) async {
    try {
      Response response = await _accApi.deleteDriverApi(driverId: driverId);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else {
        final driverDataModel = DriverDataModel.fromJson(response.data);
        return Right(driverDataModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // get driver
  @override
  Future<Either<Failure, OwnerVehicleModel>> getVehicles() async {
    try {
      Response response = await _accApi.getVehiclesApi();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        final ownerVehicleModel = OwnerVehicleModel.fromJson(response.data);
        return Right(ownerVehicleModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // get driver
  @override
  Future<Either<Failure, OwnerVehicleModel>> assignDriver(
      {required String fleetId, required String driverId}) async {
    try {
      Response response =
          await _accApi.assignDriverApi(fleetId: fleetId, driverId: driverId);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else {
        final ownerVehicleModel = OwnerVehicleModel.fromJson(response.data);
        return Right(ownerVehicleModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

//history
  @override
  Future<Either<Failure, HistoryResponseModel>> getUserHistoryDetails(
      String historyFilter,
      {String? pageNo}) async {
    HistoryResponseModel historyResponseModel;
    try {
      Response response =
          await _accApi.getHistoryApi(historyFilter, pageNo: pageNo);
      if (kDebugMode) {
        debugPrint('getUserHistoryDetails : $response');
      }
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        historyResponseModel = HistoryResponseModel.fromJson(response.data);
      }
    } on FetchDataException catch (e) {
      debugPrint('getUserHistoryDetails Error: $e');
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(historyResponseModel);
  }

  //Delete notification
  @override
  Future<Either<Failure, dynamic>> deleteNotification(String id) async {
    try {
      Response response = await _accApi.deleteNotification(id);
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(GetDataFailure(message: response.statusMessage ?? 'Error'));
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  //make complaint button
  @override
  Future<Either<Failure, dynamic>> makeComplaintButton(
      String complaintTitleId, String complaintText, String requestId) async {
    try {
      Response response = await _accApi.makeComplaintButton(
          complaintTitleId, complaintText, requestId);
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(GetDataFailure(message: response.statusMessage ?? 'Error'));
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  //Faq
  @override
  Future<Either<Failure, FaqResponseModel>> getFaqDetails() async {
    FaqResponseModel faqDataResponseModel;
    try {
      Response response = await _accApi.getFaqLists();

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          faqDataResponseModel = FaqResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(faqDataResponseModel);
  }

  @override
  Future<Either<Failure, WalletResponseModel>> getWalletHistoryDetails(
      int page) async {
    WalletResponseModel walletDataResponseModel;
    try {
      Response response = await _accApi.getWalletHistoryLists(page);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          walletDataResponseModel = WalletResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(walletDataResponseModel);
  }

//Subscription
  @override
  Future<Either<Failure, SubscriptionListModel>> getSubscriptionList() async {
    SubscriptionListModel subscriptionListModel;
    try {
      Response response = await _accApi.getSubscriptionLists();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          subscriptionListModel = SubscriptionListModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(subscriptionListModel);
  }

  @override
  Future<Either<Failure, SubscriptionSuccessModel>> makeSubscriptionPlan(
      int paymentOpt, int amount, int planId) async {
    try {
      Response response =
          await _accApi.makeSubscriptionPlans(paymentOpt, amount, planId);
      if (response.statusCode == 200) {
        final subscriptionSuccessModel =
            SubscriptionSuccessModel.fromJson(response.data);
        return Right(subscriptionSuccessModel);
      } else {
        return Left(GetDataFailure(message: response.statusMessage ?? 'Error'));
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, dynamic>> moneyTransfer({
    required String transferMobile,
    required String role,
    required String transferAmount,
  }) async {
    dynamic amountTransfered;
    try {
      Response response = await _accApi.moneytransfers(
          transferMobile: transferMobile,
          role: role,
          transferAmount: transferAmount);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          amountTransfered = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(amountTransfered);
  }

  //update button
  @override
  Future<Either<Failure, dynamic>> updateDetailsButton(
      {required String email,
      required String name,
      required String gender,
      required String profileImage}) async {
    dynamic updateval;
    try {
      Response response = await _accApi.updateDetailsButton(
          email: email, name: name, gender: gender, profileImage: profileImage);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          updateval = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(updateval);
  }

  @override
  Future<Either<Failure, dynamic>> addSos({
    required String name,
    required String number,
  }) async {
    dynamic addContact;
    try {
      Response response = await _accApi.addSosContacts(
        name: name,
        number: number,
      );
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          addContact = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(addContact);
  }

  @override
  Future<Either<Failure, dynamic>> deleteSos(String id) async {
    dynamic deleteContact;
    try {
      Response response = await _accApi.deleteSosContacts(id);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          deleteContact = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(deleteContact);
  }

  @override
  Future<Either<Failure, AdminChatModel>> sendAdminMessage({
    required String newChat,
    required String message,
    required String chatId,
  }) async {
    AdminChatModel sendAdminMessage;
    try {
      Response response = await _accApi.sendAdminMessage(
        newChat: newChat,
        message: message,
        chatId: chatId,
      );
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          sendAdminMessage = AdminChatModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(sendAdminMessage);
  }

  @override
  Future<Either<Failure, AdminChatHistoryModel>>
      getAdminChatHistoryDetails() async {
    AdminChatHistoryModel adminChatHistory;
    try {
      Response response = await _accApi.getAdminChatHistoryLists();

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          adminChatHistory = AdminChatHistoryModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(adminChatHistory);
  }

  @override
  Future<Either<Failure, dynamic>> adminMessageSeenDetails(
      String chatId) async {
    dynamic adminMessageSeen;
    try {
      Response response = await _accApi.adminMessageSeen(chatId);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          adminMessageSeen = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(adminMessageSeen);
  }

  //get earnings
  @override
  Future<Either<Failure, EarningsModel>> getEarnings() async {
    EarningsModel earningsModel;
    try {
      Response response = await _accApi.getEarnings();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          earningsModel = EarningsModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(earningsModel);
  }

  //get earnings
  @override
  Future<Either<Failure, DailyEarningsModel>> getDailyEarnings(
      {required String date}) async {
    DailyEarningsModel dailyEarningsModel;
    try {
      Response response = await _accApi.getDailyEarnings(date);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          dailyEarningsModel = DailyEarningsModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(dailyEarningsModel);
  }

  //get Rewards
  @override
  Future<Either<Failure, DriverRewardsModel>> getDriverRewards(int page) async {
    DriverRewardsModel driverRewardsModel;
    try {
      Response response = await _accApi.getDriverRewards(page);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          driverRewardsModel = DriverRewardsModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(driverRewardsModel);
  }

  //postReward points
  @override
  Future<Either<Failure, DriverRewardsPointsModel>> rewardPointsPost(
      {required String amount}) async {
    try {
      Response response = await _accApi.rewardPointsPost(amount: amount);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: response.data["message"],
            statusCode: response.statusCode!));
      } else {
        final driverRewardsPointsModel =
            DriverRewardsPointsModel.fromJson(response.data);
        return Right(driverRewardsPointsModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

//get levels
  @override
  Future<Either<Failure, DriverLevelsModel>> getDriverLevels(int page) async {
    DriverLevelsModel driverLevelsModel;
    try {
      Response response = await _accApi.getDriverLevels(page);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          driverLevelsModel = DriverLevelsModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(driverLevelsModel);
  }

  //get earnings
  @override
  Future<Either<Failure, OwnerDashboardModel>> getOwnerDashboard() async {
    OwnerDashboardModel ownerDashboardModel;
    try {
      Response response = await _accApi.getOwnerDashboard();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          ownerDashboardModel = OwnerDashboardModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(ownerDashboardModel);
  }

  @override
  Future<Either<Failure, FleetDashboardModel>> getFleetDashboard(
      {required String fleetId}) async {
    FleetDashboardModel fleetDashboardModel;
    try {
      Response response = await _accApi.getFleetDashboard(fleetId: fleetId);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          fleetDashboardModel = FleetDashboardModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(fleetDashboardModel);
  }

  @override
  Future<Either<Failure, DriverPerformanceModel>> getDriverPerformance(
      {required String driverId}) async {
    DriverPerformanceModel driverPerformanceModel;
    try {
      Response response =
          await _accApi.getDriverPerformance(driverId: driverId);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          driverPerformanceModel =
              DriverPerformanceModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(driverPerformanceModel);
  }

  @override
  Future<Either<Failure, LeaderBoardModel>> getLeaderBoard(
      {required int type, required String lat, required String lng}) async {
    LeaderBoardModel leaderBoardModel;
    try {
      Response response =
          await _accApi.getLeaderBoard(type: type, lat: lat, lng: lng);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          leaderBoardModel = LeaderBoardModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(leaderBoardModel);
  }

  @override
  Future<Either<Failure, BankDetailsModel>> getBankDetails() async {
    BankDetailsModel bankDetailsModel;
    try {
      Response response = await _accApi.getBankDetails();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          bankDetailsModel = BankDetailsModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(bankDetailsModel);
  }

  @override
  Future<Either<Failure, BankDetailsUpdateModel>> updateBankDetails(
      {required dynamic body}) async {
    BankDetailsUpdateModel bankDetailsUpdateModel;
    try {
      Response response = await _accApi.updateBankDetails(body: body);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          bankDetailsUpdateModel =
              BankDetailsUpdateModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(bankDetailsUpdateModel);
  }

  @override
  Future<Either<Failure, WithdrawModel>> getWithdrawData(int page) async {
    WithdrawModel withdrawModel;
    try {
      Response response = await _accApi.getWithdrawData(page);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          withdrawModel = WithdrawModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(withdrawModel);
  }

  @override
  Future<Either<Failure, WithdrawRequestModel>> requestWithdraw(
      {required String amount}) async {
    WithdrawRequestModel withdrawRequestModel;
    try {
      Response response = await _accApi.requestWithdraw(amount: amount);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          withdrawRequestModel = WithdrawRequestModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(withdrawRequestModel);
  }
}
