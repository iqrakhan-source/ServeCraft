import 'package:flutter/material.dart';
import 'login_screen.dart';

export 'login_screen.dart';

/// Legacy mobile login wrapper retained for backward compatibility.
/// Redirects directly to the new CRM-style Email + Password LoginScreen.
class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
