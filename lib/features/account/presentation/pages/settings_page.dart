import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/faq_page.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/top_bar.dart';
import 'package:restart_tagxi/features/language/presentation/page/choose_language_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/app_constants.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_dialoges.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/pages/user_choose_page.dart';
import '../widgets/page_options.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settingsPage';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is LogoutSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              SelectUserPage.routeName,
              (route) => false,
            );
            await AppSharedPreference.logoutRemove();
          } else if (state is DeleteAccountSuccess) {
            Navigator.pushNamedAndRemoveUntil(
                context, ChooseLanguagePage.routeName, (route) => false,
                arguments: ChangeLanguageArguments(from: 0));
            await AppSharedPreference.setLoginStatus(false);
            await AppSharedPreference.setToken('');
          } else if (state is DeleteAccountFailureState) {
            Navigator.of(context).pop(); // Dismiss the dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            body: TopBarDesign(
              onTap: () {
                Navigator.pop(context);
              },
              isHistoryPage: false,
              title: AppLocalizations.of(context)!.settings,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.04,
                    ),
                    PageOptions(
                      list: AppLocalizations.of(context)!.faq,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          FaqPage.routeName,
                        );
                      },
                    ),
                    PageOptions(
                      list: AppLocalizations.of(context)!.privacy,
                      onTap: () async {
                        const browseUrl = AppConstants.privacyPolicy;
                        if (browseUrl.isNotEmpty) {
                          await launchUrl(Uri.parse(browseUrl));
                        } else {
                          throw 'Could not launch $browseUrl';
                        }
                      },
                    ),
                    PageOptions(
                      list: AppLocalizations.of(context)!.logout,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext _) {
                            return BlocProvider.value(
                              value: BlocProvider.of<AccBloc>(context),
                              child: CustomSingleButtonDialoge(
                                title:
                                    AppLocalizations.of(context)!.comeBackSoon,
                                content:
                                    AppLocalizations.of(context)!.logoutSure,
                                btnName: AppLocalizations.of(context)!.confirm,
                                onTap: () {
                                  context.read<AccBloc>().add(LogoutEvent());
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    PageOptions(
                      list: AppLocalizations.of(context)!.deleteAccount,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext _) {
                            return BlocProvider.value(
                              value: BlocProvider.of<AccBloc>(context),
                              child: CustomSingleButtonDialoge(
                                title:
                                    '${AppLocalizations.of(context)!.deleteAccount} ?',
                                content:
                                    AppLocalizations.of(context)!.deleteText,
                                btnName:
                                    AppLocalizations.of(context)!.deleteAccount,
                                onTap: () {
                                  context
                                      .read<AccBloc>()
                                      .add(DeleteAccountEvent());
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
