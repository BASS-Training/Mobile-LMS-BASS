import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String userName;
  final String message;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.userName,
    required this.message,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userName, message, createdAt];
}