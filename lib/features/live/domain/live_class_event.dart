import 'package:equatable/equatable.dart';

abstract class LiveClassEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLiveClassesRequested extends LiveClassEvent {}

class LoadLiveClassDetailRequested extends LiveClassEvent {
  final String liveClassId;

  LoadLiveClassDetailRequested(this.liveClassId);

  @override
  List<Object?> get props => [liveClassId];
}
