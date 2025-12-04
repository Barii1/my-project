import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import '../services/email_pin_service.dart';
import 'login_screen.dart';
import 'home_screen_v3.dart';
import 'package:flutter_figma/lib/Email%20Verification/pin_verify_screen.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

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
                child: const CreateAccountForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateAccountForm extends StatefulWidget {
  const CreateAccountForm({super.key});

  @override
  State<CreateAccountForm> createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleCreateAccount(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
      final success = await auth.createAccount(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
      );

      if (!context.mounted) return;

      if (success) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          try {
            await EmailPinService().sendPin(user.uid, user.email!);
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PinVerifyScreen(uid: user.uid)),
            );
            return;
          } catch (e) {
            // If sending PIN fails, fall back to home but notify user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PIN send failed: $e')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreenV3()),
            );
            return;
          }
        } else {
          // Fallback if user not available yet
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreenV3()),
          );
          return;
        }
      }

      final err = auth.lastError ?? 'Failed to create account';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            'Create Account',
            textAlign: TextAlign.center,
            style: AppTheme.heading1(context),
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 8).height),
          Text(
            'Start your learning journey',
            textAlign: TextAlign.center,
            style: AppTheme.caption(context),
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 40).height),
          TextFormField(
            controller: _nameController,
            style: AppTheme.bodyText(context),
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: AppTheme.caption(context),
              hintText: 'Enter your full name',
              hintStyle: AppTheme.caption(context).copyWith(color: Colors.black38),
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 16).height),
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
          SizedBox(height: AppTheme.scaledSize(context, 0, 16).height),
          TextFormField(
            controller: _passwordController,
            style: AppTheme.bodyText(context),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: AppTheme.caption(context),
              hintText: 'Create a password',
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
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 16).height),
          TextFormField(
            controller: _confirmPasswordController,
            style: AppTheme.bodyText(context),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: AppTheme.caption(context),
              hintText: 'Confirm your password',
              hintStyle: AppTheme.caption(context).copyWith(color: Colors.black38),
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.withOpacityFixed(AppTheme.primary, 0.7),
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 16).height),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: AppTheme.bodyText(context),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: AppTheme.caption(context),
              hintText: 'e.g. +8801XXXXXXXXX',
              hintStyle: AppTheme.caption(context).copyWith(color: Colors.black38),
              prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 32).height),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _handleCreateAccount(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: AppTheme.scaledPadding(context, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(double.infinity, AppTheme.scaledSize(context, 0, 48).height),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Create Account',
                    style: AppTheme.bodyText(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          SizedBox(height: AppTheme.scaledSize(context, 0, 20).height),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTheme.caption(context),
                children: [
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  TextSpan(
                    text: "Log in",
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