import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER USER (unchanged)
  Future<User?> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user != null) {
      final appUser = AppUser(
        uid: user.uid,
        email: email,
        name: fullName,
        role: 'Student',
        enrolledCourses: const [],
      );

      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
    }

    return user;
  }

  // -----------------------------------------------------------
  // 🔥 FIXED LOGIN — Proper FirebaseAuthException handling
  // -----------------------------------------------------------
  Future<User?> login({required String email, required String password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // This message goes directly into AuthBloc -> SnackBar
      switch (e.code) {
        case 'user-not-found':
          throw Exception("No user found with this email");
        case 'wrong-password':
          throw Exception("Invalid password");
        case 'invalid-email':
          throw Exception("Invalid email format");
        case 'user-disabled':
          throw Exception("This account has been disabled");
        default:
          throw Exception("Invalid credentials");
      }
    } catch (_) {
      throw Exception("Login failed, please try again.");
    }
  }

  // FETCH PROFILE (unchanged)
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        final fallback = AppUser(
          uid: uid,
          email: _auth.currentUser?.email ?? "",
          name: "New User",
          role: "Student",
          enrolledCourses: const [],
        );

        await _firestore.collection('users').doc(uid).set(fallback.toMap());
        return fallback;
      }

      return AppUser.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  // -----------------------------------------------------------
  // 🔥 FIXED LOGOUT — instant, smooth, no delays
  // -----------------------------------------------------------
  Future<void> logout() async {
    await _auth.signOut(); // fast enough, do not add anything
  }

  // CURRENT USER (unchanged)
  User? get currentUser => _auth.currentUser;

  // PASSWORD RESET (unchanged)
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
