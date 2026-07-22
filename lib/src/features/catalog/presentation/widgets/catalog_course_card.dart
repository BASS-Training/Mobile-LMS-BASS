import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_accent.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

import '../../domain/entities/catalog_course_entity.dart';

/// Kartu kursus di etalase.
///
/// Perhatikan tidak ada tombol beli di mana pun: kursus berbayar hanya
/// menampilkan lencana, dan CTA-nya adalah membuka preview. Ini disengaja —
/// aplikasi tidak boleh mengarahkan pengguna ke pembayaran di luar Google Play
/// Billing (aturan anti-steering).
class CatalogCourseCard extends StatelessWidget {
  final CatalogCourseEntity course;

  /// Apakah harga boleh ditampilkan (kebijakan datang dari server).
  final bool showPrice;

  final VoidCallback onTap;

  /// Aksi "Daftar Gratis". Null bila kursus berbayar atau sudah dimiliki.
  final VoidCallback? onEnrollFree;

  final bool isEnrolling;

  const CatalogCourseCard({
    super.key,
    required this.course,
    required this.showPrice,
    required this.onTap,
    this.onEnrollFree,
    this.isEnrolling = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = CourseAccent.of(course.id);

    return PressScale(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.sm,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Cover(course: course, accent: accent),
              // Sel grid punya tinggi tetap. Isi kartu dibuat lentur (Expanded
              // + Flexible pada deskripsi) supaya judul panjang atau deskripsi
              // dua baris mengecil dengan elipsis, bukan memicu overflow.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          course.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (course.shortDescription.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Flexible(
                          child: Text(
                            course.shortDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.lessonsCount} bab',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          _PriceTag(
                            course: course,
                            showPrice: showPrice,
                            accent: accent,
                          ),
                        ],
                      ),
                      if (onEnrollFree != null) ...[
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: isEnrolling ? null : onEnrollFree,
                          style: FilledButton.styleFrom(
                            backgroundColor: accent.solid,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(38),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isEnrolling
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Daftar Gratis',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final CatalogCourseEntity course;
  final CourseAccent accent;

  const _Cover({required this.course, required this.accent});

  @override
  Widget build(BuildContext context) {
    final thumbnail = course.thumbnailUrl;

    return Stack(
      children: [
        SizedBox(
          height: 104,
          width: double.infinity,
          child: thumbnail != null && thumbnail.isNotEmpty
              ? Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  // Sampul gagal dimuat tidak boleh mematahkan kartu — jatuh ke
                  // gradien identitas kursus seperti kursus tanpa sampul.
                  errorBuilder: (_, _, _) => _GradientCover(accent: accent),
                )
              : _GradientCover(accent: accent),
        ),
        if (course.isEnrolled)
          Positioned(
            top: 8,
            left: 8,
            child: _Badge(
              icon: Icons.check_circle_rounded,
              label: 'Sudah diikuti',
              background: AppColors.success,
            ),
          ),
      ],
    );
  }
}

class _GradientCover extends StatelessWidget {
  final CourseAccent accent;

  const _GradientCover({required this.accent});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: accent.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(child: Text('📚', style: TextStyle(fontSize: 34))),
    );
  }
}

/// Lencana harga. Saat server menyembunyikan harga, kursus berbayar tampil
/// sebagai "Berbayar" saja — cukup untuk membedakan, tanpa mengajak membeli.
class _PriceTag extends StatelessWidget {
  final CatalogCourseEntity course;
  final bool showPrice;
  final CourseAccent accent;

  const _PriceTag({
    required this.course,
    required this.showPrice,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (course.isEnrolled) {
      return const SizedBox.shrink();
    }

    final isFree = course.isFree;
    final label = isFree
        ? 'Gratis'
        : (showPrice && course.priceLabel.isNotEmpty
              ? course.priceLabel
              : 'Berbayar');

    final color = isFree ? AppColors.success : accent.solid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;

  const _Badge({
    required this.icon,
    required this.label,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
