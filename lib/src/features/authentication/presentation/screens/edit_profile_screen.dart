import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/entities/user_entity.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/edit_profile/edit_profile_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Edit the current user's profile: photo + the data captured at registration
/// (name, date of birth, gender, institution, occupation).
class EditProfileScreen extends StatefulWidget {
  final UserEntity user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameC;
  late final TextEditingController _institutionC;
  late final TextEditingController _occupationC;

  DateTime? _dob;
  String? _gender; // 'male' | 'female'
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameC = TextEditingController(text: u.name);
    _institutionC = TextEditingController(text: u.institutionName ?? '');
    _occupationC = TextEditingController(text: u.occupation ?? '');
    _gender = (u.gender == 'male' || u.gender == 'female') ? u.gender : null;
    _dob = u.dateOfBirth != null ? DateTime.tryParse(u.dateOfBirth!) : null;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _institutionC.dispose();
    _occupationC.dispose();
    super.dispose();
  }

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String get _dobLabel =>
      _dob == null ? 'Pilih tanggal' : '${_dob!.day} ${_months[_dob!.month - 1]} ${_dob!.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Pilih tanggal lahir',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: AppColors.brandText),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera_rounded, color: AppColors.brandText),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (img != null) setState(() => _pickedImagePath = img.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka kamera/galeri.')),
        );
      }
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_dob == null) {
      _toast('Pilih tanggal lahir terlebih dahulu.');
      return;
    }
    if (_gender == null) {
      _toast('Pilih jenis kelamin terlebih dahulu.');
      return;
    }
    context.read<EditProfileCubit>().submit(
          name: _nameC.text,
          dateOfBirth: _ymd(_dob!),
          gender: _gender!,
          institutionName: _institutionC.text,
          occupation: _occupationC.text,
          avatarFilePath: _pickedImagePath,
        );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Edit Profil'),
      body: BlocConsumer<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state.status == EditProfileStatus.success &&
              state.updatedUser != null) {
            context.read<AuthBloc>().add(AuthUserUpdatedEvent(state.updatedUser!));
            _toast('Profil berhasil diperbarui.');
            context.pop();
          } else if (state.status == EditProfileStatus.failure) {
            _toast(state.errorMessage ?? 'Gagal memperbarui profil.');
          }
        },
        builder: (context, state) {
          return AbsorbPointer(
            absorbing: state.isSubmitting,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: _avatarPicker()),
                    const SizedBox(height: 28),
                    _label('Nama Lengkap'),
                    TextFormField(
                      controller: _nameC,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec('Nama lengkap', Icons.person_outline_rounded),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    _label('Tanggal Lahir'),
                    _PickerField(
                      icon: Icons.cake_rounded,
                      text: _dobLabel,
                      isPlaceholder: _dob == null,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 18),
                    _label('Jenis Kelamin'),
                    _genderSelector(),
                    const SizedBox(height: 18),
                    _label('Institusi'),
                    TextFormField(
                      controller: _institutionC,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec('Nama institusi', Icons.apartment_rounded),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Institusi tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    _label('Pekerjaan'),
                    TextFormField(
                      controller: _occupationC,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec('Pekerjaan', Icons.work_outline_rounded),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Pekerjaan tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state.isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Avatar ───────────────────────────────────────────────────────────────
  Widget _avatarPicker() {
    final initial = widget.user.name.trim().isNotEmpty
        ? widget.user.name.trim()[0].toUpperCase()
        : '?';
    final remoteUrl = widget.user.avatarUrl;

    Widget avatarChild;
    if (_pickedImagePath != null) {
      avatarChild = Image.file(File(_pickedImagePath!), fit: BoxFit.cover);
    } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
      avatarChild = Image.network(
        remoteUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialAvatar(initial),
      );
    } else {
      avatarChild = _initialAvatar(initial);
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppShadows.sm,
              border: Border.all(color: AppColors.surface, width: 3),
            ),
            child: ClipOval(child: avatarChild),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: const Icon(
                Icons.photo_camera_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialAvatar(String initial) {
    return Container(
      color: AppColors.brandPrimary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.brandText,
          fontSize: 44,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ── Gender ─────────────────────────────────────────────────────────────────
  Widget _genderSelector() {
    return Row(
      children: [
        Expanded(
          child: _genderChip('male', 'Laki-laki', Icons.male_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _genderChip('female', 'Perempuan', Icons.female_rounded),
        ),
      ],
    );
  }

  Widget _genderChip(String value, String label, IconData icon) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brandPrimary.withValues(alpha: 0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.brandPrimary : AppColors.borderDefault,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.brandText : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.brandText : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 0, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  InputDecoration _dec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      fillColor: AppColors.surfaceMuted,
    );
  }
}

/// A read-only, tappable field that looks like a text field (used for the date).
class _PickerField extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPlaceholder;
  final VoidCallback onTap;

  const _PickerField({
    required this.icon,
    required this.text,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isPlaceholder
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.calendar_today_rounded,
                size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
