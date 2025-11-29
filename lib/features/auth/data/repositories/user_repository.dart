import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    // 🔥 FIX: if user doesn't exist, create fallback instead of returning null
    if (!doc.exists || doc.data() == null) {
      final fallback = AppUser(
        uid: uid,
        email: "",
        name: "User",
        role: "Student",
        enrolledCourses: const [],
      );

      await createUser(fallback);
      return fallback;
    }

    final data = doc.data()!;
    final normalized = {
      ...data,
      'createdAt': data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : data['createdAt'],
    };

    return AppUser.fromMap(normalized);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> createUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Stream<AppUser?> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      final normalized = {
        ...data,
        'createdAt': data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
            : data['createdAt'],
      };

      return AppUser.fromMap(normalized);
    });
  }
}
