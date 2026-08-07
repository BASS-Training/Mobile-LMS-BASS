import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/discussions/domain/entities/discussion_feed_item.dart';
import 'package:lms_mobile_app/src/features/discussions/domain/entities/discussion_structure.dart';
import 'package:lms_mobile_app/src/features/discussions/presentation/cubit/discussion_feed_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/discussion/discussion_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

enum _ForumSort { newest, oldest }

extension on _ForumSort {
  String get label => this == _ForumSort.newest ? 'Terbaru' : 'Terlama';
}

/// Forum diskusi satu kelas (ala "Forum Diskusi Kelas" di web): semua diskusi
/// kelas ini dalam satu daftar, dengan pencarian, filter per-modul (konten), dan
/// urutan Terbaru/Terlama. Default: tampilkan semua.
class DiscussionCourseForumScreen extends StatefulWidget {
  final DiscussionCourseGroup group;

  const DiscussionCourseForumScreen({super.key, required this.group});

  @override
  State<DiscussionCourseForumScreen> createState() =>
      _DiscussionCourseForumScreenState();
}

class _DiscussionCourseForumScreenState
    extends State<DiscussionCourseForumScreen> {
  final _feedCubit = ServiceLocator().locator<DiscussionFeedCubit>();
  final _searchController = TextEditingController();

  String _query = '';

  /// Filter modul aktif (contentId); null = semua modul.
  String? _moduleFilter;
  _ForumSort _sort = _ForumSort.newest;

  @override
  void initState() {
    super.initState();
    _feedCubit.load(courseId: widget.group.courseId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _feedCubit.close();
    super.dispose();
  }

  List<DiscussionFeedItem> _visible(List<DiscussionFeedItem> items) {
    final q = _query.trim().toLowerCase();
    final out = items.where((i) {
      if (_moduleFilter != null && i.contentId != _moduleFilter) return false;
      if (q.isEmpty) return true;
      return i.title.toLowerCase().contains(q) ||
          i.snippet.toLowerCase().contains(q) ||
          i.authorName.toLowerCase().contains(q);
    }).toList();
    out.sort((a, b) {
      final da = a.lastActivityAt;
      final db = b.lastActivityAt;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return _sort == _ForumSort.newest ? db.compareTo(da) : da.compareTo(db);
    });
    return out;
  }

  /// Modul (konten) yang punya diskusi — dipakai untuk dropdown filter.
  List<({String id, String title})> _modules(List<DiscussionFeedItem> items) {
    final seen = <String>{};
    final list = <({String id, String title})>[];
    for (final i in items) {
      if (i.contentId.isEmpty || !seen.add(i.contentId)) continue;
      list.add((
        id: i.contentId,
        title: i.lessonTitle.isEmpty ? 'Materi' : i.lessonTitle,
      ));
    }
    return list;
  }

  Future<void> _openThread(DiscussionFeedItem item) async {
    await context.push(
      AppRoutes.discussionThread,
      extra: {
        'contentId': item.contentId,
        'lessonTitle': item.lessonTitle,
        'courseTitle': item.courseTitle,
        'highlightDiscussionId': item.id,
      },
    );
    if (mounted) _feedCubit.load(courseId: widget.group.courseId);
  }

  Future<void> _openCompose() async {
    if (widget.group.lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada materi untuk didiskusikan.')),
      );
      return;
    }
    final posted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CourseComposeSheet(group: widget.group),
    );
    if (posted == true && mounted) {
      _feedCubit.load(courseId: widget.group.courseId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diskusi berhasil dibuat.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.group.courseTitle.isEmpty
        ? 'Diskusi'
        : widget.group.courseTitle;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandAppBar(
        title: title,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => _feedCubit.load(courseId: widget.group.courseId),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCompose,
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text(
          'Buat Diskusi',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocBuilder<DiscussionFeedCubit, DiscussionFeedState>(
        bloc: _feedCubit,
        builder: (context, state) {
          if (state.status == DiscussionFeedStatus.loading ||
              state.status == DiscussionFeedStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }
          if (state.status == DiscussionFeedStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat diskusi',
              message: state.error ?? 'Terjadi kesalahan.',
              actionLabel: 'Coba lagi',
              onAction: () => _feedCubit.load(courseId: widget.group.courseId),
            );
          }

          // Amankan ke kelas ini di sisi klien juga: bila backend belum
          // mendukung filter `?course=`, feed bisa berisi kelas lain.
          final scoped = state.items
              .where(
                (i) =>
                    i.courseId.isEmpty || i.courseId == widget.group.courseId,
              )
              .toList();
          final modules = _modules(scoped);
          final visible = _visible(scoped);

          return Column(
            children: [
              _Controls(
                searchController: _searchController,
                onSearch: (v) => setState(() => _query = v),
                onClearSearch: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                modules: modules,
                moduleFilter: _moduleFilter,
                onModuleChanged: (v) => setState(() => _moduleFilter = v),
                sort: _sort,
                onSortChanged: (s) => setState(() => _sort = s),
                total: visible.length,
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brandPrimary,
                  onRefresh: () =>
                      _feedCubit.load(courseId: widget.group.courseId),
                  child: scoped.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 40),
                            AppEmptyState(
                              illustration:
                                  'assets/illustrations/empty_discussion.svg',
                              icon: Icons.forum_outlined,
                              title: 'Belum ada diskusi',
                              message:
                                  'Jadilah yang pertama. Ketuk "Buat Diskusi".',
                            ),
                          ],
                        )
                      : visible.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 60),
                            _Empty(
                              icon: Icons.search_off_rounded,
                              title: 'Tidak ada yang cocok',
                              message: 'Coba ubah pencarian atau filter modul.',
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                          itemCount: visible.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) => _FeedCard(
                            item: visible[i],
                            onTap: () => _openThread(visible[i]),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bar kontrol menetap: pencarian + dropdown modul + urutan.
class _Controls extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearSearch;
  final List<({String id, String title})> modules;
  final String? moduleFilter;
  final ValueChanged<String?> onModuleChanged;
  final _ForumSort sort;
  final ValueChanged<_ForumSort> onSortChanged;
  final int total;

  const _Controls({
    required this.searchController,
    required this.onSearch,
    required this.onClearSearch,
    required this.modules,
    required this.moduleFilter,
    required this.onModuleChanged,
    required this.sort,
    required this.onSortChanged,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearch,
            textInputAction: TextInputAction.search,
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari judul diskusi...',
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceMuted,
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClearSearch,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _moduleDropdown()),
              const SizedBox(width: 8),
              _sortButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moduleDropdown() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: moduleFilter,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          borderRadius: BorderRadius.circular(12),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Semua modul'),
            ),
            for (final m in modules)
              DropdownMenuItem<String?>(
                value: m.id,
                child: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onModuleChanged,
        ),
      ),
    );
  }

  Widget _sortButton(BuildContext context) {
    return PopupMenuButton<_ForumSort>(
      initialValue: sort,
      onSelected: onSortChanged,
      itemBuilder: (_) => [
        for (final s in _ForumSort.values)
          PopupMenuItem(value: s, child: Text(s.label)),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort_rounded, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              sort.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu kartu diskusi di feed — ala forum: penulis, waktu, judul, cuplikan,
/// konteks modul, jumlah balasan.
class _FeedCard extends StatelessWidget {
  final DiscussionFeedItem item;
  final VoidCallback onTap;

  const _FeedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initial = item.authorName.trim().isNotEmpty
        ? item.authorName.trim()[0].toUpperCase()
        : '?';
    final time = _timeAgo(item.lastActivityAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.brandSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: AppColors.textPrimary,
                ),
              ),
              if (item.snippet.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item.lessonTitle.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 13,
                              color: AppColors.brandText,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                item.lessonTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 15,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.repliesCount}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
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

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _Empty({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppColors.textTertiary.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hr lalu';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} mgg lalu';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} bln lalu';
  return '${(diff.inDays / 365).floor()} thn lalu';
}

/// Bottom sheet "Buat Diskusi" dalam satu kelas: pilih modul, tulis judul + isi.
class _CourseComposeSheet extends StatefulWidget {
  final DiscussionCourseGroup group;

  const _CourseComposeSheet({required this.group});

  @override
  State<_CourseComposeSheet> createState() => _CourseComposeSheetState();
}

class _CourseComposeSheetState extends State<_CourseComposeSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _contentId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _contentId = widget.group.lessons.isNotEmpty
        ? widget.group.lessons.first.contentId
        : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final contentId = _contentId;
    if (contentId == null || contentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih modul terlebih dahulu.')),
      );
      return;
    }
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi diskusi wajib diisi.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final cubit = ServiceLocator().locator<DiscussionCubit>(param1: contentId);
    final ok = await cubit.postTopic(title: title, body: body);
    await cubit.close();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat diskusi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Buat Diskusi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.group.courseTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              _label('Modul'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _contentId,
                    hint: const Text('Pilih modul'),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      for (final l in widget.group.lessons)
                        DropdownMenuItem(
                          value: l.contentId,
                          child: Text(
                            l.lessonTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _submitting
                        ? null
                        : (v) => setState(() => _contentId = v),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _label('Judul'),
              TextField(
                controller: _titleController,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration('Judul diskusi'),
              ),
              const SizedBox(height: 12),
              _label('Isi'),
              TextField(
                controller: _bodyController,
                enabled: !_submitting,
                minLines: 3,
                maxLines: 6,
                decoration: _fieldDecoration(
                  'Tulis pertanyaan atau topik diskusi...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_submitting ? 'Mengirim...' : 'Kirim'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    ),
  );

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: AppColors.surfaceMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
