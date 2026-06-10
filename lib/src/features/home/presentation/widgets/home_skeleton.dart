import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/widgets/shimmer.dart';

/// Skeleton placeholder shown while the home content loads. Mirrors the real
/// layout (hero, summary, quick actions, course rail) so the transition to
/// loaded content feels seamless instead of a blank spinner.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppMeasures.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Continue-learning hero.
            const ShimmerBox(height: 168, radius: 24),
            const SizedBox(height: 16),
            // Summary card.
            const ShimmerBox(height: 150, radius: 22),
            const SizedBox(height: 18),
            // Quick actions row.
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
                    child: const ShimmerBox(height: 56, radius: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            // Section header.
            const ShimmerBox(width: 150, height: 18, radius: 8),
            const SizedBox(height: 14),
            // Course rail.
            SizedBox(
              height: 190,
              child: Row(
                children: const [
                  ShimmerBox(width: 160, height: 190, radius: 20),
                  SizedBox(width: 14),
                  ShimmerBox(width: 160, height: 190, radius: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
