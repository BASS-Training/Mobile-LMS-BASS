import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/achievement_artwork.dart';
import 'package:lms_mobile_app/src/shared/widgets/learning_artwork.dart';
import 'package:lms_mobile_app/src/shared/widgets/quiz_artwork.dart';

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

  static const List<_IntroSlide> _slides = [
    _IntroSlide(
      title: 'Ribuan Kelas\ndalam Genggaman',
      description:
          'Jelajahi beragam kursus — dari bisnis, sains, hingga seni — yang tersusun rapi dari dasar sampai mahir. Pilih topikmu, kami siapkan jalurnya.',
      art: _IntroArt.learning,
    ),
    _IntroSlide(
      title: 'Pahami, Bukan\nSekadar Hafal',
      description:
          'Setiap kelas dilengkapi kuis interaktif dan esai reflektif, memastikan kamu benar-benar menguasai materi sebelum lanjut.',
      art: _IntroArt.quiz,
    ),
    _IntroSlide(
      title: 'Pantau Progres,\nRaih Sertifikat',
      description:
          'Lihat perkembangan belajarmu secara langsung dan dapatkan sertifikat resmi setiap kali menuntaskan sebuah kelas.',
      art: _IntroArt.achievement,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemBuilder: (context, index) {
                  // Parallax: scale pages by their distance from center.
                  final delta = (_page - index).abs().clamp(0.0, 1.0);
                  final scale = 1 - delta * 0.12;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Transform.scale(
                            scale: scale,
                            child: _IntroHero(
                              slide: _slides[index],
                              floatAnimation: _floatController,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Opacity(
                          opacity: (1 - delta).clamp(0.0, 1.0),
                          child: _IntroText(slide: _slides[index]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
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
                  fontWeight: FontWeight.w800,
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
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              final active = _pageIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
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
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Row(
                  key: ValueKey<bool>(_isLast),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLast ? 'Mulai Belajar' : 'Lanjut',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isLast
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _IntroArt { learning, quiz, achievement }

class _IntroSlide {
  final String title;
  final String description;
  final _IntroArt art;

  const _IntroSlide({
    required this.title,
    required this.description,
    required this.art,
  });
}

/// Animated brand-gradient hero panel with floating decorative shapes.
class _IntroHero extends StatelessWidget {
  final _IntroSlide slide;
  final Animation<double> floatAnimation;

  const _IntroHero({required this.slide, required this.floatAnimation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppShadows.brandPrimary,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: AnimatedBuilder(
          animation: floatAnimation,
          builder: (context, _) {
            final t = floatAnimation.value; // 0..1
            final bob = (t - 0.5) * 18; // gentle vertical bob
            return Stack(
              children: [
                // Decorative floating circles
                Positioned(top: 30 + bob, right: -30, child: _glow(120, 0.12)),
                Positioned(
                  bottom: -40 - bob,
                  left: -30,
                  child: _glow(140, 0.10),
                ),
                Positioned(top: 60 - bob, left: 28, child: _glow(16, 0.5)),
                Positioned(bottom: 70 + bob, right: 34, child: _glow(10, 0.4)),
                // Centerpiece
                Center(
                  child: Transform.translate(
                    offset: Offset(0, bob * 0.6),
                    child: _artworkFor(slide.art),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _artworkFor(_IntroArt art) {
    switch (art) {
      case _IntroArt.learning:
        return const LearningArtwork(height: 240);
      case _IntroArt.quiz:
        return const QuizArtwork(height: 240);
      case _IntroArt.achievement:
        return const AchievementArtwork(height: 240);
    }
  }

  Widget _glow(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
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
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          slide.description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
