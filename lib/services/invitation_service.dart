import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendInvitation({
    required String email,
    required String organizationId,
    required String role,
    String? department,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final invitationData = {
      'email': email,
      'organizationId': organizationId,
      'role': role,
      'department': department,
      'status': 'pending',
      'invitedBy': currentUser.uid,
      'invitedAt': FieldValue.serverTimestamp(),
      'invitationCode': _generateInvitationCode(),
    };

    await _firestore.collection('invitations').add(invitationData);
  }

  String _generateInvitationCode() {
    // Generate a unique 6-character code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final code = List.generate(6, (index) {
      final i = (random.hashCode + index) % chars.length;
      return chars[i];
    }).join();
    return code;
  }

  Future<Map<String, dynamic>?> validateInvitation(String code) async {
    final querySnapshot = await _firestore
        .collection('invitations')
        .where('invitationCode', isEqualTo: code)
        .where('status', isEqualTo: 'pending')
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.data();
  }
}
