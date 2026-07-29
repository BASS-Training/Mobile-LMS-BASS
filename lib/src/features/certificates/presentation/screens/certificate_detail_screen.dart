import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/certificates/domain/entities/certificate_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detail sertifikat NYATA. Merender file PDF sertifikat asli dari server
/// (template bergambar yang dibuat di web) secara inline — persis seperti
/// pratinjau di halaman verifikasi web — bukan kartu gambar sendiri. Ada aksi
/// unduh & verifikasi yang benar-benar bekerja, plus ketuk untuk layar penuh.
class CertificateDetailScreen extends StatelessWidget {
  final CertificateEntity certificate;

  const CertificateDetailScreen({super.key, required this.certificate});

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

  String get _issueDate {
    final d = certificate.issuedAt;
    if (d == null) return '-';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final holderName = context.select<AuthBloc, String>((bloc) {
      final state = bloc.state;
      if (state is AuthSuccess) return state.user.name;
      return 'Peserta';
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Sertifikat'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: _CertificatePreview(
                pdfUrl: certificate.pdfUrl,
                downloadUrl: certificate.downloadUrl,
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              delayMs: 80,
              child: _ActionButtons(
                downloadUrl: certificate.downloadUrl,
                verifyUrl: certificate.verifyUrl,
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delayMs: 140,
              child: _DetailCard(
                rows: [
                  _Detail(
                    'Pemegang Sertifikat',
                    holderName,
                    Icons.person_rounded,
                  ),
                  _Detail(
                    'Kursus',
                    certificate.courseTitle,
                    Icons.menu_book_rounded,
                  ),
                  _Detail('Tanggal Terbit', _issueDate, Icons.event_rounded),
                  _Detail(
                    'Kode Sertifikat',
                    certificate.certificateCode,
                    Icons.tag_rounded,
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

/// Bingkai pratinjau yang merender PDF sertifikat asli. Menampilkan loader saat
/// memuat dan jatuh ke keadaan "pratinjau tidak tersedia" (mirror web) bila file
/// belum ada / gagal dimuat.
class _CertificatePreview extends StatefulWidget {
  final String pdfUrl;
  final String downloadUrl;

  const _CertificatePreview({required this.pdfUrl, required this.downloadUrl});

  @override
  State<_CertificatePreview> createState() => _CertificatePreviewState();
}

class _CertificatePreviewState extends State<_CertificatePreview> {
  bool _loading = true;
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final hasUrl = widget.pdfUrl.isNotEmpty;

    if (!hasUrl || _failed) {
      return _PreviewUnavailable(url: widget.downloadUrl);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.md,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: SfPdfViewer.network(
                  widget.pdfUrl,
                  canShowScrollHead: false,
                  canShowPaginationDialog: false,
                  enableDoubleTapZooming: true,
                  onDocumentLoaded: (_) {
                    if (mounted) setState(() => _loading = false);
                  },
                  onDocumentLoadFailed: (_) {
                    if (mounted) {
                      setState(() {
                        _loading = false;
                        _failed = true;
                      });
                    }
                  },
                ),
              ),
              if (_loading)
                Positioned.fill(
                  child: Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Bilah bawah: tombol perbesar (layar penuh).
          InkWell(
            onTap: _loading
                ? null
                : () => _openFullScreen(context, widget.pdfUrl),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderSubtle),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fullscreen_rounded,
                    size: 18,
                    color: AppColors.brandText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Perbesar sertifikat',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullScreenCertificate(pdfUrl: url),
      ),
    );
  }
}

/// Keadaan pengganti bila PDF tidak bisa dirender (mirror "Preview Unavailable"
/// di web) — tetap menyediakan tombol buka/unduh.
class _PreviewUnavailable extends StatelessWidget {
  final String url;

  const _PreviewUnavailable({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.sm,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 34,
              color: AppColors.brandText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pratinjau belum tersedia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sertifikat belum bisa ditampilkan di sini. Anda masih dapat '
            'membuka atau mengunduhnya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openExternal(context, url),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Buka di Browser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Penampil sertifikat layar penuh (PDF asli) dengan latar gelap.
class _FullScreenCertificate extends StatelessWidget {
  final String pdfUrl;

  const _FullScreenCertificate({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sertifikat'),
      ),
      body: SfPdfViewer.network(pdfUrl, enableDoubleTapZooming: true),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String downloadUrl;
  final String verifyUrl;

  const _ActionButtons({required this.downloadUrl, required this.verifyUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _openExternal(context, downloadUrl),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text('Unduh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _openExternal(context, verifyUrl),
              icon: const Icon(Icons.verified_user_rounded, size: 18),
              label: const Text('Verifikasi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandText,
                side: const BorderSide(
                  color: AppColors.brandPrimary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Membuka [url] di aplikasi eksternal (browser). Dipakai bersama beberapa
/// widget di layar ini.
Future<void> _openExternal(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final uri = Uri.tryParse(url);
  if (uri == null || url.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Tautan tidak tersedia.')),
    );
    return;
  }
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Tidak dapat membuka tautan.')),
    );
  }
}

class _Detail {
  final String label;
  final String value;
  final IconData icon;

  const _Detail(this.label, this.value, this.icon);
}

class _DetailCard extends StatelessWidget {
  final List<_Detail> rows;

  const _DetailCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sertifikat Terverifikasi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 22,
                thickness: 1,
                color: AppColors.borderSubtle,
              ),
            _DetailRow(detail: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final _Detail detail;

  const _DetailRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.brandPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(detail.icon, size: 17, color: AppColors.brandText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail.value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
