import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/personal_agenda_item.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Menampilkan form tambah agenda pribadi untuk [date]. Mengembalikan item baru
/// (atau null bila dibatalkan).
Future<PersonalAgendaItem?> showAddPersonalEventSheet(
  BuildContext context,
  DateTime date,
) {
  return showModalBottomSheet<PersonalAgendaItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _AddPersonalEventForm(date: date),
    ),
  );
}

class _AddPersonalEventForm extends StatefulWidget {
  final DateTime date;
  const _AddPersonalEventForm({required this.date});

  @override
  State<_AddPersonalEventForm> createState() => _AddPersonalEventFormState();
}

class _AddPersonalEventFormState extends State<_AddPersonalEventForm> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TimeOfDay? _time;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final item = PersonalAgendaItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      date: widget.date,
      hour: _time?.hour,
      minute: _time?.minute,
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.date;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Agenda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${d.day} ${_months[d.month - 1]} ${d.year}',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: _dec('Judul agenda', 'mis. Belajar bab 3'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: _dec('Catatan (opsional)', 'Detail tambahan'),
          ),
          const SizedBox(height: 12),
          // Pemilih waktu opsional
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _time ?? TimeOfDay.now(),
              );
              if (picked != null) setState(() => _time = picked);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    _time == null
                        ? 'Tambah waktu (opsional)'
                        : 'Pukul ${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _time == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_time != null)
                    GestureDetector(
                      onTap: () => setState(() => _time = null),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _save,
              child: const Text(
                'Simpan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandPrimary),
        ),
      );
}
