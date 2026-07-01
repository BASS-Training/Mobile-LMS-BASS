import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/quiz_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Kartu papan peringkat kuis pada halaman hasil. Menampilkan Top-5 peserta
/// (baris peserta saat ini di-highlight) + ringkasan "Peringkat Anda". Tombol
/// "Lihat Semua" membuka daftar peringkat lengkap dalam bottom sheet.
///
/// Mirror dari tampilan web (Aktifkan Leaderboard) agar konsisten lintas
/// platform, namun memakai token warna tema sehingga rapi di dark mode.
class QuizLeaderboardCard extends StatelessWidget {
  final QuizLeaderboard leaderboard;

  const QuizLeaderboardCard({super.key, required this.leaderboard});

  static const Color _gold = Color(0xFFE0A400);

  @override
  Widget build(BuildContext context) {
    if (leaderboard.entries.isEmpty) return const SizedBox.shrink();

    final top = leaderboard.entries.take(5).toList();
    final rank = leaderboard.currentUserRank;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: _gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Top 5 Leaderboard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              if (leaderboard.entries.length > top.length)
                GestureDetector(
                  onTap: () => _showAll(context),
                  child: Text(
                    'Lihat Semua →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandText,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...top.map((e) => _LeaderboardRow(entry: e)),
          if (rank != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.brandText.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Peringkat Anda: #$rank dari ${leaderboard.totalParticipants} peserta',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAll(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: _gold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Semua Peringkat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: leaderboard.entries.length,
                itemBuilder: (_, i) =>
                    _LeaderboardRow(entry: leaderboard.entries[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final QuizLeaderboardEntry entry;

  const _LeaderboardRow({required this.entry});

  Color _rankColor() {
    switch (entry.rank) {
      case 1:
        return const Color(0xFFE0A400);
      case 2:
        return const Color(0xFF9AA0A6);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.slate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlight = entry.isCurrentUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.brandText.withValues(alpha: 0.10)
            : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: highlight
            ? Border.all(color: AppColors.brandText.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _rankColor(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              highlight ? '${entry.name} (Anda)' : entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                color: highlight ? AppColors.brandText : AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.percentage.toStringAsFixed(entry.percentage % 1 == 0 ? 0 : 1)}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.brandText : AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
