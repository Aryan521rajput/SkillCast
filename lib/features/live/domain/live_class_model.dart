import 'package:cloud_firestore/cloud_firestore.dart';

class LiveClassModel {
  final String id;
  final String title;
  final String description;
  final String instructorName;
  final DateTime? scheduledAt; // was "date"
  final DateTime? createdAt;

  LiveClassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorName,
    this.scheduledAt,
    this.createdAt,
  });

  factory LiveClassModel.fromMap(String id, Map<String, dynamic> map) {
    return LiveClassModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructorName: map['instructorId'] ?? '', // your DB uses "instructorId"
      scheduledAt: map['scheduledAt'] is Timestamp
          ? (map['scheduledAt'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'instructorId': instructorName,
      'scheduledAt': scheduledAt,
      'createdAt': createdAt,
    };
  }
}
