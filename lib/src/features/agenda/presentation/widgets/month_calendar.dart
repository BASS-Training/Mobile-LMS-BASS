import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/agenda_date.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

const _monthNames = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];
const _weekLabels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

final DateTime _epoch = DateTime(2000, 1);
int _pageFor(DateTime m) => (m.year - _epoch.year) * 12 + (m.month - 1);
DateTime _monthFor(int page) => DateTime(_epoch.year + page ~/ 12, page % 12 + 1);

/// Grid kalender bulanan custom (mulai Minggu) yang **bisa digeser** antar bulan
/// (PageView). Judul bisa di-tap untuk lompat ke bulan/tahun mana pun. Menandai
/// tanggal merah (Minggu/libur), hari terpilih (lingkaran brand), hari ini
/// (cincin), serta titik penanda sesi & agenda pribadi.
class MonthCalendar extends StatefulWidget {
  final DateTime focusedMonth; // selalu tanggal 1
  final DateTime selectedDay;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback onPickMonth;
  final ValueChanged<DateTime> onSelectDay;
  final String? Function(DateTime) holidayFor;
  final bool Function(DateTime) hasSession;
  final bool Function(DateTime) hasPersonal;

  const MonthCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.onMonthChanged,
    required this.onPickMonth,
    required this.onSelectDay,
    required this.holidayFor,
    required this.hasSession,
    required this.hasPersonal,
  });

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late final PageController _controller =
      PageController(initialPage: _pageFor(widget.focusedMonth));

  @override
  void didUpdateWidget(MonthCalendar old) {
    super.didUpdateWidget(old);
    // Bulan diubah dari luar (pemilih/today/arrows) → animasikan PageView.
    final target = _pageFor(widget.focusedMonth);
    if (_controller.hasClients && _controller.page?.round() != target) {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    final m = _monthFor(page);
    if (m.year != widget.focusedMonth.year ||
        m.month != widget.focusedMonth.month) {
      widget.onMonthChanged(m);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          _header(),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      _weekLabels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: i == 0
                            ? AppColors.brandText
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final cell = constraints.maxWidth / 7;
              return SizedBox(
                height: cell * 6,
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, page) => _grid(_monthFor(page), cell),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        _navBtn(Icons.chevron_left_rounded, () => _controller.previousPage(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            )),
        Expanded(
          child: InkWell(
            onTap: widget.onPickMonth,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_monthNames[widget.focusedMonth.month - 1]} ${widget.focusedMonth.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
        _navBtn(Icons.chevron_right_rounded, () => _controller.nextPage(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            )),
      ],
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 24, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _grid(DateTime month, double cell) {
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday % 7; // Sen=1..Sab=6, Min=7→0
    final start = first.subtract(Duration(days: leading));
    final days =
        List.generate(42, (i) => DateTime(start.year, start.month, start.day + i));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 6; row++)
          SizedBox(
            height: cell,
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  SizedBox(
                    width: cell,
                    height: cell,
                    child: _DayCell(
                      date: days[row * 7 + col],
                      inMonth: days[row * 7 + col].month == month.month,
                      selected:
                          isSameDay(days[row * 7 + col], widget.selectedDay),
                      isToday: isSameDay(days[row * 7 + col], DateTime.now()),
                      holiday: widget.holidayFor(days[row * 7 + col]),
                      hasSession: widget.hasSession(days[row * 7 + col]),
                      hasPersonal: widget.hasPersonal(days[row * 7 + col]),
                      onTap: () => widget.onSelectDay(days[row * 7 + col]),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool inMonth;
  final bool selected;
  final bool isToday;
  final String? holiday;
  final bool hasSession;
  final bool hasPersonal;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.selected,
    required this.isToday,
    required this.holiday,
    required this.hasSession,
    required this.hasPersonal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSunday = date.weekday == DateTime.sunday;
    final isRed = isSunday || holiday != null;

    Color numberColor;
    if (selected) {
      numberColor = Colors.white;
    } else if (!inMonth) {
      numberColor = AppColors.textTertiary.withValues(alpha: 0.5);
    } else if (isRed) {
      numberColor = AppColors.brandText;
    } else {
      numberColor = AppColors.textPrimary;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? AppColors.brandPrimary : Colors.transparent,
            shape: BoxShape.circle,
            border: (!selected && isToday)
                ? Border.all(color: AppColors.brandText, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: (isToday || selected || isRed)
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: numberColor,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasSession)
                    _dot(selected ? Colors.white : AppColors.brandText),
                  if (hasSession && hasPersonal) const SizedBox(width: 2),
                  if (hasPersonal)
                    _dot(selected ? Colors.white : const Color(0xFF0EA5E9)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 4.5,
        height: 4.5,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
