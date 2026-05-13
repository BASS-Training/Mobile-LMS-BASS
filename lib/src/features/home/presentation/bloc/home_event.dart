import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class SubmitJoinClassTokenEvent extends HomeEvent {
  final String token;

  const SubmitJoinClassTokenEvent(this.token);

  @override
  List<Object?> get props => [token];
}
