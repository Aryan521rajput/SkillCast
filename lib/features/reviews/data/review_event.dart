// lib/features/reviews/bloc/review_event.dart
import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadReviewsRequested extends ReviewEvent {
  final String courseId;
  LoadReviewsRequested(this.courseId);
  @override
  List<Object?> get props => [courseId];
}

class SubmitReviewRequested extends ReviewEvent {
  final String courseId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;

  SubmitReviewRequested({
    required this.courseId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [courseId, userId, userName, rating, comment];
}

class DeleteReviewRequested extends ReviewEvent {
  final String reviewId;
  final String courseId;

  DeleteReviewRequested({required this.reviewId, required this.courseId});

  @override
  List<Object?> get props => [reviewId, courseId];
}

class EditReviewRequested extends ReviewEvent {
  final String reviewId;
  final String courseId;
  final double rating;
  final String comment;

  EditReviewRequested({
    required this.reviewId,
    required this.courseId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [reviewId, courseId, rating, comment];
}
