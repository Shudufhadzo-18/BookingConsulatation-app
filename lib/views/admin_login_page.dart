import 'package:flutter/material.dart';
import 'package:firebase_flutter/auth/auth_page.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPage(
      isLogin: true,
      isAdmin: true,
    );
  }
}