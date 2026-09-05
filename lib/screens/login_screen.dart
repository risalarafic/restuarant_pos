import 'package:flutter/material.dart';

import '../api/auth_api.dart';
import '../api/login_response.dart';
import '../auth/auth_session.dart';
import '../auth/demo_auth.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authApi,
    required this.onLoginSuccess,
  });

  final AuthApi authApi;
  final ValueChanged<AuthSession> onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: DemoAuth.email);
  final _passwordController = TextEditingController(text: DemoAuth.password);
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _rememberMe = true;
  String? _authError;

  @override
  void initState() {
    super.initState();
    _restoreRememberedLogin();
  }

  Future<void> _restoreRememberedLogin() async {
    final saved = await DemoAuth.loadRemembered();
    if (!mounted) return;
    setState(() {
      _rememberMe = saved.remember == true;
      _emailController.text = saved.email;
      _passwordController.text = saved.password;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _authError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final result = await widget.authApi.login(
        username: email,
        password: password,
      );
      // Attach email & password to user so DashboardApi can reuse them
      final rawUser = result.user!;
      final userWithCreds = LoginUserDetails(
        id: rawUser.id,
        name: rawUser.name,
        restaurantId: rawUser.restaurantId,
        restaurantName: rawUser.restaurantName,
        email: email.trim(),
        password: password,
      );
      final session = AuthSession(
        authToken: result.authToken!,
        user: userWithCreds,
      );
      await AuthStorage.saveSession(session);
      await DemoAuth.saveRemembered(
        remember: _rememberMe,
        email: email,
        password: password,
      );
      if (!mounted) return;
      widget.onLoginSuccess(session);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _authError = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _authError = 'Unable to sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  const Expanded(child: _BrandPanel()),
                  Expanded(child: Center(child: _buildFormCard())),
                ],
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const _CompactBrand(),
                      const SizedBox(height: 24),
                      _buildFormCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFormCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to continue to the POS dashboard',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                enabled: !_isSubmitting,
                validator: DemoAuth.validateEmail,
                onChanged: (_) {
                  if (_authError != null) setState(() => _authError = null);
                },
                decoration: _fieldDecoration(
                  hint: 'you@restaurant.com',
                  prefix: Icons.mail_outline,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                enabled: !_isSubmitting,
                validator: DemoAuth.validatePassword,
                onFieldSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_authError != null) setState(() => _authError = null);
                },
                decoration: _fieldDecoration(
                  hint: 'Enter password',
                  prefix: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              if (_authError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _authError!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              InkWell(
                onTap: _isSubmitting
                    ? null
                    : () => setState(() => _rememberMe = !_rememberMe),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _rememberMe
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _rememberMe
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1.6,
                          ),
                        ),
                        child: _rememberMe
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.6,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefix, color: AppColors.textSecondary),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6A3D), Color(0xFFE55A30), Color(0xFFC2410C)],
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LogoMark(
                size: 88,
                iconSize: 46,
                background: Color(0x29FFFFFF),
                border: Color(0x59FFFFFF),
                iconColor: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Kudeghor POS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Restaurant Point of Sale',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 28),
              Text(
                'Take orders, assign tables, and send KOTs\nfrom one simple dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFE8DE),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _LogoMark(
          size: 64,
          iconSize: 32,
          background: AppColors.primary,
          border: AppColors.primary,
          iconColor: Colors.white,
        ),
        SizedBox(height: 12),
        Text(
          'Kudeghor POS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({
    required this.size,
    required this.iconSize,
    required this.background,
    required this.border,
    required this.iconColor,
  });

  final double size;
  final double iconSize;
  final Color background;
  final Color border;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Icon(
        Icons.local_cafe_rounded,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}
