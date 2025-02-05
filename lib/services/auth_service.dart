import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      return UserModel.fromMap({
        'id': userCredential.user!.uid,
        ...userDoc.data()!,
      });
    } catch (e) {
      print('Giriş hatası: $e');
      return null;
    }
  }

  Future<UserModel?> register(
      String email, String password, String role) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
      });

      return UserModel(
        id: userCredential.user!.uid,
        email: email,
        role: role,
      );
    } catch (e) {
      print('Kayıt hatası: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
