// lib/features/reviews/bloc/review_state.dart
import '../domain/review_model.dart';

class ReviewState {
  final bool loading;
  final bool submitting;
  final String? error;
  final List<ReviewModel> reviews;

  const ReviewState({
    this.loading = false,
    this.submitting = false,
    this.error,
    this.reviews = const [],
  });

  ReviewState copyWith({
    bool? loading,
    bool? submitting,
    String? error,
    List<ReviewModel>? reviews,
  }) {
    return ReviewState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      error: error,
      reviews: reviews ?? this.reviews,
    );
  }
}
