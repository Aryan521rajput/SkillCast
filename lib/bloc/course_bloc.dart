import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillcast/features/courses/domain/course_model.dart';
import 'package:skillcast/bloc/auth_bloc.dart';
import '../features/auth/data/repositories/course_repository.dart';
import 'course_event.dart';
import 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository repo;
  final AuthBloc authBloc;

  CourseBloc({required this.repo, required this.authBloc})
    : super(const CourseState()) {
    on<LoadCoursesRequested>(_onLoadCourses);
    on<LoadCourseDetailRequested>(_onLoadCourseDetail);
    on<EnrollCourseRequested>(_onEnrollCourse);
    on<CreateCourseRequested>(_onCreateCourse);
  }

  Future<void> _onLoadCourses(
    LoadCoursesRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final stream = repo.getAllCourses();

      await emit.forEach<List<CourseModel>>(
        stream,
        onData: (courses) => state.copyWith(loading: false, courses: courses),
        onError: (err, _) =>
            state.copyWith(loading: false, error: err.toString()),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadCourseDetail(
    LoadCourseDetailRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    try {
      final course = await repo.getCourse(event.courseId);
      emit(state.copyWith(loading: false, selectedCourse: course));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onEnrollCourse(
    EnrollCourseRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      final userId = authBloc.state.userId;

      if (userId == null) {
        emit(state.copyWith(error: "User not logged in"));
        return;
      }

      await repo.enrollUser(event.courseId, userId);
      emit(state.copyWith(error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCreateCourse(
    CreateCourseRequested event,
    Emitter<CourseState> emit,
  ) async {
    try {
      await repo.createCourse(event.course);
      emit(state.copyWith(error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
