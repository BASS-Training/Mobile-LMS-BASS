import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/document_submission_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/document_submission/document_submission_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Panel pengumpulan tugas dokumen untuk peserta (mirror partial web).
/// Self-contained: memuat state-nya sendiri lewat [DocumentSubmissionCubit].
class DocumentSubmissionPanel extends StatelessWidget {
  final String lessonId;

  /// Dipanggil setelah "Kumpulkan" sukses agar layar dapat me-refresh course
  /// (mis. memperbarui status penyelesaian / kunci lesson berikutnya).
  final VoidCallback? onSubmitted;

  /// Dipanggil tiap data pengumpulan dimuat/berubah, agar layar bisa mengunci
  /// tombol "Lanjut" sesuai status submission (mirror gating web).
  final ValueChanged<DocumentSubmissionData>? onData;

  const DocumentSubmissionPanel({
    super.key,
    required this.lessonId,
    this.onSubmitted,
    this.onData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DocumentSubmissionCubit(
        repository: GetIt.instance<DocumentSubmissionRepository>(),
        lessonId: lessonId,
      )..load(),
      child: _PanelView(onSubmitted: onSubmitted, onData: onData),
    );
  }
}

class _PanelView extends StatelessWidget {
  final VoidCallback? onSubmitted;
  final ValueChanged<DocumentSubmissionData>? onData;
  const _PanelView({this.onSubmitted, this.onData});

