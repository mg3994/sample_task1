import 'package:flutter/material.dart';
import 'package:restart_tagxi/features/account/presentation/pages/account_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/admin_chat.dart';
import 'package:restart_tagxi/features/account/presentation/pages/company_information_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/complaint_list.dart';
import 'package:restart_tagxi/features/account/presentation/pages/complaint_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/driver_levels_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/driver_performance_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/driver_rewards_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/drivers_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/earnings_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/edit_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/faq_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/fleet_dashboard_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/history_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/incentive_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/leaderboard_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/notification_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/outstation_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/owner_dashboard.dart';
import 'package:restart_tagxi/features/account/presentation/pages/referral_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/settings_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/sos_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/subscription_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/trip_summary_history.dart';
import 'package:restart_tagxi/features/account/presentation/pages/update_details.dart';
import 'package:restart_tagxi/features/account/presentation/pages/vehicle_data_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/wallet_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/withdraw_page.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/user_choose_page.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import '../core/error/error_page.dart';
import '../features/account/presentation/pages/paymentgateways.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/refferal_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/update_password_page.dart';
import '../features/auth/presentation/pages/verify_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/landing/presentation/page/landing_page.dart';
import '../features/language/presentation/page/choose_language_page.dart';
import '../features/loading/presentation/loader.dart';
import 'app_arguments.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoutes(RouteSettings routeSettings) {
    late Route<dynamic> pageRoute;
    Object? arg = routeSettings.arguments;

    switch (routeSettings.name) {
      case LoaderPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const LoaderPage(),
        );
        break;
      case LandingPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => LandingPage(
            args: arg as LandingPageArguments,
          ),
        );
        break;
      case ChooseLanguagePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ChooseLanguagePage(
            args: arg != null ? arg as ChangeLanguageArguments : null,
          ),
        );
        break;
      case AuthPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => AuthPage(
            arg: arg as AuthPageArguments,
          ),
        );
        break;
      case VerifyPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => VerifyPage(
            arg: arg as VerifyArguments,
          ),
        );
        break;
      case RegisterPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => RegisterPage(
            arg: arg as RegisterPageArguments,
          ),
        );
        break;
      case RefferalPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const RefferalPage(),
        );
        break;
      case ForgotPasswordPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ForgotPasswordPage(
            arg: arg as ForgotPasswordPageArguments,
          ),
        );
        break;
      case UpdatePasswordPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => UpdatePasswordPage(
            arg: arg as UpdatePasswordPageArguments,
          ),
        );
        break;
      case HomePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => HomePage(
            args: (arg != null) ? arg as HomePageArguments : null,
          ),
        );
        break;
      case AccountPage.routeName:
        pageRoute = PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AccountPage(arg: arg as AccountPageArguments),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final curvedAnimation =
                CurvedAnimation(parent: animation, curve: curve);
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        );
        break;
      case DriverProfilePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) =>
              DriverProfilePage(args: arg as VehicleUpdateArguments),
        );
        break;
      case EditPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const EditPage(),
        );
        break;
      case OutstationPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const OutstationPage(),
        );
        break;
      case NotificationPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const NotificationPage(),
        );
        break;
      case HistoryPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) =>
              HistoryPage(args: arg as HistoryAccountPageArguments),
        );
        break;
      case ReferralPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ReferralPage(
            args: arg as ReferralArguments,
          ),
        );
        break;
      case ComplaintListPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ComplaintListPage(
            args: arg as ComplaintListPageArguments,
          ),
        );
        break;
      case HistoryTripSummaryPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) =>
              HistoryTripSummaryPage(arg: arg as HistoryPageArguments),
        );
        break;
      case VehicleDataPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => VehicleDataPage(
            args: arg as VehicleDataArguments,
          ),
        );
        break;
      case DriversPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const DriversPage(),
        );
        break;
      case ComplaintPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ComplaintPage(
            arg: arg as ComplaintPageArguments,
          ),
        );
        break;
      case UpdateDetails.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => UpdateDetails(
            arg: arg as UpdateDetailsArguments,
          ),
        );
        break;
      case SettingsPage.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const SettingsPage());
        break;
      case FaqPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const FaqPage(),
        );
        break;
      case WalletHistoryPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const WalletHistoryPage(),
        );
        break;

      case SosPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => SosPage(arg: arg as SOSPageArguments),
        );
        break;

      case AdminChat.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const AdminChat(),
        );
        break;
      case EarningsPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => EarningsPage(
            args: arg as EarningArguments,
          ),
        );
        break;
      case OwnerDashboard.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => OwnerDashboard(
            args: arg as OwnerDashboardArguments,
          ),
        );
        break;
      case FleetDashboard.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => FleetDashboard(
            args: arg as FleetDashboardArguments,
          ),
        );
        break;
      case DriverPerformancePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => DriverPerformancePage(
            args: arg as DriverDashboardArguments,
          ),
        );
        break;
      case PaymentGatewaysPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => PaymentGatewaysPage(
            arg: arg as PaymentGateWayPageArguments,
          ),
        );
        break;
      case LeaderboardPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const LeaderboardPage(),
        );
        break;
      case SubscriptionPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => SubscriptionPage(
            args: arg as SubscriptionPageArguments,
          ),
        );
        break;
      case WithdrawPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const WithdrawPage(),
        );
        break;
      case CompanyInformationPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const CompanyInformationPage(),
        );
        break;
      case IncentivePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const IncentivePage(),
        );
        break;
      case SelectUserPage.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const SelectUserPage());
        break;
      case DriverLevelsPage.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const DriverLevelsPage());
        break;
      case DriverRewardsPage.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const DriverRewardsPage());
        break;
      default:
        pageRoute = MaterialPageRoute(
          builder: (context) => const LoaderPage(),
        );
    }
    return pageRoute;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (context) => const ErrorPage());
  }
}
