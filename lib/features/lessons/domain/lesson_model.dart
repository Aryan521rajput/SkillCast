import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String id;
  final String title;
  final String content;
  final String? videoUrl;
  final DateTime? createdAt;

  LessonModel({
    required this.id,
    required this.title,
    required this.content,
    this.videoUrl,
    this.createdAt,
  });

  factory LessonModel.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['createdAt'];

    return LessonModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      videoUrl: map['videoUrl'],
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
