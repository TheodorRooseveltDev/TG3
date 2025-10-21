import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.colorPrimaryDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const FishQuestApp());
}

class FishQuestApp extends StatelessWidget {
  const FishQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: MaterialApp(
        title: 'FishQuest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash screen for minimum 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const SplashScreen();
        }

        if (!appProvider.hasCompletedOnboarding) {
          return const OnboardingScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
