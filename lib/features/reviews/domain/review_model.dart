import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String courseId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    final rawCreatedAt = map['createdAt'];

    Timestamp ts;

    if (rawCreatedAt is Timestamp) {
      ts = rawCreatedAt;
    } else if (rawCreatedAt is String) {
      // attempt parse string
      ts = Timestamp.fromDate(
        DateTime.tryParse(rawCreatedAt) ?? DateTime.now(),
      );
    } else {
      ts = Timestamp.now();
    }

    final rawRating = map['rating'];

    double rating = 0;
    if (rawRating is int) rating = rawRating.toDouble();
    if (rawRating is double) rating = rawRating;
    if (rawRating is String) rating = double.tryParse(rawRating) ?? 0;

    return ReviewModel(
      id: id,
      courseId: map['courseId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      rating: rating,
      comment: map['comment'] ?? '',
      createdAt: ts.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
