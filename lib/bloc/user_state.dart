import 'package:equatable/equatable.dart';
import 'package:skillcast/features/auth/data/models/app_user.dart';

class UserState extends Equatable {
  final bool loading;
  final String? error;
  final AppUser? user; // <-- Make nullable

  const UserState({this.loading = false, this.error, this.user});

  UserState copyWith({bool? loading, String? error, AppUser? user}) {
    return UserState(
      loading: loading ?? this.loading,
      error: error,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [loading, error, user];
}
