import 'package:dartz/dartz.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_data_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_level_models.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_performance_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_points_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_rewards_model.dart';
import 'package:restart_tagxi/features/account/domain/models/earnings_model.dart';
import 'package:restart_tagxi/features/account/domain/models/faq_model.dart';
import 'package:restart_tagxi/features/account/domain/models/incentive_model.dart';
import 'package:restart_tagxi/features/account/domain/models/leader_board_model.dart';
import 'package:restart_tagxi/features/account/domain/models/owner_dashboard_model.dart';
import 'package:restart_tagxi/features/account/domain/models/fleet_dashboard_model.dart';
import 'package:restart_tagxi/features/account/domain/models/owner_vehicle_model.dart';
import 'package:restart_tagxi/features/account/domain/models/subcription_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/bank_details_model.dart';
import 'package:restart_tagxi/features/account/domain/models/bank_details_update_model.dart';
import 'package:restart_tagxi/features/account/domain/models/withdraw_model.dart';
import 'package:restart_tagxi/features/account/domain/models/withdraw_request_model.dart';
import '../../../../core/network/failure.dart';
import '../../domain/models/admin_chat_history_model.dart';
import '../../domain/models/admin_chat_model.dart';
import '../../domain/models/history_model.dart';
import '../../domain/models/logout_model.dart';
import '../../domain/models/makecomplaint_model.dart';
import '../../domain/models/notifications_model.dart';
import '../../domain/models/walletpage_model.dart';
import '../../domain/repositories/acc_repo.dart';

class AccUsecase {
  final AccRepository _accRepository;

  const AccUsecase(this._accRepository);

  // Notifications
  Future<Either<Failure, NotificationResponseModel>> notificationDetails(
      {String? pageNo}) async {
    return _accRepository.getUserNotificationsDetails(pageNo: pageNo);
  }

  // Outstation
  Future<Either<Failure, dynamic>> readyToPickup(
      {required String requestId}) async {
    return _accRepository.readyToPickup(requestId: requestId);
  }

  //make complaints
  Future<Either<Failure, ComplaintResponseModel>> makeComplaint(
      {String? complaintType}) async {
    return _accRepository.makeComplaintList(complaintType: complaintType);
  }

  //Delete Notification
  Future<Either<Failure, dynamic>> deleteNotification(String id) async {
    return _accRepository.deleteNotification(id);
  }

  //make complaints button
  Future<Either<Failure, dynamic>> makeComplaintButton(
      String complaintTitleId, String complaintText, String requestId) async {
    return _accRepository.makeComplaintButton(
        complaintTitleId, complaintText, requestId);
  }

  // History
  Future<Either<Failure, HistoryResponseModel>> historyDetails(
      String historyFilter,
      {String? pageNo}) async {
    return _accRepository.getUserHistoryDetails(historyFilter, pageNo: pageNo);
  }

  // logout
  Future<Either<Failure, LogoutResponseModel>> logout() async {
    return _accRepository.logout();
  }

  // Delete account
  Future<Either<Failure, dynamic>> deleteUserAccount() async {
    return _accRepository.deleteAccount();
  }

  // add driver
  Future<Either<Failure, DriverDataModel>> addDrivers(
      {required String name,
      required String email,
      required String mobile,
      required String address}) async {
    return _accRepository.addDrivers(
        name: name, email: email, mobile: mobile, address: address);
  }

  //get drivers
  Future<Either<Failure, DriverDataModel>> getDrivers() async {
    return _accRepository.getDrivers();
  }

  //get drivers
  Future<Either<Failure, OwnerDashboardModel>> getOwnerDashboard() async {
    return _accRepository.getOwnerDashboard();
  }

  Future<Either<Failure, DriverLevelsModel>> getDriverLevels(int page) async {
    return _accRepository.getDriverLevels(page);
  }

  Future<Either<Failure, DriverRewardsModel>> getDriverRewards(int page) async {
    return _accRepository.getDriverRewards(page);
  }

  Future<Either<Failure, DriverRewardsPointsModel>> rewardPointsPost(
      {required String amount}) async {
    return _accRepository.rewardPointsPost(amount: amount);
  }

