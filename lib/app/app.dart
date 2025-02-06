import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/app/localization.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/auth/application/auth_bloc.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/landing/application/onboarding_bloc.dart';
import 'package:restart_tagxi/features/language/application/language_bloc.dart';
import '../../../../common/common.dart';
import '../core/utils/custom_loader.dart';
import '../features/language/presentation/page/choose_language_page.dart';
import '../features/loading/application/loading_bloc.dart';
import '../l10n/app_localizations.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocalizationBloc()..add(LocalizationGetEvent())),
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => HomeBloc()),
        BlocProvider(create: (context) => AccBloc()),
        BlocProvider(create: (context) => LoaderBloc()),
        BlocProvider(create: (context) => DriverProfileBloc()),
        BlocProvider(create: (context) => LanguageBloc()),
        BlocProvider(create: (context) => OnBoardingBloc()),
      ],
      child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, state) {
          Locale locale = (state is LocalizationInitialState)
              ? state.locale
              : const Locale('en');
          bool isDark =
              (state is LocalizationInitialState) ? state.isDark : false;  
          return GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: MaterialApp(
                scaffoldMessengerKey: scaffoldMessengerKey,
                debugShowCheckedModeBanner: false,
                theme: AppThemes.applicationDefaultTheme(context),
                onGenerateRoute: AppRoutes.onGenerateRoutes,
                onUnknownRoute: AppRoutes.onUnknownRoute,
                initialRoute: ChooseLanguagePage.routeName,
                navigatorKey: navigatorKey,
                title: AppConstants.title,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                locale: locale,
                darkTheme: AppThemes.darkTheme(context),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              ),
            ),
          );
        },
      ),
    );
  }
}
