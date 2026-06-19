import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/update_profile_usecase.dart';

enum EditProfileStatus { initial, submitting, success, failure }

class EditProfileState extends Equatable {
  final EditProfileStatus status;
  final String? errorMessage;
  final UserEntity? updatedUser;

  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.errorMessage,
    this.updatedUser,
  });

  bool get isSubmitting => status == EditProfileStatus.submitting;

  EditProfileState copyWith({
    EditProfileStatus? status,
    String? errorMessage,
    UserEntity? updatedUser,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      updatedUser: updatedUser ?? this.updatedUser,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, updatedUser];
}

/// Handles submitting the edit-profile form. UI stays dumb: it owns the text
/// controllers and just calls [submit]; this cubit owns the async + status.
class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUseCase _updateProfile;

  EditProfileCubit(this._updateProfile) : super(const EditProfileState());

  Future<void> submit({
    required String name,
    required String dateOfBirth,
    required String gender,
    required String institutionName,
    required String occupation,
    String? avatarFilePath,
  }) async {
    emit(state.copyWith(status: EditProfileStatus.submitting));
    try {
      final user = await _updateProfile(
        name: name,
        dateOfBirth: dateOfBirth,
        gender: gender,
        institutionName: institutionName,
        occupation: occupation,
        avatarFilePath: avatarFilePath,
      );
      if (user != null) {
        emit(state.copyWith(
          status: EditProfileStatus.success,
          updatedUser: user,
        ));
      } else {
        emit(state.copyWith(
          status: EditProfileStatus.failure,
          errorMessage: 'Gagal memperbarui profil.',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: EditProfileStatus.failure,
        errorMessage: error.toString().replaceFirst('Exception: ', '').trim(),
      ));
    }
  }
}
