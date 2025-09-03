import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConsultationViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Map<String, dynamic>> consultations = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get consultation => consultations;
  bool get isLoading => _isLoading;

  Stream<List<Map<String, dynamic>>> getConsultationsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('consultations')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'title': data['title'] ?? '',
                'description': data['description'] ?? '',
                'dateTime': (data['dateTime'] as Timestamp).toDate(),
                'location': data['location'] ?? '',
              };
            }).toList());
  }


Future<Map<String, dynamic>?> getStudentData(String userId) async {
  try {
    final doc = await _firestore.collection('students').doc(userId).get();
    return doc.data();
  } catch (e) {
    print('Error fetching student data: $e');
    return null;
  }
}
  Future<void> fetchConsultations() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('consultations')
          .where('userId', isEqualTo: userId)
          .orderBy('dateTime', descending: false)
          .get();

      consultations = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'dateTime': (data['dateTime'] as Timestamp).toDate(),
          'location': data['location'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching consultations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addConsultation(Map<String, dynamic> consultation) async {
    try {
             consultations.add(consultation);
    notifyListeners();
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('consultations').add({
        ...consultation,
        'userId': userId,
        
        'createdAt': FieldValue.serverTimestamp(),

   
      });
    } catch (e) {
      print('Error adding consultation: $e');
      rethrow;
    }
  }
Future<void> removeConsultation(String id) async {
  try {
    _isLoading = true;
    notifyListeners();
    
    await _firestore.collection('consultations').doc(id).delete();
    
    // Remove from local list
    consultations.removeWhere((consultation) => consultation['id'] == id);
  } catch (e) {
    print('Error removing consultation: $e');
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<void> updateConsultation(
  String id,
  String title,
  String description,
  String location,
  DateTime dateTime,
) async {
  try {
    // Add null checks or default values if needed
    await _firestore.collection('consultations').doc(id).update({
      'title': title,
      'description': description,
      'location': location,
      'dateTime': dateTime,
      'updatedAt': DateTime.now(),
    });
  } catch (e) {
    rethrow;
  }
}}

