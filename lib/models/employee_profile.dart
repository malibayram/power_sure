import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeProfile {
  final String userId;
  final String name;
  final String organizationId;
  final String role; // technician, supervisor, etc.
  final List<String> specializations;
  final Map<String, dynamic> skills;
  final String status; // available, busy, on_leave
  final List<String> certifications;
  final String location;
  final Map<String, dynamic> schedule;
  final bool isVerified;

  EmployeeProfile({
    required this.userId,
    required this.name,
    required this.organizationId,
    required this.role,
    required this.specializations,
    required this.skills,
    required this.status,
    required this.certifications,
    required this.location,
    required this.schedule,
    required this.isVerified,
  });

  factory EmployeeProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmployeeProfile(
      userId: doc.id,
      name: data['name'],
      organizationId: data['organizationId'],
      role: data['role'],
      specializations: List<String>.from(data['specializations'] ?? []),
      skills: data['skills'] ?? {},
      status: data['status'],
      certifications: List<String>.from(data['certifications'] ?? []),
      location: data['location'],
      schedule: data['schedule'] ?? {},
      isVerified: data['isVerified'] ?? false,
    );
  }

  // ... fromFirestore and toMap methods ...
}
