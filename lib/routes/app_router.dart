import 'package:firebase_flutter/auth/auth_page.dart';
import 'package:firebase_flutter/views/add_consultation_screen.dart';
import 'package:firebase_flutter/views/admin_dashboard.dart';
import 'package:firebase_flutter/views/admin_login_page.dart';
import 'package:firebase_flutter/views/admin_register_page.dart';
import 'package:firebase_flutter/views/consultation_details_screen.dart';
import 'package:firebase_flutter/views/edit_consultation_screen.dart';
import 'package:firebase_flutter/views/home_page.dart';
import 'package:firebase_flutter/views/profile_page_screen.dart';
import 'package:flutter/material.dart';

class RouteManager {
  static const String loginPage = '/';
  static const String registrationPage = '/register';
  static const String mainPage = '/main';

  static const String home = '/home';
  static const String profile = '/profile';
  static const String consultationDetails = '/consultationDetails';
  static const String addConsultation = '/addConsultation';
    static const String adminLoginPage = '/adminLogin';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminRegisterPage = '/admin-register';
  static const String editConsultationPage='editConsultation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginPage:
        return MaterialPageRoute(builder: (_) => const AuthPage(isLogin: true));
      case registrationPage:
        return MaterialPageRoute(
          builder: (_) => const AuthPage(isLogin: false),
        );

      case home:
        return MaterialPageRoute(builder: (_) => const AuthPage(isLogin: true));
      
      case profile:
        return MaterialPageRoute(builder: (context) => ProfilePage());
      case consultationDetails:
        final consultation = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (context) =>
                  ConsultationDetailsScreen(consultation: consultation),
        );
        case adminLoginPage:
        return MaterialPageRoute(builder: (context) => AdminLoginPage());
            case adminDashboard:
        return MaterialPageRoute(builder: (context) => AdminDashboard());
                  case adminRegisterPage:
        return MaterialPageRoute(builder: (context) => AdminRegisterPage());

           case editConsultationPage:
            final consultation = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => EditConsultationScreen(consultation: consultation,));


      case addConsultation:
        return MaterialPageRoute(builder: (context) => AddConsultationPage());
      case mainPage:
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => MainPage(email: email));
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('No route for ${settings.name}')),
              ),
        );
    }
  }
}
