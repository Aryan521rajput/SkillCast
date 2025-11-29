import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillcast/features/courses/domain/course_model.dart';
import 'package:skillcast/features/lessons/domain/lesson_model.dart';
import 'package:skillcast/features/live/domain/live_class_model.dart';
import 'search_event.dart';
import 'search_state.dart';
import '../data/search_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repo;

  SearchBloc({required this.repo}) : super(const SearchState()) {
    on<SearchRequested>(_onSearchRequested);
  }

  Future<void> _onSearchRequested(
    SearchRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final results = await Future.wait([
        repo.searchCourses(event.query), // Expecting List<CourseModel>
        repo.searchLessons(event.query), // Expecting List<LessonModel>
        repo.searchLiveClasses(event.query), // Expecting List<LiveClassModel>
      ]);

      emit(
        state.copyWith(
          loading: false,
          courses: List<CourseModel>.from(results[0]),
          lessons: List<LessonModel>.from(results[1]),
          liveClasses: List<LiveClassModel>.from(results[2]),
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
