import 'package:equatable/equatable.dart';

class EssayQuestionEntity extends Equatable {
  final String id;
  final String text;
  final int order;
  final int maxScore;

  const EssayQuestionEntity({
    required this.id,
    required this.text,
    required this.order,
    required this.maxScore,
  });

  @override
  List<Object?> get props => [id, text, order, maxScore];
}
