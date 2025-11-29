import 'package:cloud_firestore/cloud_firestore.dart';
import '../../reviews/domain/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitReview(ReviewModel review) async {
    print("📌 Writing review to Firestore with ID ${review.id}");
    await _db.collection("reviews").doc(review.id).set(review.toMap());
  }

  Stream<List<ReviewModel>> getReviews(String courseId) {
    print("📡 getReviews CALLED for courseId=$courseId");

    return _db
        .collection("reviews")
        .where("courseId", isEqualTo: courseId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) {
          print("📥 Firestore snapshot docs = ${snap.docs.length}");

          return snap.docs.map((doc) {
            print("📄 Reading review doc ${doc.id}");
            return ReviewModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  Future<void> deleteReview(String reviewId) async {
    print("🗑️ Deleting review $reviewId");
    await _db.collection("reviews").doc(reviewId).delete();
  }

  Future<void> editReview(
    String reviewId,
    double rating,
    String comment,
  ) async {
    print("✏️ Editing review $reviewId");
    await _db.collection("reviews").doc(reviewId).update({
      "rating": rating,
      "comment": comment,
      "createdAt": Timestamp.now(),
    });
  }
}
