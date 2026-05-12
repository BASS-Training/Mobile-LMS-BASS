import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String userName;
  final String message;
  final String timeLabel;

  const CommentEntity({
    required this.userName,
    required this.message,
    required this.timeLabel,
  });

  @override
  List<Object?> get props => [userName, message, timeLabel];
}