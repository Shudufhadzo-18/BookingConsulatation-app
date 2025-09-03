import 'package:flutter/material.dart';

class PasswordFormField extends StatelessWidget {
  final TextEditingController controller;
  const PasswordFormField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 8) return 'Minimum 8 characters';
        if (!value.contains('@')) return 'Must contain @ symbol';
        return null;
      },
    );
  }
}