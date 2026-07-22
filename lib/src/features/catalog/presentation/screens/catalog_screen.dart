import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/shimmer.dart';

import '../../domain/entities/catalog_course_entity.dart';
import '../../domain/entities/catalog_result.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';
import '../widgets/catalog_course_card.dart';

/// Tab "Jelajahi" — etalase kursus yang dibuka untuk umum oleh admin.
///
/// Kursus GRATIS bisa langsung diikuti dari sini. Kursus berbayar hanya bisa
/// di-preview: aplikasi sengaja tidak menyediakan jalur pembelian apa pun
/// (kebijakan anti-steering Google Play), dan jalan masuk yang tersedia di
/// mobile adalah kode akses lewat "Gabung Kelas".
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CatalogCubit>(
      create: (_) => ServiceLocator().locator<CatalogCubit>()..load(),
      child: const _CatalogView(),
    );
  }
}

class _CatalogView extends StatefulWidget {
  const _CatalogView();

  @override
  State<_CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<_CatalogView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Jelajahi'),
      body: BlocConsumer<CatalogCubit, CatalogState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppMeasures.paddingLarge,
                  AppMeasures.paddingLarge,
                  AppMeasures.paddingLarge,
                  10,
                ),
                child: _SearchField(
                  controller: _searchController,
                  onChanged: context.read<CatalogCubit>().search,
                ),
              ),
              _FilterChips(
                current: state.filter,
                onChanged: context.read<CatalogCubit>().changeFilter,
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CatalogState state) {
    if (state.isInitialLoading) {
      return const _CatalogSkeleton();
    }

    if (state.status == CatalogStatus.failure && state.courses.isEmpty) {
      return AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Gagal memuat katalog',
        message:
            state.errorMessage ?? 'Periksa koneksi internetmu lalu coba lagi.',
        actionLabel: 'Coba Lagi',
        onAction: context.read<CatalogCubit>().load,
      );
    }

    if (state.isEmpty) {
      final isFiltering =
          state.query.isNotEmpty || state.filter != CatalogPriceFilter.all;

      return AppEmptyState(
        icon: isFiltering ? Icons.search_off_rounded : Icons.storefront_rounded,
        title: isFiltering
            ? 'Kursus tidak ditemukan'
            : 'Belum ada kursus di etalase',
        message: isFiltering
            ? 'Coba kata kunci lain atau ubah filternya.'
            : 'Kursus yang dibuka untuk umum akan muncul di sini.',
      );
    }

    return RefreshIndicator(
      color: AppColors.brandPrimary,
      onRefresh: context.read<CatalogCubit>().load,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppMeasures.paddingLarge,
          4,
          AppMeasures.paddingLarge,
          AppMeasures.paddingLarge,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: state.courses.length,
        itemBuilder: (context, index) {
          final course = state.courses[index];

          return CatalogCourseCard(
            course: course,
            showPrice: state.showPrice,
            isEnrolling: state.enrollingCourseId == course.id,
            onTap: () => context.push(AppRoutes.catalogDetail, extra: course),
            // Tombol hanya untuk kursus gratis yang belum diikuti. Kursus
            // berbayar sengaja tidak punya aksi apa pun selain membuka preview.
            onEnrollFree: course.isFree && !course.isEnrolled
                ? () => _enroll(context, course)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _enroll(BuildContext context, CatalogCourseEntity course) async {
    final messenger = ScaffoldMessenger.of(context);
    final courseBloc = context.read<CourseBloc>();

    final message = await context.read<CatalogCubit>().enrollFree(course.id);
    if (message == null) return;

    // Tarik ulang "Kursus Saya" supaya kursus barunya langsung terlihat di tab
    // Kursus tanpa perlu membuka ulang aplikasi.
    courseBloc.add(const RefreshCoursesEvent());

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari kursus di etalase...',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.brandText,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : null,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final CatalogPriceFilter current;
  final ValueChanged<CatalogPriceFilter> onChanged;

  const _FilterChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppMeasures.paddingLarge,
        ),
        itemCount: CatalogPriceFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = CatalogPriceFilter.values[index];
          final selected = filter == current;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.brandPrimary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? AppColors.brandPrimary
                      : AppColors.borderSubtle,
                ),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppMeasures.paddingLarge,
          4,
          AppMeasures.paddingLarge,
          AppMeasures.paddingLarge,
        ),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: 4,
        itemBuilder: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(height: 104, radius: 20),
            const SizedBox(height: 12),
            const ShimmerBox(height: 14, radius: 6),
            const SizedBox(height: 8),
            const ShimmerBox(height: 14, width: 120, radius: 6),
            const SizedBox(height: 14),
            const ShimmerBox(height: 12, width: 80, radius: 6),
          ],
        ),
      ),
    );
  }
}
