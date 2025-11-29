// lib/bloc/course_state.dart
import 'package:equatable/equatable.dart';
import 'package:skillcast/features/courses/domain/course_model.dart';

class CourseState extends Equatable {
  final bool loading;
  final String? error;
  final List<CourseModel> courses;
  final CourseModel? selectedCourse;

  const CourseState({
    this.loading = false,
    this.error,
    this.courses = const [],
    this.selectedCourse,
  });

  CourseState copyWith({
    bool? loading,
    String? error,
    List<CourseModel>? courses,
    CourseModel? selectedCourse,
  }) {
    return CourseState(
      loading: loading ?? this.loading,
      error: error,
      courses: courses ?? this.courses,
      selectedCourse: selectedCourse ?? this.selectedCourse,
    );
  }

  @override
  List<Object?> get props => [loading, error, courses, selectedCourse];
}
