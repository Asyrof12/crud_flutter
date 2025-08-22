import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/lang.dart';

class AppLanguage extends ChangeNotifier {
  String _currentLang = 'id'; // default Bahasa Indonesia

  String get currentLang => _currentLang;

  AppLanguage() {
    _loadLang();
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString('lang') ?? 'id';
    notifyListeners();
  }

  Future<void> changeLang(String langCode) async {
    _currentLang = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', langCode);
    notifyListeners();
  }

  String getText(String key) {
    return Lang.texts[_currentLang]?[key] ?? key;
  }
}
