import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/feedback_entity.dart';

enum FeedbackStatus { initial, loading, loaded, error }

class FeedbackState extends Equatable {
  final FeedbackStatus status;
  final FeedbackEntity? data;
  final bool submitting;
  final bool justSubmitted;
  final String? errorMessage;
  final String? infoMessage;

  const FeedbackState({
    this.status = FeedbackStatus.initial,
    this.data,
    this.submitting = false,
    this.justSubmitted = false,
    this.errorMessage,
    this.infoMessage,
  });

  FeedbackState copyWith({
    FeedbackStatus? status,
    FeedbackEntity? data,
    bool? submitting,
    bool? justSubmitted,
    String? errorMessage,
    String? infoMessage,
    bool clearMessages = false,
  }) {
    return FeedbackState(
      status: status ?? this.status,
      data: data ?? this.data,
      submitting: submitting ?? this.submitting,
      justSubmitted: justSubmitted ?? this.justSubmitted,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearMessages ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    submitting,
    justSubmitted,
    errorMessage,
    infoMessage,
  ];
}
