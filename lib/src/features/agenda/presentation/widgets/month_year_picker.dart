import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

const _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Pemilih bulan & tahun cepat (ala Google Calendar): pilih tahun dengan ‹ ›
/// atau lompat langsung ke bulan mana pun. Mengembalikan bulan terpilih (atau
/// null bila dibatalkan).
Future<DateTime?> showMonthYearPicker(
  BuildContext context,
  DateTime initial,
) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _MonthYearPicker(initial: initial),
  );
}

class _MonthYearPicker extends StatefulWidget {
  final DateTime initial;
  const _MonthYearPicker({required this.initial});

  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pemilih tahun
          Row(
            children: [
              _yearBtn(Icons.chevron_left_rounded, () => setState(() => _year--)),
              Expanded(
                child: Center(
                  child: Text(
                    '$_year',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              _yearBtn(Icons.chevron_right_rounded, () => setState(() => _year++)),
            ],
          ),
          const SizedBox(height: 16),
          // Grid 12 bulan
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              for (var m = 1; m <= 12; m++) _monthTile(m),
            ],
          ),
        ],
      ),
    );
  }

  Widget _yearBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _monthTile(int month) {
    final isCurrent =
        month == widget.initial.month && _year == widget.initial.year;
    return Material(
      color: isCurrent ? AppColors.brandPrimary : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(DateTime(_year, month)),
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            _monthShort[month - 1],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isCurrent ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