  //get drivers
  Future<Either<Failure, FleetDashboardModel>> getFleetDashboard(
      {required String fleetId}) async {
    return _accRepository.getFleetDashboard(fleetId: fleetId);
  }

//get drivers
  Future<Either<Failure, DriverPerformanceModel>> getDriverPerformance(
      {required String driverId}) async {
    return _accRepository.getDriverPerformance(driverId: driverId);
  }

  //get drivers
  Future<Either<Failure, DriverDataModel>> deleteDrivers(
      {required String driverId}) async {
    return _accRepository.deleteDrivers(driverId: driverId);
  }

  //get drivers
  Future<Either<Failure, OwnerVehicleModel>> getVehicles() async {
    return _accRepository.getVehicles();
  }

  //get drivers
  Future<Either<Failure, OwnerVehicleModel>> assignDriver(
      {required String fleetId, required String driverId}) async {
    return _accRepository.assignDriver(fleetId: fleetId, driverId: driverId);
  }

  //Faq
  Future<Either<Failure, FaqResponseModel>> getFaqDetail() async {
    return _accRepository.getFaqDetails();
  }

  Future<Either<Failure, WalletResponseModel>> getWalletDetail(int page) async {
    return _accRepository.getWalletHistoryDetails(page);
  }

  Future<Either<Failure, SubscriptionListModel>> getSubscriptionList() async {
    return _accRepository.getSubscriptionList();
  }

  Future<Either<Failure, SubscriptionSuccessModel>> makeSubscriptionPlan(
      {required int paymentOpt,
      required int amount,
      required int planId}) async {
    return _accRepository.makeSubscriptionPlan(paymentOpt, amount, planId);
  }

  Future<Either<Failure, dynamic>> moneyTransfer(
      {required String transferMobile,
      required String role,
      required String transferAmount}) async {
    return _accRepository.moneyTransfer(
        transferMobile: transferMobile,
        role: role,
        transferAmount: transferAmount);
  }

  //update details
  Future<Either<Failure, dynamic>> updateDetailsButton(
      {required String email,
      required String name,
      required String gender,
      required String profileImage}) async {
    return _accRepository.updateDetailsButton(
        email: email, name: name, gender: gender, profileImage: profileImage);
  }

  Future<Either<Failure, dynamic>> deleteSosContact(String id) async {
    return _accRepository.deleteSos(id);
  }

  Future<Either<Failure, dynamic>> addSosContact({
    required String name,
    required String number,
  }) async {
    return _accRepository.addSos(
      name: name,
      number: number,
    );
  }

  Future<Either<Failure, AdminChatModel>> sendAdminMessages({
    required String newChat,
    required String message,
    required String chatId,
  }) async {
    return _accRepository.sendAdminMessage(
      newChat: newChat,
      message: message,
      chatId: chatId,
    );
  }

  Future<Either<Failure, AdminChatHistoryModel>>
      getAdminChatHistoryDetail() async {
    return _accRepository.getAdminChatHistoryDetails();
  }

  Future<Either<Failure, dynamic>> adminMessageSeenDetail(String chatId) async {
    return _accRepository.adminMessageSeenDetails(chatId);
  }

  Future<Either<Failure, EarningsModel>> getEarnings() async {
    return _accRepository.getEarnings();
  }

  Future<Either<Failure, DailyEarningsModel>> getDailyEarnings(
      {required String date}) async {
    return _accRepository.getDailyEarnings(date: date);
  }

  Future<Either<Failure, LeaderBoardModel>> getLeaderBoard(
      {required int type, required String lat, required String lng}) async {
    return _accRepository.getLeaderBoard(type: type, lat: lat, lng: lng);
  }

  Future<Either<Failure, IncentiveModel>> getIncentive(
      {required int type}) async {
    return _accRepository.getIncentive(type: type);
  }

  Future<Either<Failure, BankDetailsModel>> getBankDetails() async {
    return _accRepository.getBankDetails();
  }

  Future<Either<Failure, BankDetailsUpdateModel>> updateBankDetails(
      {required dynamic body}) async {
    return _accRepository.updateBankDetails(body: body);
  }

  Future<Either<Failure, WithdrawModel>> getWithdrawData(page) async {
    return _accRepository.getWithdrawData(page);
  }

  Future<Either<Failure, WithdrawRequestModel>> requestWithdraw(
      {required String amount}) async {
    return _accRepository.requestWithdraw(amount: amount);
  }
}
