import 'package:flutter/material.dart';

/// Shared header for the auth screens: a small pill badge, a bold title, and a
/// supporting subtitle — white content on the brand gradient.
///
/// When [glow] is true the badge pulses with a neon halo (used on the login
/// screen); otherwise it renders as a plain translucent pill.
class AuthHeader extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final bool glow;

  const AuthHeader({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        glow ? _NeonBadge(text: badge) : _PlainBadge(text: badge),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Plain translucent badge pill.
class _PlainBadge extends StatelessWidget {
  final String text;

  const _PlainBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(text, style: _labelStyle),
    );
  }
}

/// Badge pill whose text and border "breathe" with a neon glow.
class _NeonBadge extends StatefulWidget {
  final String text;

  const _NeonBadge({required this.text});

  @override
  State<_NeonBadge> createState() => _NeonBadgeState();
}

class _NeonBadgeState extends State<_NeonBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Layered white shadows that read as a glowing neon halo. [g] (0..1) scales
  /// the intensity so the glow can "breathe".
  List<Shadow> _neonShadows(double g) {
    return [
      Shadow(color: Colors.white.withValues(alpha: 0.95 * g), blurRadius: 4 + 5 * g),
      Shadow(color: Colors.white.withValues(alpha: 0.80 * g), blurRadius: 9 + 9 * g),
      Shadow(
        color: const Color(0xFFFFD9D9).withValues(alpha: 0.70 * g),
        blurRadius: 16 + 14 * g,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final g = 0.55 + 0.45 * _controller.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30 + 0.40 * g),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.30 * g),
                blurRadius: 14 * g,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: _labelStyle.copyWith(shadows: _neonShadows(g)),
          ),
        );
      },
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  color: Colors.white,
  fontSize: 10,
  fontWeight: FontWeight.w800,
  letterSpacing: 1.2,
);
