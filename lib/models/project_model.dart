import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String name;
  final String location;
  final String description;
  final String createdBy;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
