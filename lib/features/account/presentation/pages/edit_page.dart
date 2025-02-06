import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/presentation/pages/update_details.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/edit_options.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/profile_design.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/auth_page.dart';
import '../../../../common/app_arguments.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/acc_bloc.dart';

class EditPage extends StatelessWidget {
  static const String routeName = '/editPage';

  const EditPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(AccGetUserDetailsEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is UserProfileDetailsLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is UpdatedUserDetailsState) {}
          if (state is UpdateUserDetailsFailureState) {
            context.showSnackBar(
                message: AppLocalizations.of(context)!.failToUpdateDetails);
          }
          if (state is UserDetailsButtonSuccess) {
            context.read<AccBloc>().add(AccGetUserDetailsEvent());
          }
          if (state is UserUnauthenticatedState) {
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
          }
          if (state is UserDetailEditState) {
            Navigator.pushNamed(
              context,
              UpdateDetails.routeName,
              arguments: UpdateDetailsArguments(
                  header: state.header, text: state.text, userData: userData!),
            ).then(
              (value) {
                // ignore: use_build_context_synchronously
                context.read<AccBloc>().add(AccGetUserDetailsEvent());
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return (userData != null)
                ? Scaffold(
                    body: ProfileWidget(
                      isEditPage: true,
                      ratings: '',
                      trips: '',
                      todaysEarnings: '',
                      showWallet: false,
                      profileUrl: userData!.profilePicture,
                      userName: userData!.name,
                      backOnTap: () {
                        Navigator.pop(context, userData);
                      },
                      wallet: userData!.wallet != null
                          ? '${userData!.currencySymbol}${userData!.wallet!.data.amountBalance}'
                          : '',
                      child: SizedBox(
                        height: size.height * 0.7 - size.width * 0.2,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .personalInformation,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.bold,fontSize: 18),
                                ),
                                const SizedBox(height: 10),
                                EditOptions(
                                  text: userData!.name,
                                  header: AppLocalizations.of(context)!.name,
                                  onTap: () {
                                    context
                                        .read<AccBloc>()
                                        .add(UserDetailEditEvent(
                                          header: AppLocalizations.of(context)!
                                              .name,
                                          text: userData!.name,
                                        ));
                                  },
                                ),
                                EditOptions(
                                  text: userData!.mobile,
                                  header: AppLocalizations.of(context)!.mobile,
                                  onTap: () {},
                                ),
                                EditOptions(
                                  text: userData!.email,
                                  header: AppLocalizations.of(context)!.email,
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                        UserDetailEditEvent(
                                            header:
                                                AppLocalizations.of(context)!
                                                    .email,
                                            text: userData!.email));
                                  },
                                ),
                                EditOptions(
                                  text: userData!.gender != ''
                                      ? userData!.gender
                                      : "${AppLocalizations.of(context)!.update} ${AppLocalizations.of(context)!.gender}",
                                  header: AppLocalizations.of(context)!.gender,
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                          UserDetailEditEvent(
                                            header:
                                                AppLocalizations.of(context)!
                                                    .gender,
                                            text: userData!.gender,
                                          ),
                                        );
                                  },
                                ),
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
          },
        ),
      ),
    );
  }
}
