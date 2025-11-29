import 'package:equatable/equatable.dart';

class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchRequested extends SearchEvent {
  final String query;

  SearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}
