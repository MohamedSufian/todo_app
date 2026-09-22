import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// طبقة بسيطة فوق SharedPreferences.
/// مسؤولة عن: حالة "هل شاهد المستخدم Onboarding؟"، ووضع الثيم (فاتح/غامق/تلقائي).
class PreferencesHelper {
  static const String _onboardingSeenKey = 'onboarding_seen';
  static const String _themeModeKey = 'theme_mode'; // 'light' | 'dark' | 'system'

  /// يرجع true لو المستخدم شاف شاشات الـ Onboarding قبل هيك.
  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  /// يسجل إنه المستخدم خلص من شاشات الـ Onboarding، حتى ما تظهر له مرة ثانية.
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
  }

  /// وضع الثيم المحفوظ. الافتراضي: يتبع إعدادات الجهاز (system).
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeModeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// حفظ وضع الثيم المختار.
  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
}
