import 'dart:io';

import 'package:restart_tagxi/db/app_database.dart';

import '../features/language/domain/models/language_listing_model.dart';

class AppConstants {
  static const String title = 'DroppingRide';
  static const String baseUrl = 'https://onboarding.droppingride.com';
  static String firbaseApiKey = (Platform.isAndroid)
      ? "AIzaSyCMyZR-VFeMh4uc9aGMn1Bi0pjcw2jmbgo"
      : "ios firebase api key";
  static String firebaseAppId = (Platform.isAndroid)
      ? "1:331750600814:android:86373cf08e69c20aaef67f"
      : "ios firebase app id";
  static String firebasemessagingSenderId =
      (Platform.isAndroid) ? "331750600814" : "ios firebase sender id";
  static String firebaseProjectId =
      (Platform.isAndroid) ? "dropping-app-2025" : "ios firebase project id";

  static String mapKey =
      (Platform.isAndroid) ? "android map key" : 'ios map key';
  static const String privacyPolicy = 'your privacy policy url';
  static const String termsCondition = 'your terms and condition url';

  static List<LocaleLanguageList> languageList = [
    LocaleLanguageList(name: 'English', lang: 'en'),
    LocaleLanguageList(name: 'Arabic', lang: 'ar'),
    LocaleLanguageList(name: 'French', lang: 'fr'),
    LocaleLanguageList(name: 'Spanish', lang: 'es')
  ];
  static String packageName = 'com.droppingride.driver';
  static String signKey =
      '91:DE:F4:F1:B0:57:E0:D3:1F:6E:B3:09:A1:FA:65:86:82:A7:DC:93';
  double headerSize = 18.0;
  double subHeaderSize = 16.0;
  double buttonTextSize = 20.0;
}

bool showBubbleIcon = false;
bool subscriptionSkip = false;
String choosenLanguage = 'en';
String languageDirection = 'ltr';
String mapType = 'google_map';

AppDatabase db = AppDatabase();
