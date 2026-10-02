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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _startLearning() {
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _browseCatalog() {
    if (!mounted) return;
    context.go(AppRoutes.catalog);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final headerH = media.size.height * 0.42;

    // Onboarding dikunci ke tampilan light/brand (best practice layar pra-login)
    // walau device dalam dark mode — header pastel + kanvas putih + tinta gelap.
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          // Continuous gradient header, windowed + translated by scroll so the
          // colour flows as one smooth gradasi while moving with the swipe.
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, _) {
              final maxIndex = _slides.length - 1;
              final page = _pageController.hasClients
                  ? (_pageController.page ?? _pageIndex.toDouble())
                  : _pageIndex.toDouble();
              final frac = maxIndex > 0
                  ? (page / maxIndex).clamp(0.0, 1.0)
                  : 0.0;

              return Positioned(
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
              );
            },
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
              Text(
                'Bass Training',
                style: TextStyle(
                  fontFamily: _kFont,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.paperBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              final active = _pageIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.only(right: i == _slides.length - 1 ? 0 : 6),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.brandPrimary
                      : AppColors.paperBorder,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('browse-catalog-button'),
                    onPressed: _browseCatalog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandPrimary,
                      side: BorderSide(
                        color: AppColors.brandPrimary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Telusuri',
                      style: TextStyle(
                        fontFamily: _kFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    key: const ValueKey('start-learning-button'),
                    onPressed: _startLearning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Mulai Belajar',
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: _kFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
    final compact = media.size.height < 700;
    final illoH = media.size.height * (compact ? 0.24 : 0.31);
    final artwork = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: SizedBox(
        height: illoH,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: floatAnimation,
          builder: (context, child) {
            final bob = (floatAnimation.value - 0.5) * 14;
            return Transform.translate(offset: Offset(0, bob), child: child);
          },
          child: RepaintBoundary(
            child: SvgPicture.asset(
              slide.asset,
              fit: BoxFit.contain,
              semanticsLabel: slide.title,
            ),
          ),
        ),
      ),
    );
    final copy = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: _IntroText(slide: slide),
    );

    return Padding(
      padding: EdgeInsets.only(top: topInset + 40, bottom: compact ? 128 : 142),
      child: compact
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  artwork,
                  const SizedBox(height: 20),
                  copy,
                  const SizedBox(height: 16),
                ],
              ),
            )
          : Column(
              children: [
                const Spacer(flex: 5),
                artwork,
                const SizedBox(height: 32),
                copy,
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
          style: TextStyle(
            fontFamily: _kFont,
            fontSize: 27,
            height: 1.18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          slide.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: _kFont,
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w500,
            color: AppColors.inkSoft,
          ),
        ),
      ],
    );
  }
}
