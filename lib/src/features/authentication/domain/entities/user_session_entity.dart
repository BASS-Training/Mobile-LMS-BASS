import 'package:equatable/equatable.dart';

class UserSessionEntity extends Equatable {
  final String id;
  final String name;
  final String email;

  const UserSessionEntity({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}
