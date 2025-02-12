import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequest {
  final String id;
  final String customerId;
  final String description;
  final String status; // pending, matched, in_progress, completed
  final List<String>? assignedProviders;
  final DateTime createdAt;
  final Map<String, dynamic> requirements;
  final String location;
  final double budget;
  final String projectSize; // small, medium, large
  final DateTime preferredDate;
  final List<String> serviceTypes; // installation, maintenance, etc.

  ServiceRequest({
    required this.id,
    required this.customerId,
    required this.description,
    required this.status,
    this.assignedProviders,
    required this.createdAt,
    required this.requirements,
    required this.location,
    required this.budget,
    required this.projectSize,
    required this.preferredDate,
    required this.serviceTypes,
  });

  factory ServiceRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceRequest(
      id: doc.id,
      customerId: data['customerId'],
      description: data['description'],
      status: data['status'],
      assignedProviders: List<String>.from(data['assignedProviders'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      requirements: data['requirements'] ?? {},
      location: data['location'],
      budget: data['budget'],
      projectSize: data['projectSize'],
      preferredDate: (data['preferredDate'] as Timestamp).toDate(),
      serviceTypes: List<String>.from(data['serviceTypes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'description': description,
      'status': status,
      'assignedProviders': assignedProviders,
      'createdAt': Timestamp.fromDate(createdAt),
      'requirements': requirements,
      'location': location,
      'budget': budget,
      'projectSize': projectSize,
      'preferredDate': Timestamp.fromDate(preferredDate),
      'serviceTypes': serviceTypes,
    };
  }
}
