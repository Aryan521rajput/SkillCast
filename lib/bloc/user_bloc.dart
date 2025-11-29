import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillcast/features/auth/data/models/app_user.dart';
import 'package:skillcast/features/auth/data/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repo;

  UserBloc({required this.repo}) : super(const UserState()) {
    on<LoadUserRequested>(_onLoadUser);
    on<WatchUserRequested>(_onWatchUser);
    on<UpdateUserRequested>(_onUpdateUser);
  }

  // GET USER ONCE
  Future<void> _onLoadUser(
    LoadUserRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final AppUser? user = await repo.getUser(event.uid);
      emit(state.copyWith(loading: false, user: user));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  // WATCH USER REALTIME
  Future<void> _onWatchUser(
    WatchUserRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    await emit.forEach<AppUser?>(
      repo.watchUser(event.uid),
      onData: (user) => state.copyWith(loading: false, user: user),
      onError: (error, _) =>
          state.copyWith(loading: false, error: error.toString()),
    );
  }

  // UPDATE USER PROFILE
  Future<void> _onUpdateUser(
    UpdateUserRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      await repo.updateUser(event.uid, event.data);
      add(LoadUserRequested(event.uid));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
