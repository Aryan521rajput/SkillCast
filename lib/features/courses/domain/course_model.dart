import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? instructorName;
  final DateTime createdAt;
  final bool published;
  final String? videoUrl; // optional video url

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.instructorName,
    this.published = true,
    this.videoUrl,
  });

  factory CourseModel.fromMap(String id, Map<String, dynamic> map) {
    // createdAt in Firestore might be a Timestamp OR a String depending on how it was saved
    DateTime created;
    final raw = map['createdAt'];
    if (raw == null) {
      created = DateTime.now();
    } else if (raw is Timestamp) {
      created = raw.toDate();
    } else if (raw is DateTime) {
      created = raw;
    } else {
      // assume string
      created = DateTime.tryParse(raw.toString()) ?? DateTime.now();
    }

    return CourseModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructorName: map['instructorName'] ?? 'Unknown',
      createdAt: created,
      published: map['published'] ?? true,
      videoUrl: map['videoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'instructorName': instructorName,
      // store as a Firestore Timestamp
      'createdAt': Timestamp.fromDate(createdAt),
      'published': published,
      if (videoUrl != null) 'videoUrl': videoUrl,
    };
  }
}
