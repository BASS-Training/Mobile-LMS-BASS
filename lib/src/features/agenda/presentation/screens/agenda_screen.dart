import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/agenda_item.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/personal_agenda_item.dart';
import 'package:lms_mobile_app/src/features/agenda/presentation/cubit/agenda_cubit.dart';
import 'package:lms_mobile_app/src/features/agenda/presentation/widgets/add_personal_event_sheet.dart';
import 'package:lms_mobile_app/src/features/agenda/presentation/widgets/month_calendar.dart';
import 'package:lms_mobile_app/src/features/agenda/presentation/widgets/month_year_picker.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

const _dayNames = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];
const _dayShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _monthNames = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];
const _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// Kalender agenda (ala Google Calendar): grid bulanan yang bisa digeser & judul
/// untuk lompat bulan/tahun, detail hari terpilih, dan section "Sesi Mendatang"
/// yang selalu tampil agar jadwal penting (Zoom) tak pernah tersembunyi.
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

  Future<void> _addEvent() async {
    final item =
        await showAddPersonalEventSheet(context, _cubit.state.selectedDay);
    if (item != null) {
      await _cubit.addPersonal(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agenda ditambahkan')),
        );
      }
    }
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthYearPicker(context, _cubit.state.focusedMonth);
    if (picked != null) _cubit.goToMonth(picked);
  }

  void _jumpToDay(DateTime day) {
    _cubit.goToMonth(day);
    _cubit.selectDay(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandAppBar(
        title: 'Jadwal',
        actions: [
          IconButton(
            tooltip: 'Hari ini',
            onPressed: _cubit.goToToday,
            icon: const Icon(Icons.today_rounded, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => _cubit.load(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEvent,
        backgroundColor: AppColors.brandPrimary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocBuilder<AgendaCubit, AgendaState>(
        bloc: _cubit,
        builder: (context, state) {
          return Column(
            children: [
              MonthCalendar(
                focusedMonth: state.focusedMonth,
                selectedDay: state.selectedDay,
                onMonthChanged: _cubit.goToMonth,
                onPickMonth: _pickMonth,
                onSelectDay: _cubit.selectDay,
                holidayFor: state.holidayFor,
                hasSession: state.hasSession,
                hasPersonal: state.hasPersonal,
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brandPrimary,
                  onRefresh: () => _cubit.load(),
                  child: _DetailList(
                    state: state,
                    onDeletePersonal: _cubit.removePersonal,
                    onJumpToDay: _jumpToDay,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailList extends StatelessWidget {
  final AgendaState state;
  final ValueChanged<String> onDeletePersonal;
  final ValueChanged<DateTime> onJumpToDay;

  const _DetailList({
    required this.state,
    required this.onDeletePersonal,
    required this.onJumpToDay,
  });

  @override
  Widget build(BuildContext context) {
    final day = state.selectedDay;
    final holiday = state.holidayFor(day);
    final sessions = state.sessionsOn(day);
    final personal = state.personalOn(day);
    final loading = state.status == AgendaStatus.loading;

    // Sesi mendatang (semua yang dikembalikan API = upcoming/ongoing), urut waktu.
    final upcoming = [...state.sessions]
      ..sort((a, b) => (a.scheduledStart ?? DateTime(0))
          .compareTo(b.scheduledStart ?? DateTime(0)));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Text(
          '${_dayNames[day.weekday - 1]}, ${day.day} ${_monthNames[day.month - 1]} ${day.year}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        if (holiday != null) _HolidayBanner(name: holiday),

        if (state.status == AgendaStatus.error)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Gagal memuat sesi terjadwal: ${state.error}',
              style: TextStyle(fontSize: 12.5, color: AppColors.brandText),
            ),
          ),

        for (final s in sessions) _SessionCard(item: s),
        for (final p in personal)
          _PersonalCard(item: p, onDelete: () => onDeletePersonal(p.id)),

        if (holiday == null && sessions.isEmpty && personal.isEmpty && !loading)
          _emptyHint(),

        if (loading && sessions.isEmpty && personal.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            ),
          ),

        // ── Selalu tampil: sesi penting mendatang (tak tergantung tanggal terpilih).
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.videocam_rounded,
                  size: 17, color: AppColors.brandText),
              const SizedBox(width: 6),
              Text(
                'Sesi Mendatang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Jadwal penting dari kelasmu — tap untuk membuka tanggalnya.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 10),
          for (final s in upcoming)
            _UpcomingTile(
              item: s,
              onTap: () {
                final d = s.scheduledStart;
                if (d != null) onJumpToDay(d);
              },
            ),
        ],
      ],
    );
  }

  Widget _emptyHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.event_note_rounded, size: 38, color: AppColors.textTertiary),
          const SizedBox(height: 10),
          Text(
            'Tidak ada agenda di tanggal ini',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap tombol “Tambah” untuk membuat agenda sendiri.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _HolidayBanner extends StatelessWidget {
  final String name;
  const _HolidayBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.brandText.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brandText.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration_rounded,
              size: 18, color: AppColors.brandText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Libur Nasional · $name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.brandText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final AgendaItem item;
  const _SessionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = item.isOngoing ? AppColors.success : AppColors.brandText;
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
          _LeadingIcon(icon: Icons.videocam_rounded, color: accent),
          const SizedBox(width: 12),
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
                    if (item.isOngoing)
                      _Chip(label: 'Berlangsung', color: AppColors.success),
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
                    _Chip(label: 'Sesi LMS', color: AppColors.brandText),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _t(DateTime? dt) =>
      dt == null ? '--:--' : '${_two(dt.toLocal().hour)}:${_two(dt.toLocal().minute)}';
  String _range(DateTime? s, DateTime? e) =>
      e == null ? _t(s) : '${_t(s)} – ${_t(e)}';
}

class _PersonalCard extends StatelessWidget {
  final PersonalAgendaItem item;
  final VoidCallback onDelete;
  const _PersonalCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0EA5E9);
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
          const _LeadingIcon(icon: Icons.push_pin_rounded, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(Icons.delete_outline_rounded,
                          size: 19, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                if ((item.note ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.note!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (item.hasTime) ...[
                      Icon(Icons.schedule_rounded,
                          size: 13, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        item.timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    const _Chip(label: 'Agenda pribadi', color: accent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris ringkas untuk daftar "Sesi Mendatang": menampilkan tanggal + waktu.
class _UpcomingTile extends StatelessWidget {
  final AgendaItem item;
  final VoidCallback onTap;
  const _UpcomingTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = item.isOngoing ? AppColors.success : AppColors.brandText;
    final start = item.scheduledStart?.toLocal();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              // Kotak tanggal
              Container(
                width: 46,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      start == null ? '--' : _dayShort[start.weekday - 1],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    Text(
                      start == null ? '--' : '${start.day}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                    Text(
                      start == null ? '' : _monthShort[start.month - 1],
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: accent.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      start == null
                          ? (item.courseTitle ?? '')
                          : '${_two(start.hour)}:${_two(start.minute)} · ${item.courseTitle ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isOngoing)
                _Chip(label: 'Berlangsung', color: AppColors.success)
              else
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _LeadingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

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
