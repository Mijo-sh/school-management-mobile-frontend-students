import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalization {
  final Locale? locale;

  AppLocalization({required this.locale});

  static AppLocalization? of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  static const LocalizationsDelegate<AppLocalization> delegate = _AppLocalizationDelegate();
  late Map<String, String> _localizedStrings;

  Future loadJsonLanguage() async {
    String jsonString = await rootBundle.loadString("assets/lang/${locale!.languageCode}.json");
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  String translate(String key) => _localizedStrings[key] ?? "";

  String translateWithArgs(String key, [Map<String, String>? args]) {
    String text = _localizedStrings[key] ?? "";
    if (args != null) {
      args.forEach((argKey, value) {
        text = text.replaceAll('{$argKey}', value);
      });
    }
    return text;
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization localization = AppLocalization(locale: locale);
    await localization.loadJsonLanguage();
    return localization;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalization> old) => false;
}

extension TranslateX on String {
  String tr(BuildContext context) {
    return AppLocalization.of(context)!.translate(this);
  }
}
extension TranslateArgsX on String {
  String trArgs(BuildContext context, {Map<String, String>? args}) {
    return AppLocalization.of(context)!.translateWithArgs(this, args);
  }
}