import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  final List<_IntroSlide> _slides = const [
    _IntroSlide(
      title: 'Belajar bass dengan alur yang jelas',
      description:
          'Materi, video, quiz, dan essay disusun bertahap supaya proses belajar terasa ringan dan terarah.',
      accent: AppColors.red,
      icon: Icons.library_music_outlined,
    ),
    _IntroSlide(
      title: 'Quiz dan essay tersimpan di server',
      description:
          'Akun, hasil belajar, dan progress memakai satu database Laravel supaya web dan mobile tetap sama.',
      accent: AppColors.tomato,
      icon: Icons.storage_outlined,
    ),
    _IntroSlide(
      title: 'Masuk cepat dan lanjut belajar',
      description:
          'Setelah melihat pengantar singkat, kamu bisa masuk dan langsung melanjutkan kelas yang sudah tersedia.',
      accent: AppColors.burgundy,
      icon: Icons.rocket_launch_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishIntro() async {
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _nextPage() {
    if (_pageIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishIntro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7F5), Color(0xFFFFFFFF), Color(0xFFFFEAEA)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -60,
                right: -40,
                child: _DecorBlob(
                  color: AppColors.red.withValues(alpha: 0.10),
                  size: 180,
                ),
              ),
              Positioned(
                bottom: -50,
                left: -30,
                child: _DecorBlob(
                  color: AppColors.tomato.withValues(alpha: 0.08),
                  size: 140,
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _finishIntro,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.stone,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(
                            _slides.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _pageIndex == index ? 18 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _pageIndex == index
                                    ? AppColors.red
                                    : AppColors.pearl,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 64),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (value) {
                        setState(() {
                          _pageIndex = value;
                        });
                      },
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                        child: _IntroSlideView(slide: _slides[index]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _finishIntro,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              foregroundColor: AppColors.red,
                              side: const BorderSide(
                                color: AppColors.red,
                                width: 1.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Langsung Masuk',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: AppColors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _pageIndex == _slides.length - 1
                                  ? 'Mulai'
                                  : 'Next',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroSlide {
  final String title;
  final String description;
  final Color accent;
  final IconData icon;

  const _IntroSlide({
    required this.title,
    required this.description,
    required this.accent,
    required this.icon,
  });
}

class _IntroSlideView extends StatelessWidget {
  final _IntroSlide slide;

  const _IntroSlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            slide.accent.withValues(alpha: 0.20),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: slide.accent.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: slide.accent,
                        borderRadius: BorderRadius.circular(44),
                      ),
                      child: Icon(slide.icon, size: 76, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 27,
                height: 1.12,
                fontWeight: FontWeight.w900,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              slide.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: AppColors.stone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _DecorBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
