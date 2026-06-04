import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/core/utils/validators.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/widgets/auth_header.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/widgets/auth_scaffold.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _institutionNameController = TextEditingController();
  final _occupationController = TextEditingController();

  int _step = 1;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;
  String? _classInterest;
  String? _gender;
  DateTime? _selectedDateOfBirth;

  static const List<String> _occupationOptions = [
    'Pelajar/Mahasiswa',
    'PNS/ASN',
    'TNI/Polri',
    'Karyawan Swasta',
    'Pegawai BUMN',
    'Wiraswasta',
    'Buruh/Tenaga Harian Lepas',
    'Pedagang',
    'Sopir/Pengemudi',
    'Ibu Rumah Tangga',
    'Pensiunan',
    'Tidak Bekerja',
    'Lainnya',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _dateOfBirthController.dispose();
    _institutionNameController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate =
        _selectedDateOfBirth ?? DateTime(now.year - 18, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Pilih tanggal lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDateOfBirth = pickedDate;
      _dateOfBirthController.text = _formatDate(pickedDate);
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  bool _validateCurrentStep() {
    if (_step == 1) {
      return _step1FormKey.currentState?.validate() ?? false;
    }
    if (_step == 2) {
      return _step2FormKey.currentState?.validate() ?? false;
    }
    return _step3FormKey.currentState?.validate() ?? false;
  }

  bool _validateAllRegistrationData() {
    final nameValid = _nameController.text.trim().isNotEmpty;
    final emailValid = Validators.validateEmail(_emailController.text) == null;
    final passwordValid =
        Validators.validatePassword(_passwordController.text) == null;
    final confirmationValid =
        _passwordConfirmationController.text.isNotEmpty &&
        _passwordConfirmationController.text == _passwordController.text;
    final classInterestValid = _classInterest != null;
    final genderValid = _gender != null;
    final dateOfBirthValid = _selectedDateOfBirth != null;
    final institutionValid = _institutionNameController.text.trim().isNotEmpty;
    final occupationValid = _occupationController.text.trim().isNotEmpty;

    return nameValid &&
        emailValid &&
        passwordValid &&
        confirmationValid &&
        classInterestValid &&
        genderValid &&
        dateOfBirthValid &&
        institutionValid &&
        occupationValid;
  }

  void _goNext() {
    if (_validateCurrentStep()) {
      setState(() {
        _step = (_step + 1).clamp(1, 3);
      });
    }
  }

  void _goBack() {
    setState(() {
      _step = (_step - 1).clamp(1, 3);
    });
  }

  void _submitRegister(BuildContext context) {
    final isValid = _validateAllRegistrationData();

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data dulu sebelum mendaftar.'),
          backgroundColor: AppColors.brandPrimary,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterEvent(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        classInterest: _classInterest ?? 'regular',
        dateOfBirth: _formatDate(_selectedDateOfBirth!),
        gender: _gender ?? 'male',
        institutionName: _institutionNameController.text.trim(),
        occupation: _occupationController.text.trim(),
      ),
    );
  }

  void _clearAuthError(BuildContext context) {
    context.read<AuthBloc>().add(const AuthClearErrorEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akun berhasil dibuat. Masuk ke aplikasi...'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go(AppRoutes.main);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.brandPrimary,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: AuthScaffold(
          maxWidth: 480,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            const FadeSlideIn(
              child: AuthHeader(
                badge: 'BUAT AKUN BARU',
                title: 'Daftar Akun ✨',
                subtitle: 'Satu akun untuk web dan mobile dengan data yang sama.',
              ),
            ),
            const SizedBox(height: 22),
            FadeSlideIn(delayMs: 80, child: _buildProgressIndicator()),
            const SizedBox(height: 20),
            FadeSlideIn(
              delayMs: 140,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppShadows.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildStepContent(),
                    ),
                    const SizedBox(height: 24),
                    _buildNavigation(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sudah punya akun? ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.login),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepChip(1, 'Program & Akun'),
        _buildStepConnector(1),
        _buildStepChip(2, 'Data Diri'),
        _buildStepConnector(2),
        _buildStepChip(3, 'Pekerjaan'),
      ],
    );
  }

  Widget _buildStepChip(int index, String label) {
    final isActive = _step >= index;
    final isCompleted = _step > index;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: isActive ? Colors.white : Colors.white54,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 22,
                      color: AppColors.brandPrimary,
                    )
                  : Text(
                      '$index',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isActive ? AppColors.brandPrimary : Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int index) {
    final isActive = _step > index;

    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 2,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white38,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return Form(
          key: _step1FormKey,
          child: _buildStepCard(
            title: 'Program & Akun',
            subtitle: 'Pilih jalur kelas lalu lengkapi identitas akun.',
            children: [
              _buildProgramSelection(),
              const SizedBox(height: 18),
              _buildInfoBox(
                'Jika memilih AVPN AI, akun akan dibuat dengan status menunggu validasi admin.',
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _nameController,
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
                onChanged: (_) => _clearAuthError(context),
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: AppStrings.email,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.validateEmail,
                onChanged: (_) => _clearAuthError(context),
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: AppStrings.password,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: Validators.validatePassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                onChanged: (_) => _clearAuthError(context),
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _passwordConfirmationController,
                labelText: 'Konfirmasi Password',
                hintText: 'Ulangi password',
                prefixIcon: Icons.verified_user_outlined,
                obscureText: _obscurePasswordConfirmation,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password wajib diisi';
                  }
                  if (value != _passwordController.text) {
                    return 'Konfirmasi password tidak sama';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePasswordConfirmation =
                          !_obscurePasswordConfirmation;
                    });
                  },
                  icon: Icon(
                    _obscurePasswordConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                onChanged: (_) => _clearAuthError(context),
              ),
            ],
          ),
        );
      case 2:
        return Form(
          key: _step2FormKey,
          child: _buildStepCard(
            title: 'Data Diri',
            subtitle: 'Isi data diri yang dipakai untuk validasi akun.',
            children: [
              _buildGenderSelection(),
              const SizedBox(height: 18),
              _buildDatePickerField(),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _institutionNameController,
                labelText: 'Nama Instansi/Sekolah',
                hintText: 'Nama sekolah, kampus, atau perusahaan',
                prefixIcon: Icons.apartment_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama instansi wajib diisi';
                  }
                  return null;
                },
                onChanged: (_) => _clearAuthError(context),
              ),
            ],
          ),
        );
      default:
        return Form(
          key: _step3FormKey,
          child: _buildStepCard(
            title: 'Pekerjaan',
            subtitle: 'Pilih kategori pekerjaan Anda.',
            children: [_buildOccupationGrid()],
          ),
        );
    }
  }

  Widget _buildStepCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      key: ValueKey<int>(_step),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textTertiary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildProgramSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Jalur Kelas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _choiceCard(
                selected: _classInterest == 'regular',
                title: 'Kelas Reguler BASS',
                subtitle: 'Langsung daftar di web atau mobile.',
                icon: Icons.menu_book_outlined,
                onTap: () {
                  setState(() {
                    _classInterest = 'regular';
                  });
                  _clearAuthError(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _choiceCard(
                selected: _classInterest == 'avpn_ai',
                title: 'Literasi AI (AVPN)',
                subtitle: 'Akun masuk status pending validasi.',
                icon: Icons.auto_awesome_outlined,
                onTap: () {
                  setState(() {
                    _classInterest = 'avpn_ai';
                  });
                  _clearAuthError(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FormField<String>(
          validator: (_) => _classInterest == null
              ? 'Pilih jalur kelas terlebih dahulu'
              : null,
          builder: (state) => state.hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    state.errorText ?? '',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kelamin',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _choiceCard(
                selected: _gender == 'male',
                title: 'Laki-laki',
                subtitle: 'Perempuan atau pria',
                icon: Icons.male_outlined,
                onTap: () {
                  setState(() {
                    _gender = 'male';
                  });
                  _clearAuthError(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _choiceCard(
                selected: _gender == 'female',
                title: 'Perempuan',
                subtitle: 'Data sesuai identitas',
                icon: Icons.female_outlined,
                onTap: () {
                  setState(() {
                    _gender = 'female';
                  });
                  _clearAuthError(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FormField<String>(
          validator: (_) =>
              _gender == null ? 'Pilih jenis kelamin terlebih dahulu' : null,
          builder: (state) => state.hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    state.errorText ?? '',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Lahir',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateOfBirthController,
          readOnly: true,
          onTap: _pickDateOfBirth,
          decoration: InputDecoration(
            hintText: 'Pilih tanggal lahir',
            prefixIcon: const Icon(Icons.calendar_month_outlined),
            suffixIcon: IconButton(
              onPressed: _pickDateOfBirth,
              icon: const Icon(Icons.edit_calendar_outlined),
            ),
          ),
          validator: (_) {
            if (_selectedDateOfBirth == null) {
              return 'Tanggal lahir wajib diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOccupationGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pekerjaan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _occupationOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10,
            childAspectRatio: 4.8,
          ),
          itemBuilder: (context, index) {
            final occupation = _occupationOptions[index];
            final selected = _occupationController.text == occupation;

            return _choiceCard(
              selected: selected,
              title: occupation,
              subtitle: '',
              icon: Icons.work_outline,
              compact: true,
              onTap: () {
                setState(() {
                  _occupationController.text = occupation;
                });
                _clearAuthError(context);
              },
            );
          },
        ),
        const SizedBox(height: 10),
        FormField<String>(
          validator: (_) => _occupationController.text.trim().isEmpty
              ? 'Pilih pekerjaan terlebih dahulu'
              : null,
          builder: (state) => state.hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    state.errorText ?? '',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _choiceCard({
    required bool selected,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    final basePadding = compact
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
        : const EdgeInsets.all(14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: basePadding,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF1F1) : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.brandPrimary
                  : AppColors.borderDefault,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.brandPrimary : Colors.white,
                  border: Border.all(
                    color: selected
                        ? AppColors.brandPrimary
                        : AppColors.borderDefault,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: compact
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? AppColors.brandPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (!compact && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4C56A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20, color: Color(0xFFB97700)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF8A5A00),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Widget _buildNavigation(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isLoading = authState is AuthLoading;

    return Row(
      children: [
        if (_step > 1)
          OutlinedButton.icon(
            onPressed: isLoading ? null : _goBack,
            icon: const Icon(Icons.arrow_back_outlined),
            label: const Text('Kembali'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.borderDefault),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          )
        else
          const SizedBox.shrink(),
        const Spacer(),
        if (_step < 3)
          ElevatedButton.icon(
            onPressed: isLoading ? null : _goNext,
            icon: const Icon(Icons.arrow_forward_outlined),
            label: const Text('Selanjutnya'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: isLoading ? null : () => _submitRegister(context),
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(isLoading ? 'Mendaftar...' : 'Daftar Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
      ],
    );
  }
}
