import 'package:flutter/material.dart';

import '../services/preferences_helper.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// شاشة البداية: تظهر لثانيتين، وبنفس الوقت بنتحقق من SharedPreferences
/// حتى نعرف نوجّه المستخدم على شاشة Onboarding (أول مرة) أو مباشرة Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    // تأخير بسيط حتى تظهر شاشة البداية بشكل طبيعي (مش قصيرة كتير)
    final onboardingSeenFuture = PreferencesHelper.isOnboardingSeen();
    final results = await Future.wait([
      onboardingSeenFuture,
      Future.delayed(const Duration(seconds: 2)),
    ]);

    final bool onboardingSeen = results[0] as bool;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            onboardingSeen ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 96,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'المهام اليومية',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
