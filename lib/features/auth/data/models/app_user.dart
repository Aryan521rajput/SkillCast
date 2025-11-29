import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;

  final String role;
  final String? photoUrl;
  final String? bio;
  final List<String> enrolledCourses;

  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.role = "Student",
    this.photoUrl,
    this.bio,
    this.enrolledCourses = const [],
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final created = map['createdAt'];

    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'Student',
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      enrolledCourses: List<String>.from(map['enrolledCourses'] ?? []),
      createdAt: created is Timestamp
          ? created.toDate()
          : DateTime.tryParse(created ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'bio': bio,
      'enrolledCourses': enrolledCourses,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
