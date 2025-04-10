import 'package:dartz/dartz.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_data_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_level_models.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_performance_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_points_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_rewards_model.dart';
import 'package:restart_tagxi/features/account/domain/models/earnings_model.dart';
import 'package:restart_tagxi/features/account/domain/models/faq_model.dart';
import 'package:restart_tagxi/features/account/domain/models/incentive_model.dart';
import 'package:restart_tagxi/features/account/domain/models/owner_dashboard_model.dart';
import 'package:restart_tagxi/features/account/domain/models/owner_vehicle_model.dart';
import 'package:restart_tagxi/features/account/domain/models/leader_board_model.dart';
import 'package:restart_tagxi/features/account/domain/models/fleet_dashboard_model.dart';
import 'package:restart_tagxi/features/account/domain/models/subcription_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/bank_details_model.dart';
import 'package:restart_tagxi/features/account/domain/models/bank_details_update_model.dart';
import 'package:restart_tagxi/features/account/domain/models/withdraw_model.dart';
import 'package:restart_tagxi/features/account/domain/models/withdraw_request_model.dart';
import '../../../../core/network/failure.dart';
import '../models/admin_chat_history_model.dart';
import '../models/admin_chat_model.dart';
import '../models/history_model.dart';
import '../models/logout_model.dart';
import '../models/makecomplaint_model.dart';
import '../models/notifications_model.dart';
import '../models/walletpage_model.dart';

abstract class AccRepository {
  Future<Either<Failure, NotificationResponseModel>>
      getUserNotificationsDetails({String? pageNo});

  Future<Either<Failure, dynamic>> deleteAccount();

  Future<Either<Failure, dynamic>> readyToPickup({required String requestId});

  Future<Either<Failure, ComplaintResponseModel>> makeComplaintList(
      {String? complaintType});

  Future<Either<Failure, dynamic>> deleteNotification(String id);

  Future<Either<Failure, dynamic>> makeComplaintButton(
      String complaintTitleId, String complaintText, String requestId);

  Future<Either<Failure, HistoryResponseModel>> getUserHistoryDetails(
      String historyFilter,
      {String? pageNo});

  Future<Either<Failure, LogoutResponseModel>> logout();

  Future<Either<Failure, FaqResponseModel>> getFaqDetails();

  Future<Either<Failure, WalletResponseModel>> getWalletHistoryDetails(
      int page);

  Future<Either<Failure, dynamic>> moneyTransfer({
    required String transferMobile,
    required String role,
    required String transferAmount,
  });

  Future<Either<Failure, dynamic>> addSos({
    required String name,
    required String number,
  });
  Future<Either<Failure, dynamic>> deleteSos(String id);

  Future<Either<Failure, dynamic>> updateDetailsButton(
      {required String email,
      required String name,
      required String gender,
      required String profileImage});

  Future<Either<Failure, AdminChatModel>> sendAdminMessage({
    required String newChat,
    required String message,
    required String chatId,
  });

  Future<Either<Failure, AdminChatHistoryModel>> getAdminChatHistoryDetails();

  Future<Either<Failure, dynamic>> adminMessageSeenDetails(String chatId);

  Future<Either<Failure, EarningsModel>> getEarnings();
  Future<Either<Failure, SubscriptionListModel>> getSubscriptionList();
  Future<Either<Failure, SubscriptionSuccessModel>> makeSubscriptionPlan(
      int paymentOpt, int amount, int planId);

  Future<Either<Failure, DriverRewardsPointsModel>> rewardPointsPost(
      {required String amount});
  Future<Either<Failure, DriverDataModel>> getDrivers();
  Future<Either<Failure, DriverDataModel>> deleteDrivers(
      {required String driverId});
  Future<Either<Failure, OwnerVehicleModel>> getVehicles();
  Future<Either<Failure, OwnerVehicleModel>> assignDriver(
      {required String fleetId, required String driverId});
  Future<Either<Failure, DriverDataModel>> addDrivers(
      {required String name,
      required String email,
      required String mobile,
      required String address});

  Future<Either<Failure, DailyEarningsModel>> getDailyEarnings(
      {required String date});

  Future<Either<Failure, OwnerDashboardModel>> getOwnerDashboard();

  Future<Either<Failure, DriverLevelsModel>> getDriverLevels(int page);
  Future<Either<Failure, DriverRewardsModel>> getDriverRewards(int page);
  Future<Either<Failure, FleetDashboardModel>> getFleetDashboard(
      {required String fleetId});
  Future<Either<Failure, DriverPerformanceModel>> getDriverPerformance(
      {required String driverId});
  Future<Either<Failure, LeaderBoardModel>> getLeaderBoard(
      {required int type, required String lat, required String lng});

  Future<Either<Failure, IncentiveModel>> getIncentive({required int type});
  Future<Either<Failure, BankDetailsModel>> getBankDetails();
  Future<Either<Failure, BankDetailsUpdateModel>> updateBankDetails(
      {required dynamic body});
  Future<Either<Failure, WithdrawModel>> getWithdrawData(int page);
  Future<Either<Failure, WithdrawRequestModel>> requestWithdraw(
      {required String amount});
}
