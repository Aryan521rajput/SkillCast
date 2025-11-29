// lib/bloc/course_event.dart
import 'package:equatable/equatable.dart';
import 'package:skillcast/features/courses/domain/course_model.dart';

abstract class CourseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCoursesRequested extends CourseEvent {}

class LoadCourseDetailRequested extends CourseEvent {
  final String courseId;
  LoadCourseDetailRequested(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class EnrollCourseRequested extends CourseEvent {
  final String courseId;
  EnrollCourseRequested(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class CreateCourseRequested extends CourseEvent {
  final CourseModel course;
  CreateCourseRequested(this.course);

  @override
  List<Object?> get props => [course];
}

class LoadSingleCourseRequested extends CourseEvent {
  final String courseId;
  LoadSingleCourseRequested(this.courseId);

  @override
  List<Object?> get props => [courseId];
}
