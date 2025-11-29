import 'package:equatable/equatable.dart';

abstract class LessonEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLessonsRequested extends LessonEvent {
  final String courseId;
  LoadLessonsRequested(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class LoadLessonDetailRequested extends LessonEvent {
  final String lessonId;
  LoadLessonDetailRequested(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}
