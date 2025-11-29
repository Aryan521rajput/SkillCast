class EnrollmentModel {
  final String id;
  final String userId;
  final String courseId;

  EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
  });

  factory EnrollmentModel.fromMap(String id, Map<String, dynamic> map) {
    return EnrollmentModel(
      id: id,
      userId: map['userId'],
      courseId: map['courseId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'courseId': courseId};
  }
}
