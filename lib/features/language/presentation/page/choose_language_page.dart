import 'package:flutter/material.dart';
import 'package:restart_tagxi/app/localization.dart';
import '../../../../common/app_constants.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_background.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_text.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../loading/presentation/loader.dart';
import '../../application/language_bloc.dart';
import '../../domain/models/language_listing_model.dart';

class ChooseLanguagePage extends StatelessWidget {
  static const String routeName = '/chooseLanguage';
  final ChangeLanguageArguments? args;

  const ChooseLanguagePage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return builderList(size);
  }

  Widget builderList(Size size) {
    return BlocProvider(
      create: (context) => LanguageBloc()
        ..add(LanguageInitialEvent())
        ..add(LanguageGetEvent(from: args != null ? args!.from : 0)),
      child: BlocListener<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageInitialState) {
            CustomLoader.loader(context);
          }
          if (state is LanguageLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is LanguageSuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is LanguageFailureState) {
            CustomLoader.dismiss(context);
          }
          if (state is LanguageAlreadySelectedState) {
            context.read<LocalizationBloc>().add(LocalizationInitialEvent(
              isDark: Theme.of(context).brightness == Brightness.dark,
                locale: Locale(context.read<LanguageBloc>().choosedLanguage)));
            if (args == null || args!.from == 0) {
              Navigator.pushNamedAndRemoveUntil(
                  context, LoaderPage.routeName, (route) => false);
            }
          }
          if (state is LanguageUpdateState) {
            if (args == null || args!.from == 0) {
              // Navigator.pushNamedAndRemoveUntil(
              //     context, SelectUserPage.routeName, (route) => false);
              Navigator.pushNamedAndRemoveUntil(
                  context, LoaderPage.routeName, (route) => false);
            } else {
              Navigator.pop(context);
            }
          }
        },
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return PopScope(
              canPop: (args != null && args!.from == 1) ? true : false,
              child: Scaffold(
                body: (context
                            .read<LanguageBloc>()
                            .choosedLanguage
                            .isNotEmpty &&
                        (args == null))
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.loader,
                              width: size.width * 0.51,
                              height: size.height * 0.51,
                            )
                          ],
                        ),
                      )
                    : CustomBackground(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height: size.width * 0.05 +
                                      MediaQuery.of(context).padding.top),
                              Row(
                                children: [
                                  if (args != null && args!.from == 1)
                                    Row(
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                              context
                                                  .read<LocalizationBloc>()
                                                  .add(LocalizationInitialEvent(
                                                    isDark: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark,
                                                      locale: Locale(context
                                                          .read<LanguageBloc>()
                                                          .choosedLanguage)));
                                            },
                                            child: Icon(
                                              Icons.arrow_back,
                                              size: size.width * 0.07,
                                              color: AppColors.black,
                                            )),
                                        SizedBox(
                                          width: size.width * 0.05,
                                        )
                                      ],
                                    ),
                                  MyText(
                                      text: (args != null && args!.from == 1)
                                          ? AppLocalizations.of(context)!
                                              .changeLanguage
                                          : AppLocalizations.of(context)!
                                              .chooseLanguage,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color: AppColors.blackText,
                                              fontSize: 18)),
                                ],
                              ),
                              SizedBox(height: size.width * 0.02),
                              // if (context
                              //     .read<LanguageBloc>()
                              //     .languageList
                              //     .isNotEmpty) ...[
                              // buildLanguageList(
                              //     size, context.read<LanguageBloc>().languageList),
                              buildLanguageList(
                                  size, AppConstants.languageList),
                              SizedBox(height: size.width * 0.05),
                              selectButton(size, context),
                              // ],
                            ],
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildLanguageList(Size size, List<LocaleLanguageList> languageList) {
    return languageList.isNotEmpty
        ? SizedBox(
            height: size.height * 0.7,
            child: RawScrollbar(
              radius: const Radius.circular(20),
              child: ListView.builder(
                itemCount: languageList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 8),
                    child: InkWell(
                      onTap: () {
                        context.read<LanguageBloc>().add(
                            LanguageSelectEvent(selectedLanguageIndex: index));
                        context.read<LocalizationBloc>().add(
                            LocalizationInitialEvent(
                              isDark: Theme.of(context).brightness ==
                                    Brightness.dark,
                                locale: Locale(languageList[index].lang)));
                      },
                      child: Container(
                        height: 50,
                        width: size.width,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color:
                                  (context.read<LanguageBloc>().selectedIndex ==
                                          index)
                                      ? AppColors.black
                                      : AppColors.white,
                              width:
                                  (context.read<LanguageBloc>().selectedIndex ==
                                          index)
                                      ? 2.0
                                      : 1.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: MyText(
                              text: languageList[index].name,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: AppColors.blackText,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : const SizedBox();
  }

  Widget selectButton(Size size, BuildContext context) {
    return Center(
      child: CustomButton(
        buttonName: AppLocalizations.of(context)!.select,
        height: size.width * 0.15,
        width: size.width * 0.85,
        onTap: () async {
          final selectedIndex = context.read<LanguageBloc>().selectedIndex;
          context.read<LanguageBloc>().add(LanguageSelectUpdateEvent(
              selectedLanguage:
                  AppConstants.languageList.elementAt(selectedIndex).lang));
        },
      ),
    );
  }
}
