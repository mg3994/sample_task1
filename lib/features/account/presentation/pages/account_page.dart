import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/admin_chat.dart';
import 'package:restart_tagxi/features/account/presentation/pages/company_information_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/complaint_list.dart';
import 'package:restart_tagxi/features/account/presentation/pages/driver_levels_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/driver_rewards_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/drivers_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/edit_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/history_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/incentive_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/owner_dashboard.dart';
import 'package:restart_tagxi/features/account/presentation/pages/referral_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/settings_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/sos_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/subscription_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/vehicle_data_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/wallet_page.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/page_options.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/profile_design.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import 'package:restart_tagxi/features/language/presentation/page/choose_language_page.dart';
import '../../../../common/app_arguments.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../l10n/app_localizations.dart';
import 'notification_page.dart';

class AccountPage extends StatelessWidget {
  static const String routeName = '/accountPage';
  final AccountPageArguments arg;

  const AccountPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          }
          if (state is UserDetailState) {
            Navigator.pushNamed(
              context,
              EditPage.routeName,
            ).then(
              (value) {
                if (!context.mounted) return;
                context.read<AccBloc>().add(AccGetUserDetailsEvent());
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(buildWhen: (previous, current) {
          // Avoid rebuild if the state has not changed meaningfully
          return previous.runtimeType != current.runtimeType;
        }, builder: (context, state) {
          return (userData != null)
              ? Scaffold(
                  body: ProfileWidget(
                    isEditPage: false,
                    ratings: userData!.rating,
                    trips: userData!.totalRidesTaken!,
                    profileUrl: userData!.profilePicture,
                    userName: userData!.name,
                    todaysEarnings:
                        '${userData!.currencySymbol}${userData!.totalEarnings!}',
                    wallet: userData!.showWalletFeatureOnMobileApp == '1'
                        ? '${userData!.currencySymbol}${userData!.wallet?.data.amountBalance ?? 0.0}'
                        : '',
                    showWallet: userData!.showWalletFeatureOnMobileApp == '1',
                    child: SizedBox(
                      // height: size.height * 0.7 - size.width * 0.2,
                      height: size.height * 0.65,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              userData!.role == 'driver'
                                  ? SizedBox(height: size.width * 0.2)
                                  : SizedBox(
                                      height: size.width * 0.15,
                                    ),
                              MyText(
                                  text: AppLocalizations.of(context)!.myAccount,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                          fontSize:
                                              AppConstants().subHeaderSize)),
                              PageOptions(
                                  list: AppLocalizations.of(context)!
                                      .personalInformation,
                                  onTap: () {
                                    Navigator.pushNamed(
                                            context, EditPage.routeName,
                                            arguments: arg)
                                        .then((value) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(UpdateEvent());
                                    });
                                  }),
                              if (userData!.role == 'owner')
                                PageOptions(
                                    list: AppLocalizations.of(context)!
                                        .companyInfo,
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                          CompanyInformationPage.routeName,
                                          arguments: arg);
                                    }),
                              if (userData!.role != 'owner')
                                PageOptions(
                                  list: AppLocalizations.of(context)!
                                      .notifications,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, NotificationPage.routeName);
                                  },
                                ),
                              PageOptions(
                                list: AppLocalizations.of(context)!.history,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, HistoryPage.routeName,
                                      arguments: HistoryAccountPageArguments(
                                          isFrom: 'account'));
                                },
                              ),
                              PageOptions(
                                list: userData!.role != 'owner'
                                    ? AppLocalizations.of(context)!.vehicleInfo
                                    : AppLocalizations.of(context)!.manageFleet,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    VehicleDataPage.routeName,
                                    arguments: VehicleDataArguments(from: 0),
                                  );
                                },
                              ),
                              if (userData!.role == 'owner')
                                PageOptions(
                                  list: AppLocalizations.of(context)!.drivers,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, DriversPage.routeName);
                                  },
                                ),
                              PageOptions(
                                list: AppLocalizations.of(context)!.documents,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, DriverProfilePage.routeName,
                                      arguments:
                                          VehicleUpdateArguments(from: 'docs'));
                                },
                              ),
                              if (userData!.role == 'owner')
                                PageOptions(
                                  list: AppLocalizations.of(context)!.dashboard,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      OwnerDashboard.routeName,
                                      arguments:
                                          OwnerDashboardArguments(from: ''),
                                    );
                                  },
                                ),
                              if (userData!.showWalletFeatureOnMobileApp == '1')
                                PageOptions(
                                  list: AppLocalizations.of(context)!.payment,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, WalletHistoryPage.routeName);
                                  },
                                ),
                              if (userData!.role == 'driver')
                                PageOptions(
                                  list: AppLocalizations.of(context)!
                                      .referAndEarn,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      ReferralPage.routeName,
                                      arguments: ReferralArguments(
                                          title: AppLocalizations.of(context)!
                                              .referAndEarn,
                                          userData: arg.userData),
                                    );
                                  },
                                ),
                              PageOptions(
                                list: AppLocalizations.of(context)!
                                    .changeLanguage,
                                onTap: () {
                                  Navigator.pushNamed(
                                          context, ChooseLanguagePage.routeName,
                                          arguments:
                                              ChangeLanguageArguments(from: 1))
                                      .then(
                                    (value) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(AccGetDirectionEvent());
                                    },
                                  );
                                },
                              ),
                              if (userData!.role == 'driver')
                                PageOptions(
                                  list: AppLocalizations.of(context)!.sosText,
                                  onTap: () {
                                    Navigator.pushNamed(
                                            context, SosPage.routeName,
                                            arguments: SOSPageArguments(
                                                sosData: userData!.sos!.data))
                                        .then(
                                      (value) {
                                        if (!context.mounted) return;
                                        if (value != null) {
                                          final sos = value as List<SOSDatum>;
                                          context.read<AccBloc>().sosdata = sos;
                                          userData!.sos!.data =
                                              context.read<AccBloc>().sosdata;
                                          context
                                              .read<AccBloc>()
                                              .add(UpdateEvent());
                                        }
                                      },
                                    );
                                  },
                                ),
                              if (userData!.role == 'driver' &&
                                  userData!.hasSubscription! &&
                                  (userData!.driverMode == 'subscription' ||
                                      userData!.driverMode == 'both'))
                                PageOptions(
                                  list: AppLocalizations.of(context)!
                                      .subscription,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      SubscriptionPage.routeName,
                                      arguments: SubscriptionPageArguments(
                                          isFromAccPage: true),
                                    ).then((value) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(UpdateEvent());
                                    });
                                  },
                                ),
                              if (userData!.role == 'driver' &&
                                  userData!.showIncentiveFeatureForDriver ==
                                      "1" &&
                                  userData!.availableIncentive != null)
                                PageOptions(
                                  list:
                                      AppLocalizations.of(context)!.incentives,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      IncentivePage.routeName,
                                    );
                                  },
                                ),
                              if (userData!.role == 'driver' &&
                                  userData!.showDriverLevel == true)
                                PageOptions(
                                  list:
                                      AppLocalizations.of(context)!.levelupText,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      DriverLevelsPage.routeName,
                                    );
                                  },
                                ),
                              if (userData!.role == 'driver' &&
                                  userData!.showDriverLevel == true)
                                PageOptions(
                                  list:
                                      AppLocalizations.of(context)!.rewardsText,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      DriverRewardsPage.routeName,
                                    );
                                  },
                                ),
                              const SizedBox(height: 20),
                              MyText(
                                text: AppLocalizations.of(context)!.general,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontSize: AppConstants().subHeaderSize),
                              ),
                              PageOptions(
                                list: AppLocalizations.of(context)!.chatWithUs,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AdminChat.routeName);
                                },
                              ),
                              PageOptions(
                                list:
                                    AppLocalizations.of(context)!.makeComplaint,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ComplaintListPage.routeName,
                                      arguments: ComplaintListPageArguments(
                                          choosenHistoryId: ''));
                                },
                              ),
                              PageOptions(
                                list: AppLocalizations.of(context)!.settings,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, SettingsPage.routeName);
                                },
                              ),
                              SizedBox(height: size.width * 0.25)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const Scaffold(
                  body: Loader(),
                );
        }),
      ),
    );
  }
}
