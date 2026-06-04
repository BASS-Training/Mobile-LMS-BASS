import 'package:equatable/equatable.dart';

class VideoState extends Equatable {
  final bool canProceed;

  const VideoState({this.canProceed = false});

  VideoState copyWith({bool? canProceed}) {
    return VideoState(canProceed: canProceed ?? this.canProceed);
  }

  @override
  List<Object?> get props => [canProceed];
}
