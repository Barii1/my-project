import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import '../services/connectivity_service.dart';
import 'create_account_screen.dart';
import 'home_screen_v3.dart';
import '../services/xp_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppTheme.scaledPadding(context, horizontal: 20, vertical: 20),
            child: RepaintBoundary(
              child: Card(
                elevation: 4, // lower elevation to reduce blur/shadow cost
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: AppTheme.scaledPadding(context, horizontal: 24, vertical: 24),
                  child: const LogIn(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _logFcmToken();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!context.mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        // Award XP for first login of day and recompute streak
        try {
          await XpService().awardXpForLogin();
        } catch (e) {
          debugPrint('XP login award failed: $e');
        }
        // Defer navigation to next frame to avoid race with rebuilds
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreenV3()),
            (route) => false,
          );
        });
        return;
      }

      final err = auth.lastError ?? 'Invalid email or password';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: $e')));
    }
  }

  Future<void> _logFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');
      if (token != null) {
        debugPrint('FCM token: $token');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectivity = Provider.of<ConnectivityService>(context);
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Offline mode indicator
          if (connectivity.isOffline)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline Mode - You can still login if previously logged in',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Icon(
            Icons.school,
            size: AppTheme.scaledFontSize(context, 48),
            color: AppTheme.primary,
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 24).height),
          Text('Welcome Back', textAlign: TextAlign.center, style: AppTheme.heading1(context).copyWith(color: isDark ? Colors.white : null)),
          SizedBox(height: AppTheme.scaledSize(context, 0, 8).height),
          Text('Log in to continue learning', textAlign: TextAlign.center, style: AppTheme.caption(context).copyWith(color: isDark ? Colors.white70 : null)),
          SizedBox(height: AppTheme.scaledSize(context, 0, 40).height),
          TextFormField(
            controller: _emailController,
            style: AppTheme.bodyText(context).copyWith(color: isDark ? Colors.white : null),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: AppTheme.caption(context).copyWith(color: isDark ? Colors.white70 : null),
              hintText: 'Your email@example.com',
              hintStyle: AppTheme.caption(context).copyWith(color: isDark ? Colors.white38 : Colors.black38),
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!value.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 20).height),
          TextFormField(
            controller: _passwordController,
            style: AppTheme.bodyText(context).copyWith(color: isDark ? Colors.white : null),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: AppTheme.caption(context).copyWith(color: isDark ? Colors.white70 : null),
              hintText: 'Enter your password',
              hintStyle: AppTheme.caption(context).copyWith(color: isDark ? Colors.white38 : Colors.black38),
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.withOpacityFixed(AppTheme.primary, 0.7)),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 32).height),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _handleLogin(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: AppTheme.scaledPadding(context, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: Size(double.infinity, AppTheme.scaledSize(context, 0, 48).height),
            ),
            child: _isLoading
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : Text('Log in', style: AppTheme.bodyText(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 16).height),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccountScreen())),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.caption(context),
                    children: [
                      TextSpan(text: "Don't have an account? ", style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textSecondary)),
                      TextSpan(text: "Create one", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}