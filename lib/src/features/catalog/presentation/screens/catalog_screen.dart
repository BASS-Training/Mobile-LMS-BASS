import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants/app_routes.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_shadows.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/brand_app_bar.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../widgets/catalog_course_card.dart';

class CatalogScreen extends StatefulWidget {
  final bool guestMode;

  const CatalogScreen({super.key, this.guestMode = false});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const Duration _searchDebounce = Duration(milliseconds: 400);
  static const double _loadMoreThreshold = 320;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (context.read<CatalogBloc>().state.status == CatalogStatus.initial) {
      context.read<CatalogBloc>().add(const LoadCatalogEvent());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<CatalogBloc>().add(const LoadMoreCatalogEvent());
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();

    // Parameter `q` divalidasi server minimal 2 karakter, jadi tunggu sampai
    // pengguna mengetik cukup panjang sebelum memicu request. Jika sebelumnya
    // ada query aktif, kembalikan daftar penuh agar hasil lama tidak tertinggal.
    if (trimmed.length < 2) {
      final bloc = context.read<CatalogBloc>();
      if (bloc.state.query.isNotEmpty) {
        bloc.add(const SearchCatalogEvent(''));
      }
      return;
    }

    _debounce = Timer(_searchDebounce, () {
      if (!mounted) return;
      context.read<CatalogBloc>().add(SearchCatalogEvent(trimmed));
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    final bloc = context.read<CatalogBloc>();
    if (bloc.state.query.isNotEmpty) {
      bloc.add(const SearchCatalogEvent(''));
    }
  }

  Future<void> _refresh() async {
    context.read<CatalogBloc>().add(const LoadCatalogEvent());
    await context.read<CatalogBloc>().stream.firstWhere(
      (next) => next.status != CatalogStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandAppBar(
        title: 'Katalog',
        actions: widget.guestMode
            ? [
                TextButton.icon(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.login_rounded, color: Colors.white),
                  label: const Text(
                    'Masuk',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temukan kelas berikutnya',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Jelajahi program belajar yang sesuai dengan perjalanan bass Anda.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CatalogSearchField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onClear: _clearSearch,
                    ),
                    const SizedBox(height: 14),
                    _CatalogFilters(selected: state.filter),
                  ],
                ),
              ),
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CatalogState state) {
    if (state.status == CatalogStatus.loading && state.courses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandPrimary),
      );
    }

    if (state.status == CatalogStatus.failure && state.courses.isEmpty) {
      return AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Katalog belum dapat dimuat',
        message: state.errorMessage ?? 'Silakan coba beberapa saat lagi.',
        actionLabel: 'Coba Lagi',
        onAction: () =>
            context.read<CatalogBloc>().add(const LoadCatalogEvent()),
      );
    }

    final courses = state.visibleCourses;
    if (courses.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Belum ada course',
        message: state.query.isNotEmpty
            ? 'Tidak ada course untuk pencarian "${state.query}".'
            : 'Belum ada course untuk filter yang dipilih.',
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return CatalogCourseCard(
                  course: course,
                  onTap: () => context.push(AppRoutes.catalogDetail(course.id)),
                );
              },
            ),
          ),
        ),
        _LoadMoreFooter(state: state),
      ],
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  final CatalogState state;

  const _LoadMoreFooter({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CatalogBloc>();

    if (state.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Memuat halaman berikutnya...',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null && state.status == CatalogStatus.loaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.errorMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.red, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () => bloc.add(const LoadMoreCatalogEvent()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state.hasMorePages) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Center(
          child: TextButton.icon(
            onPressed: () => bloc.add(const LoadMoreCatalogEvent()),
            icon: const Icon(Icons.expand_more_rounded, size: 18),
            label: const Text('Muat lebih banyak'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _CatalogSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _CatalogSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: AppShadows.xs,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Cari course (min. 2 karakter)',
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textTertiary,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _CatalogFilters extends StatelessWidget {
  final CatalogFilter selected;

  const _CatalogFilters({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: CatalogFilter.values.map((filter) {
        final isSelected = filter == selected;
        final label = switch (filter) {
          CatalogFilter.all => 'Semua',
          CatalogFilter.free => 'Gratis',
        };
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: filter == CatalogFilter.values.last ? 0 : 8,
            ),
            child: Material(
              color: isSelected ? AppColors.brandPrimary : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.read<CatalogBloc>().add(
                  ChangeCatalogFilterEvent(filter),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brandPrimary
                          : AppColors.borderDefault,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
