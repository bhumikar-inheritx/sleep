import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _storageKey = 'selected_language';
  
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() {
    final langCode = StorageService.getString(_storageKey) ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await StorageService.setString(_storageKey, locale.languageCode);
    notifyListeners();
  }

  // Simple translation helper for demo purposes
  String translate(String key) {
    final translations = {
      'en': {
        'home': 'Home',
        'explore': 'Explore',
        'journal': 'Journal',
        'alarm': 'Alarm',
        'profile': 'Profile',
        'good_evening': 'Good Evening',
        'go_premium': 'GO PREMIUM',
        'tonight_recommendation': 'Tonight\'s Recommendation',
        'nightly_ritual': 'Nightly Ritual',
      },
      'es': {
        'home': 'Inicio',
        'explore': 'Explorar',
        'journal': 'Diario',
        'alarm': 'Alarma',
        'profile': 'Perfil',
        'good_evening': 'Buenas Noches',
        'go_premium': 'HACERSE PREMIUM',
        'tonight_recommendation': 'Recomendación de Hoy',
        'nightly_ritual': 'Ritual Nocturno',
      },
      'hi': {
        'home': 'होम',
        'explore': 'एक्सप्लोर',
        'journal': 'जर्नल',
        'alarm': 'अलार्म',
        'profile': 'प्रोफ़ाइल',
        'good_evening': 'शुभ संध्या',
        'go_premium': 'प्रीमियम लें',
        'tonight_recommendation': 'आज की सिफारिश',
        'nightly_ritual': 'रात्रि अनुष्ठान',
      }
    };

    return translations[_locale.languageCode]?[key] ?? key;
  }
}
