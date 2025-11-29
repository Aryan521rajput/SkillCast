// lib/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);

    on<AuthClearError>((event, emit) {
      emit(state.copyWith(error: null));
    });

    add(AuthCheckRequested());
  }

  // -------------------------------------------------------
  // CHECK USER STATUS
  // -------------------------------------------------------
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final current = authRepository.currentUser;

      if (current == null) {
        emit(state.copyWith(isLoading: false, user: null, userId: null));
        return;
      }

      final profile = await authRepository.getUserProfile(current.uid);

      emit(
        state.copyWith(isLoading: false, userId: current.uid, user: profile),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // -------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final user = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (user == null) {
        emit(state.copyWith(isLoading: false, error: "Invalid credentials"));
        return;
      }

      final profile = await authRepository.getUserProfile(user.uid);

      emit(state.copyWith(isLoading: false, userId: user.uid, user: profile));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // -------------------------------------------------------
  // REGISTER → NO AUTO-LOGIN
  // -------------------------------------------------------
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await authRepository.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );

      if (result == null) {
        emit(state.copyWith(isLoading: false, error: "Registration failed"));
        return;
      }

      // ❌ DO NOT AUTO LOGIN
      // ❌ DO NOT load user profile
      // ✔ Return clean state so RegisterScreen can pop back

      emit(state.copyWith(
        isLoading: false,
        user: null,
        userId: null,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // -------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const AuthState());
  }

  // -------------------------------------------------------
  // RESET PASSWORD
  // -------------------------------------------------------
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await authRepository.resetPassword(email: event.email);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

// -----------------------------------------------------------
// 🔥 ADMIN DETECTION
// -----------------------------------------------------------
extension AuthRoleCheck on AuthState {
  bool get isAdmin => user?.role == "Admin";
}
