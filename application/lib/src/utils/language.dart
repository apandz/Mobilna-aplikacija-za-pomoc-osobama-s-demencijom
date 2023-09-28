import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String constLanguageCode = 'languageCode';

const String english = 'en';
const String bosnian = 'bs';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString(constLanguageCode, languageCode);
  return Locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String languageCode = preferences.getString(constLanguageCode) ?? english;
  return Locale(languageCode);
}
