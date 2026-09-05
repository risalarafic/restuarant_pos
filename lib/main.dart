import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api/auth_api.dart';
import 'auth/auth_session.dart';
import 'screens/login_screen.dart';
import 'screens/pos_dashboard.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const RestaurantPosApp());
}

class RestaurantPosApp extends StatefulWidget {
  const RestaurantPosApp({
    super.key,
    this.authApi,
    this.restoreSession = true,
  });

  final AuthApi? authApi;
  final bool restoreSession;

  @override
  State<RestaurantPosApp> createState() => _RestaurantPosAppState();
}

class _RestaurantPosAppState extends State<RestaurantPosApp> {
  late final AuthApi _authApi;
  AuthSession? _session;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _authApi = widget.authApi ?? RemoteAuthApi();
    if (widget.restoreSession) {
      _restoreSession();
    } else {
      _ready = true;
    }
  }

  Future<void> _restoreSession() async {
    final session = await AuthStorage.loadSession();
    if (!mounted) return;
    setState(() {
      _session = session;
      _ready = true;
    });
  }

  Future<void> _logout() async {
    await AuthStorage.clearSession();
    if (!mounted) return;
    setState(() => _session = null);
  }

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
      home: !_ready
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _session != null
              ? PosDashboard(
                  session: _session!,
                  onLogout: _logout,
                )
              : LoginScreen(
                  authApi: _authApi,
                  onLoginSuccess: (session) => setState(() => _session = session),
                ),
    );
  }
}
