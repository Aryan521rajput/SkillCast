import 'package:flutter_bloc/flutter_bloc.dart';
import '../../reviews/domain/review_model.dart';
import '../data/review_repository.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repo;

  ReviewBloc({required this.repo}) : super(const ReviewState()) {
    on<LoadReviewsRequested>(_onLoadReviews);
    on<SubmitReviewRequested>(_onSubmitReview);
    on<DeleteReviewRequested>(_onDeleteReview);
    on<EditReviewRequested>(_onEditReview);
  }

  Future<void> _onLoadReviews(
    LoadReviewsRequested event,
    Emitter<ReviewState> emit,
  ) async {
    print("🔥 Loading reviews for courseId = ${event.courseId}");

    emit(state.copyWith(loading: true));

    await emit.forEach<List<ReviewModel>>(
      repo.getReviews(event.courseId),
      onData: (reviews) {
        print("📥 Firestore returned ${reviews.length} reviews");
        for (var r in reviews) {
          print(
            "➡️ Review: ${r.id} | courseId=${r.courseId} | rating=${r.rating}",
          );
        }
        return state.copyWith(loading: false, reviews: reviews);
      },
      onError: (e, _) {
        print("❌ Firestore error loading reviews: $e");
        return state.copyWith(loading: false, error: "Failed to load reviews");
      },
    );
  }

  Future<void> _onSubmitReview(
    SubmitReviewRequested event,
    Emitter<ReviewState> emit,
  ) async {
    print("📝 SUBMIT review for courseId = ${event.courseId}");

    emit(state.copyWith(submitting: true));

    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseId: event.courseId,
      userId: event.userId,
      userName: event.userName,
      rating: event.rating,
      comment: event.comment,
      createdAt: DateTime.now(),
    );

    print("📤 Sending review to Firestore: ${review.toMap()}");

    await repo.submitReview(review);

    emit(state.copyWith(submitting: false));
  }

  Future<void> _onDeleteReview(
    DeleteReviewRequested event,
    Emitter<ReviewState> emit,
  ) async {
    print("🗑️ DELETE review ${event.reviewId}");
    await repo.deleteReview(event.reviewId);
  }

  Future<void> _onEditReview(
    EditReviewRequested event,
    Emitter<ReviewState> emit,
  ) async {
    print("✏️ EDIT review ${event.reviewId}");
    await repo.editReview(event.reviewId, event.rating, event.comment);
  }
}
