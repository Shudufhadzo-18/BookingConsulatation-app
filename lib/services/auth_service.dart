import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  

  // Modified register method to store in 'students' collection
  Future<User?> register(String email, String password, String name, String studentId, String contactNumber) async {
    try {
      // 1. Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Create student document in 'students' collection
      await _firestore.collection('students').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'studentId': studentId,
        'contactNumber': contactNumber,
        'createdAt': DateTime.now(),
        'uid': userCredential.user!.uid, // Store the auth UID for reference
      });

        // Save additional admin data to Firestore
    
  
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  // Rest of your existing methods remain the same...
  Future<User?> login(String email, String password, {required bool rememberMe, required bool isAdmin}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

Future<void> loginAdmin(
  String email,
  String password, {
  bool rememberMe = false,
  bool isAdmin = false,
}) async {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Fetch user profile from Firestore
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(credential.user!.uid)
      .get();

  final data = doc.data();

  if (isAdmin) {
    if (data == null || data['isAdmin'] != true) {
      throw Exception('Not an admin account');
    }
  }
}

  String _authError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid CUT email address';
      case 'weak-password':
        return 'Password must be 8+ chars with @ symbol';
      default:
        return 'Authentication failed';
    }
  }

  Future<AppUser?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Your module-related methods...
  // CollectionReference get _modulesCollection => _firestore.collection('modules');

  // Future<void> addModule(String name, String code) async {
  //   if (currentUser == null) throw Exception('User not authenticated');
    
  //   await _modulesCollection.add({
  //     'name': name,
  //     'code': code,
  //     'studentId': currentUser!.uid,
  //     'createdAt': DateTime.now(),
  //   });
  //   notifyListeners();
  // }

  // Future<void> updateModule(String moduleId, String name, String code) async {
  //   await _modulesCollection.doc(moduleId).update({
  //     'name': name,
  //     'code': code,
  //   });
  //   notifyListeners();
  // }

  // Future<void> deleteModule(String moduleId) async {
  //   await _modulesCollection.doc(moduleId).delete();
  //   notifyListeners();
  // }

  // Stream<List<Module>> getModules() {
  //   if (currentUser == null) throw Exception('User not authenticated');
  //   return _modulesCollection
  //     .where('studentId', isEqualTo: currentUser!.uid)
  //     .orderBy('createdAt', descending: true)
  //     .snapshots()
  //     .map((snapshot) => 
  //       snapshot.docs.map((doc) => Module.fromFirestore(doc)).toList());
  // }

  resetPassword(String trim) {}

  logout() {}

Future<void> registerAdmin(String email, String password, String name ) async {
  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
    
  );




    // Store extra data in Firestore
  await FirebaseFirestore.instance.collection('admins').doc(credential.user!.uid).set({
      'email': email,
      'admin code': name,
      'createdAt': FieldValue.serverTimestamp(),
      'isAdmin': true,
      'adminSince': FieldValue.serverTimestamp(),
  });
}}