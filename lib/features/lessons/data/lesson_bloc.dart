import 'package:flutter_bloc/flutter_bloc.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';
import 'lesson_repository.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final LessonRepository repo;

  LessonBloc({required this.repo}) : super(const LessonState()) {
    on<LoadLessonsRequested>(_onLoadLessons);
    on<LoadLessonDetailRequested>(_onLoadLessonDetail);
  }

  // LOAD ALL LESSONS OF A COURSE
  Future<void> _onLoadLessons(
    LoadLessonsRequested event,
    Emitter<LessonState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final stream = repo.getLessons(event.courseId);

      await emit.forEach(
        stream,
        onData: (lessons) => state.copyWith(loading: false, lessons: lessons),
        onError: (error, _) =>
            state.copyWith(loading: false, error: error.toString()),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  // LOAD SPECIFIC LESSON DETAIL
  Future<void> _onLoadLessonDetail(
    LoadLessonDetailRequested event,
    Emitter<LessonState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    try {
      final lesson = await repo.getLesson(event.lessonId);
      emit(state.copyWith(loading: false, selectedLesson: lesson));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
