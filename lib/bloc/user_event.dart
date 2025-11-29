import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// LOAD USER PROFILE
class LoadUserRequested extends UserEvent {
  final String uid;

  LoadUserRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

// STREAM REALTIME UPDATES
class WatchUserRequested extends UserEvent {
  final String uid;

  WatchUserRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

// UPDATE USER
class UpdateUserRequested extends UserEvent {
  final String uid;
  final Map<String, dynamic> data;

  UpdateUserRequested(this.uid, this.data);

  @override
  List<Object?> get props => [uid, data];
}
