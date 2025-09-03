import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User data
  String? name;
  String? role;
  String? phoneNumber;
  String? email;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // Mode state
  bool _isEditMode = false;
  bool _isLoading = true;
  
  // Firestore reference
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final User? user = _auth.currentUser;
      
      if (user != null) {
        // Set email from auth
        email = user.email;
        
        // Try to get additional data from Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (doc.exists) {
          setState(() {
            name = doc.data()?['name'] ?? user.displayName ?? 'No name';
            role = doc.data()?['role'] ?? 'No role specified';
            phoneNumber = doc.data()?['phoneNumber'] ?? 'No phone number';
            
            // Initialize controllers
            _nameController.text = name!;
            _roleController.text = role!;
            _phoneController.text = phoneNumber!;
          });
        } else {
          // If no Firestore doc exists, use basic auth data
          setState(() {
            name = user.displayName ?? 'No name';
            role = 'No role specified';
            phoneNumber = 'No phone number';
            
            _nameController.text = name!;
            _roleController.text = role!;
            _phoneController.text = phoneNumber!;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final User? user = _auth.currentUser;
      
      if (user != null) {
        // Update in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'role': _roleController.text,
          'phoneNumber': _phoneController.text,
          'email': user.email,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // Update local state
        setState(() {
          name = _nameController.text;
          role = _roleController.text;
          phoneNumber = _phoneController.text;
          _isEditMode = false;
        });
        
        // Here you would also upload the profile image to Firebase Storage if needed
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/login', 
      (route) => false,
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _isEditMode ? _pickImage : null,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage: _profileImage != null 
            ? FileImage(_profileImage!) 
            : null,
        child: _profileImage == null
            ? const Icon(Icons.person, size: 60, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildInfoField(String label, String? value, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          _isEditMode
              ? TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  child: Text(
                    value ?? 'Not specified',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image Section
            Stack(
              children: [
                _buildProfileImage(),
                if (_isEditMode)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // User Info Section
            _buildInfoField('Full Name', name, _nameController),
            _buildInfoField('Role/Title', role, _roleController),
            _buildInfoField('Email', email, TextEditingController(text: email)),
            _buildInfoField('Phone Number', phoneNumber, _phoneController),
            
            const SizedBox(height: 30),
            
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isEditMode ? _saveProfile : () => setState(() => _isEditMode = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isEditMode ? 'SAVE CHANGES' : 'EDIT PROFILE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            if (_isEditMode) const SizedBox(height: 15),
            
            if (_isEditMode)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Reset to original values
                    _nameController.text = name!;
                    _roleController.text = role!;
                    _phoneController.text = phoneNumber!;
                    setState(() {
                      _profileImage = null;
                      _isEditMode = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}