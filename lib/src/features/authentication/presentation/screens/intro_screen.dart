import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Onboarding uses Poppins (geometric-rounded sans) for a friendlier, more
/// polished feel that matches the reference designs.
const String _kFont = 'Poppins';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _floatController;
  int _pageIndex = 0;
  double _page = 0;

  // One continuous warm gradient spans all pages. Swiping slides a window
  // across it, so transitions are always a smooth gradasi (no hard seam) while
  // still clearly moving. Kept soft/pastel so the red figures stay readable.
  static const List<Color> _washColors = [
    Color(0xFFFFCDBE), // coral  (page 1)
    Color(0xFFFFE0C0), // amber  (page 2)
    Color(0xFFFFCBC8), // rose   (page 3)
  ];

  static const List<_IntroSlide> _slides = [
    _IntroSlide(
      title: 'Ribuan Kelas\ndalam Genggaman',
      description:
          'Jelajahi beragam kursus — dari bisnis, sains, hingga seni — yang tersusun rapi dari dasar sampai mahir. Pilih topikmu, kami siapkan jalurnya.',
      asset: 'assets/illustrations/onboard_learning.svg',
    ),
    _IntroSlide(
      title: 'Pahami, Bukan\nSekadar Hafal',
      description:
          'Setiap kelas dilengkapi kuis interaktif dan esai reflektif, memastikan kamu benar-benar menguasai materi sebelum lanjut.',
      asset: 'assets/illustrations/onboard_quiz.svg',
    ),
    _IntroSlide(
      title: 'Pantau Progres,\nRaih Sertifikat',
      description:
          'Lihat perkembangan belajarmu secara langsung dan dapatkan sertifikat resmi setiap kali menuntaskan sebuah kelas.',
      asset: 'assets/illustrations/onboard_certificate.svg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _finishIntro() {
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _next() {
    if (_pageIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishIntro();
    }
  }

  bool get _isLast => _pageIndex == _slides.length - 1;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final headerH = media.size.height * 0.42;
    final maxIndex = _slides.length - 1;
    // 0..1 scroll fraction → how far the gradient window has travelled.
    final frac = maxIndex > 0 ? (_page / maxIndex).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Continuous gradient header, windowed + translated by scroll so the
          // colour flows as one smooth gradasi while moving with the swipe.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HeroCurveClipper(),
              child: SizedBox(
                height: headerH,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 0,
                      left: -frac * 2 * w,
                      width: 3 * w,
                      height: headerH,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: _washColors,
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Pages: illustration + copy only (transparent, so the header shows).
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _pageIndex = i),
            itemBuilder: (context, index) => _IntroPage(
              slide: _slides[index],
              floatAnimation: _floatController,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(bottom: false, child: _buildTopBar()),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, child: _buildBottomControls()),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.brandGradient,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Bass Training',
                style: TextStyle(
                  fontFamily: _kFont,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Spacer(),
          AnimatedOpacity(
            opacity: _isLast ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              onPressed: _isLast ? null : _finishIntro,
              child: const Text(
                'Lewati',
                style: TextStyle(
                  fontFamily: _kFont,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 8, 30, 28),
      child: Row(
        children: [
          // Page dots, left-aligned for an airy, reference-clean footer.
          Row(
            children: List.generate(_slides.length, (i) {
              final active = _pageIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 6),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.brandPrimary
                      : AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
          const Spacer(),
          // A small circular "next" that morphs into a wide CTA on the last slide.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: _isLast
                ? SizedBox(
                    key: const ValueKey('cta'),
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mulai Belajar',
                            style: TextStyle(
                              fontFamily: _kFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.rocket_launch_rounded, size: 19),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('next'),
                    width: 56,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, size: 22),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _IntroSlide {
  final String title;
  final String description;

  /// Brand-recolored unDraw illustration (flat-vector SVG) for this slide.
  final String asset;

  const _IntroSlide({
    required this.title,
    required this.description,
    required this.asset,
  });
}

/// One page's foreground: the floating illustration and the copy, both pushed
/// lower and centered, over the shared continuous gradient header behind.
class _IntroPage extends StatelessWidget {
  final _IntroSlide slide;
  final Animation<double> floatAnimation;

  const _IntroPage({required this.slide, required this.floatAnimation});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final illoH = media.size.height * 0.31;
    // Spacers (5:4) bias the block slightly low to fill the bottom space, while
    // the fixed 32px gap guarantees the illustration and copy never collide.
    return Padding(
      padding: EdgeInsets.only(top: topInset + 40, bottom: 112),
      child: Column(
        children: [
          const Spacer(flex: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: SizedBox(
              height: illoH,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: floatAnimation,
                builder: (context, child) {
                  final bob = (floatAnimation.value - 0.5) * 14;
                  return Transform.translate(
                    offset: Offset(0, bob),
                    child: child,
                  );
                },
                child: SvgPicture.asset(
                  slide.asset,
                  fit: BoxFit.contain,
                  semanticsLabel: slide.title,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: _IntroText(slide: slide),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

/// Soft, slightly asymmetric organic curve for the header's bottom edge.
class _HeroCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..lineTo(0, h - 52)
      ..cubicTo(w * 0.25, h - 16, w * 0.60, h - 80, w, h - 44)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _HeroCurveClipper oldClipper) => false;
}

class _IntroText extends StatelessWidget {
  final _IntroSlide slide;

  const _IntroText({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: _kFont,
            fontSize: 27,
            height: 1.18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          slide.description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: _kFont,
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
