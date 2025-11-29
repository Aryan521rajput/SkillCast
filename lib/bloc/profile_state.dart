import 'package:equatable/equatable.dart';
import '../features/auth/data/models/app_user.dart';

class ProfileState extends Equatable {
  final bool loading;
  final String? error;
  final bool success;
  final AppUser? user;

  const ProfileState({
    this.loading = false,
    this.error,
    this.success = false,
    this.user,
  });

  ProfileState copyWith({
    bool? loading,
    String? error,
    bool? success,
    AppUser? user,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      error: error,
      success: success ?? this.success,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [loading, error, success, user];
}
