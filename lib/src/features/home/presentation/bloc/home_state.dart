import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  List<Object?> get props => [];
}

class HomeJoinClassLoading extends HomeState {
  const HomeJoinClassLoading();

  @override
  List<Object?> get props => [];
}

class HomeJoinClassSuccess extends HomeState {
  final String message;

  const HomeJoinClassSuccess({this.message = 'Berhasil gabung kelas'});

  @override
  List<Object?> get props => [message];
}

class HomeJoinClassFailure extends HomeState {
  final String message;

  const HomeJoinClassFailure(this.message);

  @override
  List<Object?> get props => [message];
}
