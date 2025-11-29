import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../features/auth/data/repositories/user_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository repo;

  ProfileBloc({required this.repo}) : super(const ProfileState()) {
    on<LoadUserProfileRequested>(_onLoadProfile);
    on<UpdateUserProfileRequested>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadUserProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: false));

    try {
      final user = await repo.getUser(event.uid);

      emit(state.copyWith(loading: false, user: user, success: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString(), success: false));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateUserProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: false));

    try {
      await repo.updateUser(event.uid, event.data);

      // ✅ FIRST: mark success
      emit(state.copyWith(loading: false, success: true, error: null));

      // ❗ THEN refresh profile (but do not reset success)
      add(LoadUserProfileRequested(event.uid));
    } catch (e) {
      emit(state.copyWith(loading: false, success: false, error: e.toString()));
    }
  }
}
