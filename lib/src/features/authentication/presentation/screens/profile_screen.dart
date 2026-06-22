import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/entities/user_entity.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/theme/theme_controller.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthSuccess) {
          return const Scaffold(body: Center(child: Text('No user logged in')));
        }
        final user = state.user;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _ProfileHeader(user: user, roleLabel: _roleLabel(user.role)),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Akun'),
                        _SectionCard(
                          children: [
                            _NavRow(
                              icon: Icons.edit_rounded,
                              accent: AppColors.brandPrimary,
                              title: 'Edit Profil',
                              subtitle: 'Ubah foto & data diri',
                              onTap: () => context.push(
                                AppRoutes.editProfile,
                                extra: user,
                              ),
                            ),
                          ],
                        ),
                        _buildPersonalSection(user),
                        _buildAccountSection(user),
                        // _sectionLabel('Pembelajaran'),
                        // _SectionCard(
                        //   children: [
                        //     _NavRow(
                        //       icon: Icons.workspace_premium_rounded,
                        //       accent: AppColors.warning,
                        //       title: 'Sertifikat Saya',
                        //       subtitle: 'Lihat sertifikat yang sudah diraih',
                        //       onTap: () =>
                        //           context.push(AppRoutes.certificateList),
                        //     ),
                        //     _NavRow(
                        //       icon: Icons.bookmark_rounded,
                        //       accent: AppColors.brandPrimary,
                        //       title: 'Kursus Tersimpan',
                        //       subtitle: 'Koleksi kursus yang kamu simpan',
                        //       onTap: () => context.push(AppRoutes.savedCourses),
                        //     ),
                        //   ],
                        // ),
                        _sectionLabel('Pengaturan Aplikasi'),
                        _SectionCard(
                          children: [
                            _NavRow(
                              icon: Icons.dark_mode_outlined,
                              accent: AppColors.violet,
                              title: 'Mode Tampilan',
                              subtitle: _themeLabel(
                                ThemeController.instance.mode,
                              ),
                              onTap: () => _showThemeSelector(context),
                            ),
                          ],
                        ),
                        _sectionLabel('Dukungan'),
                        _SectionCard(
                          children: [
                            _NavRow(
                              icon: Icons.help_outline_rounded,
                              accent: AppColors.success,
                              title: 'Pusat Bantuan',
                              subtitle: 'FAQ & kontak dukungan',
                              onTap: () => _showHelp(context),
                            ),
                            _NavRow(
                              icon: Icons.privacy_tip_outlined,
                              accent: AppColors.info,
                              title: 'Kebijakan Privasi',
                              subtitle: 'Bagaimana data kamu digunakan',
                              onTap: () => _showPrivacy(context),
                            ),
                            _NavRow(
                              icon: Icons.info_outline_rounded,
                              accent: AppColors.violet,
                              title: 'Tentang Aplikasi',
                              subtitle: 'BASS — Bintang Anugrah Surya Semesta',
                              onTap: () => _showAbout(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _LogoutButton(onTap: () => _confirmLogout(context)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Sections ───────────────────────────────────────────────────────────────
  Widget _buildPersonalSection(UserEntity user) {
    final rows = <Widget>[
      if (user.dateOfBirth != null)
        _InfoRow(
          icon: Icons.cake_rounded,
          accent: AppColors.brandPrimary,
          label: 'Tanggal Lahir',
          value: _formatDate(user.dateOfBirth),
        ),
      if (user.gender != null)
        _InfoRow(
          icon: Icons.wc_rounded,
          accent: AppColors.info,
          label: 'Jenis Kelamin',
          value: _genderLabel(user.gender!),
        ),
      if (user.institutionName != null)
        _InfoRow(
          icon: Icons.apartment_rounded,
          accent: AppColors.success,
          label: 'Institusi',
          value: user.institutionName!,
        ),
      if (user.occupation != null)
        _InfoRow(
          icon: Icons.work_outline_rounded,
          accent: AppColors.warning,
          label: 'Pekerjaan',
          value: user.occupation!,
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Informasi Pribadi'),
        _SectionCard(children: rows),
      ],
    );
  }

  Widget _buildAccountSection(UserEntity user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _sectionLabel('Akun'),
        _SectionCard(
          children: [
            _InfoRow(
              icon: Icons.verified_user_rounded,
              accent: AppColors.success,
              label: 'Status Akun',
              value: 'Aktif',
            ),
            _InfoRow(
              icon: Icons.badge_rounded,
              accent: AppColors.brandPrimary,
              label: 'Peran',
              value: _roleLabel(user.role),
            ),
            if (user.registrationProgram != null)
              _InfoRow(
                icon: Icons.school_rounded,
                accent: AppColors.info,
                label: 'Program',
                value: _programLabel(user.registrationProgram!),
              ),
            if (user.isAvpn && user.avpnVerificationStatus != null)
              _InfoRow(
                icon: Icons.fact_check_rounded,
                accent: AppColors.warning,
                label: 'Verifikasi AVPN',
                value: _avpnLabel(user.avpnVerificationStatus!),
              ),
            // Sembunyikan baris ini bila tanggal bergabung tak tersedia
            // (mis. sesi lama ter-cache) agar tidak menampilkan "-" yang janggal.
            if (user.joinedAt != null &&
                DateTime.tryParse(user.joinedAt!) != null)
              _InfoRow(
                icon: Icons.calendar_today_rounded,
                accent: AppColors.violet,
                label: 'Bergabung Sejak',
                value: _formatJoined(user.joinedAt),
              ),
          ],
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── Formatting helpers ──────────────────────────────────────────────────────
  String _formatDate(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso);
    if (d == null) return '-';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String _formatJoined(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso);
    if (d == null) return '-';
    return '${_months[d.month - 1]} ${d.year}';
  }

  String _genderLabel(String g) =>
      g == 'male' ? 'Laki-laki' : (g == 'female' ? 'Perempuan' : g);

  String _programLabel(String p) =>
      p == 'avpn_ai' ? 'AVPN AI' : (p == 'regular' ? 'Reguler' : p);

  String _avpnLabel(String s) {
    switch (s) {
      case 'verified':
        return 'Terverifikasi';
      case 'pending':
        return 'Menunggu verifikasi';
      case 'rejected':
        return 'Ditolak';
      default:
        return s;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'super-admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'instructor':
        return 'Instruktur';
      case 'event-organizer':
        return 'Event Organizer';
      case 'participant':
        return 'Peserta';
      default:
        return role.isEmpty
            ? 'Peserta'
            : role[0].toUpperCase() + role.substring(1);
    }
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.brandGradient),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'BASS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Bintang Anugrah Surya Semesta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Versi 0.1.0',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 14),
            Text(
              'Platform pembelajaran untuk peserta & instruktur akademi BASS.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandPrimary,
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      case ThemeMode.system:
        return 'Ikuti sistem';
    }
  }

  void _showThemeSelector(BuildContext context) {
    final current = ThemeController.instance.mode;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        Widget option(ThemeMode mode, IconData icon, String label) {
          final selected = mode == current;
          return ListTile(
            leading: Icon(
              icon,
              color: selected
                  ? AppColors.brandPrimary
                  : AppColors.textSecondary,
            ),
            title: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: selected
                ? Icon(Icons.check_rounded, color: AppColors.brandText)
                : null,
            onTap: () {
              Navigator.pop(sheetContext);
              ThemeController.instance.setMode(mode);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Text(
                  'Mode Tampilan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              option(ThemeMode.light, Icons.light_mode_rounded, 'Terang'),
              option(ThemeMode.dark, Icons.dark_mode_rounded, 'Gelap'),
              option(
                ThemeMode.system,
                Icons.brightness_auto_rounded,
                'Ikuti sistem',
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showHelp(BuildContext context) {
    _infoDialog(
      context,
      icon: Icons.help_outline_rounded,
      title: 'Pusat Bantuan',
      body:
          'Butuh bantuan dalam menggunakan aplikasi?\n\n'
          '• Mulai belajar: buka tab Kursus, pilih kelas, lalu ketuk materi.\n'
          '• Gabung kelas: gunakan token dari instruktur di menu "Gabung Kelas".\n'
          '• Sertifikat: terbit otomatis setelah kursus tuntas 100%.\n\n'
          'Masih ada kendala? Hubungi instruktur atau admin akademi BASS.',
    );
  }

  void _showPrivacy(BuildContext context) {
    _infoDialog(
      context,
      icon: Icons.privacy_tip_outlined,
      title: 'Kebijakan Privasi',
      body:
          'Aplikasi BASS hanya mengumpulkan data yang diperlukan untuk '
          'pembelajaran (identitas, progres belajar, nilai). Data kamu '
          'digunakan untuk menampilkan progres dan sertifikat, serta tidak '
          'dibagikan ke pihak ketiga tanpa izin. Dengan menggunakan aplikasi '
          'ini kamu menyetujui pengelolaan data sebagaimana mestinya oleh '
          'akademi BASS.',
    );
  }

  void _infoDialog(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(icon, color: AppColors.brandText, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandPrimary,
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutEvent());
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandPrimary,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final String roleLabel;

  const _ProfileHeader({required this.user, required this.roleLabel});

  Widget _avatarInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = user.name.trim().isNotEmpty
        ? user.name.trim()[0].toUpperCase()
        : '?';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Profil Saya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                    ? Image.network(
                        user.avatarUrl!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _avatarInitial(initial),
                      )
                    : _avatarInitial(initial),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.badge_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    roleLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A grouped card holding several rows separated by thin dividers.
class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.borderSubtle,
          ),
        );
      }
      rows.add(children[i]);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: Column(children: rows),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Keluar'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          side: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
