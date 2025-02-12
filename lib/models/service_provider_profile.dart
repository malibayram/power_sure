import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderProfile {
  final String userId;
  final String companyName;
  final String organizationId;
  final List<String> services;
  final Map<String, dynamic> capabilities;
  final bool isVerified;
  final String status; // active, suspended, pending
  final DateTime registeredAt;

  ServiceProviderProfile({
    required this.userId,
    required this.companyName,
    required this.organizationId,
    required this.services,
    required this.capabilities,
    required this.isVerified,
    required this.status,
    required this.registeredAt,
  });

  factory ServiceProviderProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceProviderProfile(
      userId: doc.id,
      companyName: data['companyName'],
      organizationId: data['organizationId'],
      services: List<String>.from(data['services'] ?? []),
      capabilities: data['capabilities'] ?? {},
      isVerified: data['isVerified'] ?? false,
      status: data['status'],
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'organizationId': organizationId,
      'services': services,
      'capabilities': capabilities,
      'isVerified': isVerified,
      'status': status,
      'registeredAt': Timestamp.fromDate(registeredAt),
    };
  }
}
