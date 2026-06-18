import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/agenda/data/agenda_repository.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/agenda_item.dart';

enum AgendaStatus { initial, loading, loaded, error }

class AgendaState extends Equatable {
  final AgendaStatus status;
  final List<AgendaItem> items;
  final String? error;

  const AgendaState({
    this.status = AgendaStatus.initial,
    this.items = const [],
    this.error,
  });

  AgendaState copyWith({
    AgendaStatus? status,
    List<AgendaItem>? items,
    String? error,
  }) => AgendaState(
    status: status ?? this.status,
    items: items ?? this.items,
    error: error,
  );

  @override
  List<Object?> get props => [status, items, error];
}

class AgendaCubit extends Cubit<AgendaState> {
  final AgendaRepository repository;

  AgendaCubit({required this.repository}) : super(const AgendaState());

  Future<void> load() async {
    emit(state.copyWith(status: AgendaStatus.loading, error: null));
    try {
      final items = await repository.getAgenda();
      emit(state.copyWith(status: AgendaStatus.loaded, items: items));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: AgendaStatus.error, error: msg));
    }
  }
}
