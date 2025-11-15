import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import 'create_account_screen.dart';
import 'home_screen_v3.dart';

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
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
              ),
              child: Padding(
                padding: AppTheme.scaledPadding(context, horizontal: 24, vertical: 24),
                child: const LogIn(),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final success = await auth.login(
          _emailController.text,
          _passwordController.text,
        );

        if (!context.mounted) return;

        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreenV3()),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school,
            size: AppTheme.scaledFontSize(context, 48),
            color: AppTheme.primary,
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 24).height),
          Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: AppTheme.heading1(context),
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 8).height),
          Text(
            'Log in to continue learning',
            textAlign: TextAlign.center,
            style: AppTheme.caption(context),
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 40).height),
          TextFormField(
            controller: _emailController,
            style: AppTheme.bodyText(context),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: AppTheme.caption(context),
              hintText: 'Your email@example.com',
              hintStyle: AppTheme.caption(context).copyWith(color: Colors.black38),
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 20).height),
          TextFormField(
            controller: _passwordController,
            style: AppTheme.bodyText(context),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: AppTheme.caption(context),
              hintText: 'Enter your password',
              hintStyle: AppTheme.caption(context).copyWith(color: Colors.black38),
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.withOpacityFixed(AppTheme.primary, 0.7),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 32).height),
          ElevatedButton(
            onPressed: () => _handleLogin(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: AppTheme.scaledPadding(context, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(double.infinity, AppTheme.scaledSize(context, 0, 48).height),
            ),
            child: Text(
              'Log in',
              style: AppTheme.bodyText(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 16).height),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateAccountScreen(),
                ),
              );
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTheme.caption(context),
                children: [
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  TextSpan(
                    text: "Create one",
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}