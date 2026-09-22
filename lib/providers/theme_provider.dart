import 'package:flutter/material.dart';

import '../services/preferences_helper.dart';

/// يدير وضع الثيم (فاتح/غامق/تلقائي) ويحفظه محليًا حتى يضل نفس الاختيار
/// حتى لو المستخدم سكر التطبيق وفتحه من جديد.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemeMode() async {
    _themeMode = await PreferencesHelper.getThemeMode();
    notifyListeners();
  }

  /// يبدّل الوضع بالترتيب: نظام ← فاتح ← غامق ← نظام ...
  Future<void> cycleThemeMode() async {
    final next = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await PreferencesHelper.setThemeMode(mode);
  }
}
