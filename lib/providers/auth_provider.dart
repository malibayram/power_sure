import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _userRole;
  bool get isAuthenticated => _user != null;

  User? get user => _user;
  String? get userRole => _userRole;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserRole();
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserRole() async {
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      _userRole = doc.data()?['role'];
      notifyListeners();
    } catch (e) {
      print('Rol yüklenirken hata: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signUp(String email, String password, String role) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
