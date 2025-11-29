import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserProfileRequested extends ProfileEvent {
  final String uid;

  LoadUserProfileRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UpdateUserProfileRequested extends ProfileEvent {
  final String uid;
  final Map<String, dynamic> data;

  UpdateUserProfileRequested(this.uid, this.data);

  @override
  List<Object?> get props => [uid, data];
}
