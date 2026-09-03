import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/login_screen.dart';
import 'screens/pos_dashboard.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const RestaurantPosApp());
}

class RestaurantPosApp extends StatefulWidget {
  const RestaurantPosApp({super.key});

  @override
  State<RestaurantPosApp> createState() => _RestaurantPosAppState();
}

class _RestaurantPosAppState extends State<RestaurantPosApp> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kudeghor POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      home: _isLoggedIn
          ? PosDashboard(
              onLogout: () => setState(() => _isLoggedIn = false),
            )
          : LoginScreen(
              onLoginSuccess: () => setState(() => _isLoggedIn = true),
            ),
    );
  }
}
