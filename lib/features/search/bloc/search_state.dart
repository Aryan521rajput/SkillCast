import 'package:equatable/equatable.dart';
import '../../courses/domain/course_model.dart';
import '../../lessons/domain/lesson_model.dart';
import '../../live/domain/live_class_model.dart';

class SearchState extends Equatable {
  final bool loading;
  final String? error;
  final List<CourseModel> courses;
  final List<LessonModel> lessons;
  final List<LiveClassModel> liveClasses;

  const SearchState({
    this.loading = false,
    this.error,
    this.courses = const [],
    this.lessons = const [],
    this.liveClasses = const [],
  });

  SearchState copyWith({
    bool? loading,
    String? error,
    List<CourseModel>? courses,
    List<LessonModel>? lessons,
    List<LiveClassModel>? liveClasses,
  }) {
    return SearchState(
      loading: loading ?? this.loading,
      error: error,
      courses: courses ?? this.courses,
      lessons: lessons ?? this.lessons,
      liveClasses: liveClasses ?? this.liveClasses,
    );
  }

  @override
  List<Object?> get props => [loading, error, courses, lessons, liveClasses];
}
