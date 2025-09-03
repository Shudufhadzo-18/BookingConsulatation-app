import 'package:flutter/material.dart';

class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  const EmailFormField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'CUT Email',
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email is required';
        if (!value.endsWith('@cut.ac.za')) return 'Only CUT emails allowed';
        return null;
      },
    );
  }
}