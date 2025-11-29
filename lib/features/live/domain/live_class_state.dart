import 'package:equatable/equatable.dart';
import '../domain/live_class_model.dart';

class LiveClassState extends Equatable {
  final bool loading;
  final String? error;
  final List<LiveClassModel> classes;
  final LiveClassModel? selectedClass;

  const LiveClassState({
    this.loading = false,
    this.error,
    this.classes = const [],
    this.selectedClass,
  });

  LiveClassState copyWith({
    bool? loading,
    String? error,
    List<LiveClassModel>? classes,
    LiveClassModel? selectedClass,
  }) {
    return LiveClassState(
      loading: loading ?? this.loading,
      error: error,
      classes: classes ?? this.classes,
      selectedClass: selectedClass ?? this.selectedClass,
    );
  }

  @override
  List<Object?> get props => [loading, error, classes, selectedClass];
}
