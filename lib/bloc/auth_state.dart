import 'package:equatable/equatable.dart';
import 'package:skillcast/features/auth/data/models/app_user.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? userId;
  final AppUser? user;

  const AuthState({this.isLoading = false, this.error, this.userId, this.user});

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? userId,
    AppUser? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userId: userId ?? this.userId,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, userId, user];
}
