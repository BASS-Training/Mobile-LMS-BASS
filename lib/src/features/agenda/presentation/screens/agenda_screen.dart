import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/agenda_item.dart';
import 'package:lms_mobile_app/src/features/agenda/presentation/cubit/agenda_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];
const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// Daftar sesi terjadwal (Zoom) mendatang & berlangsung, dikelompokkan per hari.
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final _cubit = ServiceLocator().locator<AgendaCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandAppBar(
        title: 'Jadwal',
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => _cubit.load(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<AgendaCubit, AgendaState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.status == AgendaStatus.loading ||
              state.status == AgendaStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }
          if (state.status == AgendaStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat jadwal',
              message: state.error ?? 'Terjadi kesalahan.',
              actionLabel: 'Coba lagi',
              onAction: () => _cubit.load(),
            );
          }
          if (state.items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.event_available_rounded,
              title: 'Belum ada jadwal',
              message:
                  'Sesi terjadwal (mis. Zoom) dari kelas yang kamu ikuti akan muncul di sini.',
            );
          }

          return RefreshIndicator(
            color: AppColors.brandPrimary,
            onRefresh: () => _cubit.load(),
            child: _buildGroupedList(state.items),
          );
        },
      ),
    );
  }

  Widget _buildGroupedList(List<AgendaItem> items) {
    // Bangun daftar campuran: header tanggal + kartu sesi, dikelompokkan per hari.
    final children = <Widget>[];
    String? lastKey;
    for (final item in items) {
      final key = _dayKey(item.scheduledStart);
      if (key != lastKey) {
        children.add(_DayHeader(label: _dayLabel(item.scheduledStart)));
        lastKey = key;
      }
      children.add(_AgendaCard(item: item));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      physics: const AlwaysScrollableScrollPhysics(),
      children: children,
    );
  }

  String _dayKey(DateTime? dt) {
    if (dt == null) return 'none';
    final l = dt.toLocal();
    return '${l.year}-${l.month}-${l.day}';
  }

  String _dayLabel(DateTime? dt) {
    if (dt == null) return 'Tanpa tanggal';
    final l = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(l.year, l.month, l.day);
    final diff = that.difference(today).inDays;
    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Besok';
    return '${_days[l.weekday - 1]}, ${l.day} ${_months[l.month - 1]} ${l.year}';
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 0, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final AgendaItem item;
  const _AgendaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = item.isOngoing ? AppColors.success : AppColors.brandPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom waktu
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.videocam_rounded, size: 18, color: accent),
                const SizedBox(height: 4),
                Text(
                  _time(item.scheduledStart),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (item.isOngoing) _StatusChip(label: 'Berlangsung', color: AppColors.success),
                  ],
                ),
                if ((item.courseTitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.courseTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      _range(item.scheduledStart, item.scheduledEnd),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    if (!item.isOngoing)
                      Text(
                        _countdown(item.scheduledStart),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _time(DateTime? dt) {
    if (dt == null) return '--:--';
    final l = dt.toLocal();
    final h = l.hour.toString().padLeft(2, '0');
    final m = l.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _range(DateTime? start, DateTime? end) {
    final s = _time(start);
    if (end == null) return s;
    return '$s – ${_time(end)}';
  }

  /// Hitung mundur kasar menuju mulai sesi ("dalam 3 hari", "2 jam lagi", dll.).
  String _countdown(DateTime? start) {
    if (start == null) return '';
    final diff = start.toLocal().difference(DateTime.now());
    if (diff.isNegative) return '';
    if (diff.inDays >= 1) return 'dalam ${diff.inDays} hari';
    if (diff.inHours >= 1) return '${diff.inHours} jam lagi';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} menit lagi';
    return 'sebentar lagi';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
