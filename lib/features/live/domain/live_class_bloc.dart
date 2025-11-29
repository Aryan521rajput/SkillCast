import 'package:flutter_bloc/flutter_bloc.dart';
import 'live_class_event.dart';
import 'live_class_state.dart';
import '../data/live_class_repository.dart';

class LiveClassBloc extends Bloc<LiveClassEvent, LiveClassState> {
  final LiveClassRepository repo;

  LiveClassBloc({required this.repo}) : super(const LiveClassState()) {
    on<LoadLiveClassesRequested>(_onLoadAll);
    on<LoadLiveClassDetailRequested>(_onLoadDetail);
  }

  Future<void> _onLoadAll(
    LoadLiveClassesRequested event,
    Emitter<LiveClassState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final stream = repo.getLiveClasses();

      await emit.forEach(
        stream,
        onData: (classes) => state.copyWith(loading: false, classes: classes),
        onError: (error, _) =>
            state.copyWith(loading: false, error: error.toString()),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadDetail(
    LoadLiveClassDetailRequested event,
    Emitter<LiveClassState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final live = await repo.getLiveClass(event.liveClassId);

      emit(state.copyWith(loading: false, selectedClass: live));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
