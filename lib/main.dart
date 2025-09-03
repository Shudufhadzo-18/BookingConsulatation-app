import 'package:firebase_flutter/routes/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'viewmodels/consultation_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBB9-ke6UBzeybiGYo9wBRW00oIbRoZ5Sw",
        authDomain: "fir-flutter-32e60.firebaseapp.com",
        projectId: "fir-flutter-32e60",
        storageBucket: "fir-flutter-32e60.appspot.com",
        messagingSenderId: "970809795460",
        appId: "1:970809795460:web:8eca52a4f3d8384bdd73d1",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConsultationViewModel()),
     
        ChangeNotifierProvider(create: (_) => AuthService()),
   
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: RouteManager.loginPage,
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
}