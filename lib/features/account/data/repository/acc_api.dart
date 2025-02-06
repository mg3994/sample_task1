import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import '../../../../common/local_data.dart';
import '../../../../core/network/dio_provider_impl.dart';
import '../../../../core/network/endpoints.dart';

class AccApi {
  //get history
  Future getHistoryApi(String historyFilter, {String? pageNo}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (pageNo != null && pageNo != 'null' && pageNo.isNotEmpty)
            ? '${ApiEndpoints.history}?$historyFilter&page=$pageNo'
            : '${ApiEndpoints.history}?$historyFilter',
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //Outstation
  Future readyToPickup({required String requestId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.readyToPickup,
        body: {'request_id': requestId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //add driver
  Future addDriverApi({
    required String name,
    required String email,
    required String mobile,
    required String address,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.addDrivers,
        body: {
          'name': name,
          'email': email,
          'mobile': mobile,
          'address': address,
          'transport_type': userData!.transportType
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get driver
  Future getDriverApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getDrivers,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      if (kDebugMode) {
        printWrapped('text get drivers api ${response.data}');
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get driver
  Future deleteDriverApi({required String driverId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.deleteDriver
            .toString()
            .replaceAll('driverId', driverId.toString()),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get driver
  Future getVehiclesApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getVehicles,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get driver
  Future assignDriverApi(
      {required String fleetId, required String driverId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.assignDriver.toString().replaceAll('fleetId', fleetId),
        body: {'driver_id': driverId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //logout
  Future logoutApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.logout,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //delete account
  Future deleteAccountApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.deleteAccount,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//delete notification
  Future deleteNotification(String id) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.deleteNotification}/$id',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //delete notification
  Future getEarnings() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getEarnings,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //delete notification
  Future getDailyEarnings(final String date) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.getDailyEarnings,
        body: {'date': date},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //make complaint confirm button
  Future makeComplaintButton(
      String complaintTitleId, String complaintText, String requestId) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.makeComplaintButton,
        headers: {'Authorization': token},
        body: (requestId.isEmpty)
            ? jsonEncode({
                'complaint_title_id': complaintTitleId,
                'description': complaintText,
              })
            : jsonEncode({
                'complaint_title_id': complaintTitleId,
                'description': complaintText,
                'request_id': requestId,
              }),
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get notifications
  Future getNotificationsApi({String? pageNo}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (pageNo != null)
            ? '${ApiEndpoints.notification}?page=$pageNo'
            : ApiEndpoints.notification,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //Make Complaints
  Future makeComplaintsApi({String? complaintType}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (complaintType == 'general')
            ? '${ApiEndpoints.makeComplaint}?complaint_type=general'
            : '${ApiEndpoints.makeComplaint}?complaint_type=request',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //Faq
  Future getFaqLists() async {
    try {
      final token = await AppSharedPreference.getToken();
      Position? position = await Geolocator.getLastKnownPosition();
      double lat = (position != null) ? position.latitude : 0;
      double long = (position != null) ? position.longitude : 0;
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.faqData}/$lat/$long',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      if (kDebugMode) {
        printWrapped(response.data.toString());
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Wallet History
  Future getWalletHistoryLists(int page) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.walletHistory}?page=$page',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Subscription
  Future makeSubscriptionPlans(int paymentOpt, int amount, int planId) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response =
          await DioProviderImpl().post(ApiEndpoints.makeSubscription,
              headers: {'Authorization': token},
              body: jsonEncode({
                'payment_opt': paymentOpt,
                'amount': amount,
                'plan_id': planId,
              }));
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//subscription
  Future getSubscriptionLists() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.subscriptionList,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Incentive
  Future getIncentive({required int type}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (type == 0)
            ? ApiEndpoints.todayIncentive
            : ApiEndpoints.weeklyIncentive,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future moneytransfers({
    required String transferMobile,
    required String role,
    required String transferAmount,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
          ApiEndpoints.transferMoney,
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: FormData.fromMap({
            'mobile': transferMobile,
            'role': role,
            'amount': transferAmount
          }));
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future updateDetailsButton(
      {required String email,
      required String name,
      required String gender,
      required String profileImage}) async {
    try {
      final token = await AppSharedPreference.getToken();
      final formData = FormData.fromMap({
        "name": name,
        "email": email,
        'gender': (gender == 'Male' || gender == 'male')
            ? 'male'
            : (gender == 'Female' || gender == 'female')
                ? 'female'
                : 'others',
      });
      if (profileImage.isNotEmpty) {
        formData.files.add(MapEntry(
            'profile_picture', await MultipartFile.fromFile(profileImage)));
      }
      Response response = await DioProviderImpl().post(
        ApiEndpoints.updateUserDetailsButton,
        body: formData,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future addSosContacts({
    required String name,
    required String number,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
          ApiEndpoints.addSosContact,
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: FormData.fromMap({
            'name': name,
            'number': number,
          }));
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //sos delete
  Future deleteSosContacts(String id) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        '${ApiEndpoints.deleteSosContact}/$id',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//admin send message
  Future sendAdminMessage({
    required String newChat,
    required String message,
    required String chatId,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
          ApiEndpoints.sendAdminMessage,
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: (chatId.isEmpty)
              ? FormData.fromMap({'new_conversation': 1, 'content': message})
              : FormData.fromMap({
                  'new_conversation': 0,
                  'content': message,
                  'conversation_id': chatId
                }));
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//admin chat history
  Future getAdminChatHistoryLists() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.adminChatHistory,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//get bank details
  Future getBankDetails() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getBankInfo,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//update bank details
  Future updateBankDetails({required dynamic body}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.updateBankInfo,
        body: body,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//rewards points
  Future rewardPointsPost({required String amount}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.rewardsPointsPost,
        body: jsonEncode({
          'amount': amount,
        }),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Withdraw amount
  Future getWithdrawData(int page) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.getWithdrawData}?page=$page',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Request withdraw
  Future requestWithdraw({required String amount}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.requestWithdraw,
        body: {'requested_amount': amount},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//admin message seen api
  Future adminMessageSeen(String chatId) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.adminMessageSeen}?conversation_id=$chatId',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Get driver levelup
  Future getDriverLevels(int page) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        "${ApiEndpoints.driverLevel}?page=$page",
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//get driver rewards
  Future getDriverRewards(int page) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        "${ApiEndpoints.driverRewards}?page=$page",
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get notifications
  Future getOwnerDashboard() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.ownerDashboard,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//fleet driver dashboard
  Future getFleetDashboard({required String fleetId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.fleetDashboard,
        body: {'fleet_id': fleetId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Get driver performance
  Future getDriverPerformance({required String driverId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.driverPerformance,
        body: {'driver_id': driverId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get Leaderboard
  Future getLeaderBoard(
      {required int type, required String lat, required String lng}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (type == 0)
            ? '${ApiEndpoints.leaderBoardEarnings}?current_lat=$lat&current_lng=$lng'
            : '${ApiEndpoints.leaderBoardTrips}?current_lat=$lat&current_lng=$lng',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
