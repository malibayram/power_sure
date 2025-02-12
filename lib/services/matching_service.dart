import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/employee_profile.dart';
import '../models/service_request.dart';

class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<EmployeeProfile>> findMatchingEmployees(
      ServiceRequest request) async {
    // Talebe uygun çalışanları bul
    final employeesQuery = await _firestore
        .collection('employee_profiles')
        .where('specializations', arrayContainsAny: request.serviceTypes)
        .where('status', isEqualTo: 'available')
        .where('location', isEqualTo: request.location)
        .get();

    return employeesQuery.docs
        .map((doc) => EmployeeProfile.fromFirestore(doc))
        .toList();
  }

  Future<void> createMatch(
      ServiceRequest request, List<String> employeeIds) async {
    // Eşleştirme oluştur
    await _firestore.collection('matches').add({
      'requestId': request.id,
      'employeeIds': employeeIds,
      'status': 'pending_approval',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Talebin durumunu güncelle
    await _firestore
        .collection('service_requests')
        .doc(request.id)
        .update({'status': 'matched', 'assignedProviders': employeeIds});
  }
}