  static String _fmtSize(int? bytes) {
    if (bytes == null || bytes == 0) return '';
    const units = ['B', 'KB', 'MB', 'GB'];
    double b = bytes.toDouble();
    int i = 0;
    while (b >= 1024 && i < units.length - 1) {
      b /= 1024;
      i++;
    }
    final v = (b < 10 && i > 0) ? b.toStringAsFixed(1) : b.toStringAsFixed(0);
    return '$v ${units[i]}';
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    DocumentSubmissionData data,
  ) async {
    final cubit = context.read<DocumentSubmissionCubit>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: data.allowedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final path = file.path;
    if (path == null) return;

    // Cek ukuran di sisi klien untuk UX lebih baik (backend tetap memvalidasi).
    final maxBytes = data.maxSizeMb * 1024 * 1024;
    if (file.size > maxBytes) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ukuran file melebihi ${data.maxSizeMb} MB.'),
          ),
        );
      }
      return;
    }
    await cubit.upload(path);
  }

  Future<void> _openFile(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka file.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentSubmissionCubit, DocumentSubmissionState>(
      listenWhen: (p, c) =>
          p.message != c.message ||
          p.error != c.error ||
          p.data != c.data ||
          (!p.submitted && c.submitted),
      listener: (context, state) {
        if (state.data != null) onData?.call(state.data!);
        if (state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
        } else if (state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.jade,
              ),
            );
        }
        if (state.submitted) onSubmitted?.call();
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _content(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.red, AppColors.tomato],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.upload_file_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Pengumpulan Tugas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Unggah dokumen tugas Anda, lalu kumpulkan untuk dinilai.',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, DocumentSubmissionState state) {
    if (state.status == DocSubStatus.loading && state.data == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.red)),
      );
    }
    if (state.status == DocSubStatus.error && state.data == null) {
      return Column(
        children: [
          Text(
            state.error ?? 'Gagal memuat.',
            style: TextStyle(color: AppColors.slate),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<DocumentSubmissionCubit>().load(),
            child: const Text('Coba lagi'),
          ),
        ],
      );
    }

    final data = state.data;
    if (data == null) return const SizedBox.shrink();

    final latest = data.latest;
    final children = <Widget>[];

    // Info terkunci (wajib lulus & belum lulus)
    if (data.requireSubmissionPass && !data.isPassed) {
      children.add(
        _infoBox(
          icon: Icons.lock_outline_rounded,
          color: AppColors.brandText,
          bg: AppColors.surfaceMuted,
          text:
              'Konten berikutnya terkunci sampai tugas Anda dinilai Lulus.',
        ),
      );
    }

    // Instruksi
    if ((data.instructions ?? '').isNotEmpty) {
      children.add(
        _softCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INSTRUKSI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandText,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.instructions!,
                style: TextStyle(fontSize: 13, color: AppColors.charcoal),
              ),
            ],
          ),
        ),
      );
    }

    // Status banner
    if (data.isWaiting) {
      children.add(
        _statusBanner(
          emoji: '⏳',
          bg: AppColors.warningSurface,
          border: AppColors.warningBorder,
          titleColor: AppColors.warningText,
          title: 'Menunggu penilaian',
          body:
              'Tugas Anda (percobaan ke-${latest?.attempt ?? 1}) sudah dikumpulkan dan menunggu penilaian instruktur.',
        ),
      );
    } else if (data.isPassed) {
      children.add(
        _statusBanner(
          emoji: '✅',
          bg: AppColors.successSurface,
          border: AppColors.successBorder,
          titleColor: AppColors.successText,
          title: data.scoringEnabled && latest?.score != null
              ? 'Lulus — Nilai: ${latest!.score}'
              : 'Lulus',
          body: 'Selamat! Tugas Anda telah dinilai lulus.',
          feedback: latest?.feedback,
        ),
      );
    } else if (data.isFailed) {
      children.add(
        _statusBanner(
          emoji: '🔁',
          bg: AppColors.warningSurface,
          border: AppColors.warningBorder,
          titleColor: AppColors.warningText,
          title: data.scoringEnabled && latest?.score != null
              ? 'Belum lulus — Nilai: ${latest!.score}'
              : 'Belum lulus',
          body:
              'Percobaan ke-${latest?.attempt ?? 1} belum lulus. Perbaiki dan unggah percobaan berikutnya.',
          feedback: latest?.feedback,
          feedbackLabel: 'Catatan revisi',
        ),
      );
    }

    // File draft aktif (belum dikumpulkan)
    if (data.isDraft && (latest?.hasFile ?? false)) {
      children.add(_draftFileCard(context, data, latest!));
    }

    // Area unggah
    if (data.canUpload) {
      children.add(_uploadArea(context, data, state));
    }

    // Tombol Kumpulkan
    if (data.isDraft && (latest?.hasFile ?? false)) {
      children.add(_submitButton(context, state));
    }

    // Riwayat
    if (data.history.isNotEmpty) {
      children.add(_history(context, data));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _withGaps(children),
    );
  }

  List<Widget> _withGaps(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(const SizedBox(height: 14));
    }
    return out;
  }

  Widget _draftFileCard(
    BuildContext context,
    DocumentSubmissionData data,
    DocumentSubmissionAttempt latest,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_rounded, color: AppColors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  latest.originalName ?? 'File',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  '${_fmtSize(latest.fileSize)} • Belum dikumpulkan',
                  style: TextStyle(fontSize: 11, color: AppColors.slate),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Buka',
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
            color: AppColors.brandText,
            onPressed: () => _openFile(context, latest.fileUrl),
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.tomato,
            onPressed: () => _confirmRemove(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final cubit = context.read<DocumentSubmissionCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus file?'),
        content: const Text('File yang diunggah akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) cubit.removeFile();
  }

  Widget _uploadArea(
    BuildContext context,
    DocumentSubmissionData data,
    DocumentSubmissionState state,
  ) {
    final hasDraftFile = data.isDraft && (data.latest?.hasFile ?? false);
    final label = data.isFailed
        ? 'Unggah Percobaan ke-${data.nextAttempt}'
        : (hasDraftFile ? 'Ganti File' : 'Unggah File Tugas');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: state.busy ? null : () => _pickAndUpload(context, data),
            icon: state.busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.red,
                    ),
                  )
                : const Icon(Icons.attach_file_rounded),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandText,
              side: BorderSide(color: AppColors.brandText, width: 1.4),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tipe: ${data.allowedTypes.toUpperCase().replaceAll(',', ', ')} • Maks ${data.maxSizeMb} MB',
          style: TextStyle(fontSize: 11, color: AppColors.slate),
        ),
      ],
    );
  }

  Widget _submitButton(BuildContext context, DocumentSubmissionState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.busy ? null : () => _confirmSubmit(context),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Kumpulkan Tugas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.jade,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '🔒 Setelah dikumpulkan, tugas terkunci hingga dinilai instruktur.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.slate),
        ),
      ],
    );
  }

  Future<void> _confirmSubmit(BuildContext context) async {
    final cubit = context.read<DocumentSubmissionCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kumpulkan tugas?'),
        content: const Text(
          'Setelah dikumpulkan tidak bisa diubah sampai dinilai instruktur.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.jade),
            child: const Text('Kumpulkan'),
          ),
        ],
      ),
    );
    if (ok == true) cubit.submit();
  }

  Widget _history(BuildContext context, DocumentSubmissionData data) {
    // Material transparan agar ListTile milik ExpansionTile punya Material
    // ancestor untuk melukis ink/latar (menghindari assertion Flutter karena
    // panel dibungkus Container ber-warna).
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
        title: Text(
          'Riwayat Pengumpulan (${data.history.length})',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.slate,
          ),
        ),
          children:
              data.history.map((s) => _historyRow(context, data, s)).toList(),
        ),
      ),
    );
  }

  Widget _historyRow(
    BuildContext context,
    DocumentSubmissionData data,
    DocumentSubmissionAttempt s,
  ) {
    final (label, bg, fg) = switch (s.status) {
      'passed' => ('Lulus', AppColors.successSurface, AppColors.successText),
      'failed' => (
        'Belum lulus',
        AppColors.warningSurface,
        AppColors.warningText,
      ),
      _ => ('Menunggu', AppColors.surfaceMuted, AppColors.slate),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${s.attempt}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.originalName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.scoringEnabled && s.score != null
                      ? '$label · ${s.score}'
                      : label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (s.hasFile)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  color: AppColors.brandText,
                  onPressed: () => _openFile(context, s.fileUrl),
                ),
            ],
          ),
          if ((s.feedback ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Feedback: ${s.feedback}',
                style: TextStyle(fontSize: 11.5, color: AppColors.slate),
              ),
            ),
        ],
      ),
    );
  }

  // ---- small building blocks ----

  Widget _softCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderSubtle),
    ),
    child: child,
  );

  Widget _infoBox({
    required IconData icon,
    required Color color,
    required Color bg,
    required String text,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderSubtle),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.5, color: color),
          ),
        ),
      ],
    ),
  );

  Widget _statusBanner({
    required String emoji,
    required Color bg,
    required Color border,
    required Color titleColor,
    required String title,
    required String body,
    String? feedback,
    String feedbackLabel = 'Feedback',
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: TextStyle(fontSize: 12.5, color: titleColor),
              ),
              if ((feedback ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$feedbackLabel: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          fontSize: 12.5,
                        ),
                      ),
                      TextSpan(
                        text: feedback,
                        style: TextStyle(color: titleColor, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
