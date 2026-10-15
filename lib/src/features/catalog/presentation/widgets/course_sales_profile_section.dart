import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/course_sales_profile.dart';

class CourseSalesProfileSection extends StatelessWidget {
  const CourseSalesProfileSection({super.key, required this.profile});

  final CourseSalesProfile? profile;

  Widget _textSection(String title, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(value.trim()),
        ],
      ),
    );
  }

  Future<void> _openPromo(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // The same message covers missing apps and launcher failures.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video promosi belum dapat dibuka.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = profile;
    if (p == null) return const SizedBox.shrink();
    final badges = [
      p.levelLabel,
      p.durationLabel,
      p.language,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
    final promo = Uri.tryParse(p.promoVideoUrl ?? '');
    final hasPromo =
        promo != null &&
        (promo.scheme == 'https' || promo.scheme == 'http') &&
        promo.host.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badges.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges
                  .map((label) => Chip(label: Text(label)))
                  .toList(),
            ),
          ),
        _textSection('Manfaat yang Anda dapatkan', p.learningBenefits),
        _textSection('Cocok untuk siapa?', p.targetAudience),
        _textSection('Persyaratan', p.requirements),
        if (hasPromo)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: OutlinedButton.icon(
              onPressed: () => _openPromo(context, promo),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Tonton video promosi'),
            ),
          ),
        if (p.faq.isNotEmpty) ...[
          const Text(
            'Pertanyaan yang sering diajukan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          for (final item in p.faq)
            ExpansionTile(
              title: Text(item.question),
              childrenPadding: const EdgeInsets.all(16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(item.answer)],
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
