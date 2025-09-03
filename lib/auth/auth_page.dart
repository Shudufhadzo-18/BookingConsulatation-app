 import 'package:firebase_flutter/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'email_formfield.dart';
import 'password_formfield.dart';

class AuthPage extends StatefulWidget {
  final bool isLogin;
  final bool isAdmin;
  final bool isAdminRegister;

  const AuthPage({
    super.key,
    required this.isLogin,
    this.isAdmin = false,
    this.isAdminRegister = false,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _adminCodeController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (widget.isLogin) {
        if (widget.isAdmin) {
          const adminSecretCode = "admin123";
          if (_adminCodeController.text.trim() != adminSecretCode) {
            throw Exception("Invalid admin code");
          }

          await authService.login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            rememberMe: _rememberMe,
            isAdmin: true,
          );

          Navigator.pushReplacementNamed(context, RouteManager.adminDashboard);
        } else {
          await authService.login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            rememberMe: _rememberMe,
            isAdmin: false,
          );

          Navigator.pushReplacementNamed(
            context,
            RouteManager.mainPage,
            arguments: _emailController.text.trim(),
          );
        }
      } else {
        if (widget.isAdminRegister) {
          const adminSecretCode = "admin123";
          if (_adminCodeController.text.trim() != adminSecretCode) {
            throw Exception("Invalid admin code");
          }

     
          _showSuccessToast(context, 'Admin registered! Please login.');
          Navigator.pushReplacementNamed(context, RouteManager.adminLoginPage);
        } else {
          await authService.register(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
            _studentIdController.text.trim(),
            _contactController.text.trim(),
          );

          _showSuccessToast(context, 'Registration successful! Please login.');
          Navigator.pushReplacementNamed(context, RouteManager.loginPage);
        }
      }
    } catch (e) {
      _showErrorToast(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showErrorToast(context, 'Please enter a valid email address to reset password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.resetPassword(_emailController.text.trim());
      _showSuccessToast(context, 'Password reset link sent to your email');
    } catch (e) {
      _showErrorToast(context, 'Failed to send reset email: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = !widget.isLogin;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin
            ? (widget.isAdminRegister ? 'Admin Registration' : 'Admin Login')
            : widget.isLogin
                ? 'Login'
                : 'Register'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isRegister && !widget.isAdmin) ...[
                  _buildInputField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) => value!.isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _studentIdController,
                    label: 'Student ID',
                    icon: Icons.badge,
                    validator: (value) => value!.isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _contactController,
                    label: 'Contact Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                EmailFormField(controller: _emailController),
                const SizedBox(height: 16),
                PasswordFormField(controller: _passwordController),
                const SizedBox(height: 16),
                if (widget.isAdmin && (widget.isLogin || widget.isAdminRegister)) ...[
                  _buildInputField(
                    controller: _adminCodeController,
                    label: widget.isLogin ? 'Admin Code' : 'Admin Registration Code',
                    icon: Icons.security,
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                if (widget.isLogin && !widget.isAdmin) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) => setState(() => _rememberMe = value!),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      const Text('Remember me'),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading ? null : () => _resetPassword(context),
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          widget.isAdmin
                              ? (widget.isAdminRegister ? 'Register as Admin' : 'Login as Admin')
                              : widget.isLogin
                                  ? 'Login'
                                  : 'Register',
                        ),
                ),
                const SizedBox(height: 16),
                if (!widget.isAdmin) ...[
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushReplacementNamed(
                              context,
                              widget.isLogin
                                  ? RouteManager.registrationPage
                                  : RouteManager.loginPage,
                            ),
                    child: Text(
                      widget.isLogin
                          ? 'Don\'t have an account? Register'
                          : 'Already have an account? Login',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushReplacementNamed(
                              context,
                              RouteManager.adminLoginPage,
                            ),
                    child: const Text(
                      'Admin Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ] else ...[
                  if (widget.isAdminRegister) ...[
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                                context,
                                RouteManager.loginPage,
                              ),
                      child: const Text('Admin Login'),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                                context,
                                RouteManager.adminRegisterPage,
                              ),
                      child: const Text(
                        'Register as Admin',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushReplacementNamed(
                              context,
                              RouteManager.loginPage,
                            ),
                    child: const Text('Regular User Login'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _studentIdController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }
}