import 'package:equatable/equatable.dart';
import '../domain/lesson_model.dart';

class LessonState extends Equatable {
  final bool loading;
  final String? error;
  final List<LessonModel> lessons;
  final LessonModel? selectedLesson;

  const LessonState({
    this.loading = false,
    this.error,
    this.lessons = const [],
    this.selectedLesson,
  });

  LessonState copyWith({
    bool? loading,
    String? error,
    List<LessonModel>? lessons,
    LessonModel? selectedLesson,
  }) {
    return LessonState(
      loading: loading ?? this.loading,
      error: error,
      lessons: lessons ?? this.lessons,
      selectedLesson: selectedLesson ?? this.selectedLesson,
    );
  }

  @override
  List<Object?> get props => [loading, error, lessons, selectedLesson];
}
