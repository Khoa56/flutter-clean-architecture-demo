import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post.dart';
import '../../domain/failures/app_failure.dart';
import '../cubit/post_detail_cubit.dart';
import '../cubit/posts_cubit.dart';
import '../widgets/failure_panel.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';

final class PostsPage extends StatefulWidget {
  const PostsPage({
    required this.createDetailCubit,
    this.useFixture = false,
    super.key,
  });
  final PostDetailCubit Function() createDetailCubit;
  final bool useFixture;

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() {
    _search.clear();
    context.read<PostsCubit>().resetFilters();
  }

  void _open(Post post) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => widget.createDetailCubit()..load(post.id),
          child: PostDetailPage(postId: post.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_stories_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          const Text('góc đọc', style: TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Tải lại bài viết',
          onPressed: () => context.read<PostsCubit>().load(),
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: BlocBuilder<PostsCubit, PostsState>(
            builder: (context, state) => RefreshIndicator(
              onRefresh: context.read<PostsCubit>().load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ĐỌC · KHÁM PHÁ · SUY NGẪM',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Một chút đọc,\nthêm nhiều ý tưởng.',
                            style: TextStyle(
                              fontSize: MediaQuery.sizeOf(context).width < 400
                                  ? 32
                                  : 40,
                              height: 1.15,
                              letterSpacing: -1.3,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Những bài viết nhỏ cho một khoảng nghỉ trong ngày.',
                            style: TextStyle(
                              height: 1.5,
                              color: Color(0xFF617068),
                            ),
                          ),
                          if (widget.useFixture) ...[
                            const SizedBox(height: 12),
                            const Chip(
                              avatar: Icon(Icons.science_outlined, size: 18),
                              label: Text('Đang dùng dữ liệu mẫu'),
                            ),
                          ],
                          const SizedBox(height: 26),
                          TextField(
                            controller: _search,
                            onChanged: context.read<PostsCubit>().search,
                            decoration: InputDecoration(
                              hintText: 'Tìm trong tiêu đề hoặc nội dung...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: state.query.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Xóa tìm kiếm',
                                      onPressed: () {
                                        _search.clear();
                                        context.read<PostsCubit>().search('');
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(
                                width: 205,
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  // Key làm mới selection khi reset; null = tất cả tác giả.
                                  key: ValueKey(
                                    'author-${state.query.authorId}',
                                  ),
                                  initialValue: state.query.authorId ?? 0,
                                  decoration: const InputDecoration(
                                    labelText: 'Tác giả',
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: 0,
                                      child: Text('Tất cả tác giả'),
                                    ),
                                    for (final id in state.authorIds)
                                      DropdownMenuItem(
                                        value: id,
                                        child: Text('Tác giả $id'),
                                      ),
                                  ],
                                  onChanged: (id) => context
                                      .read<PostsCubit>()
                                      .selectAuthor(id == 0 ? null : id),
                                ),
                              ),
                              SizedBox(
                                width: 205,
                                child: DropdownButtonFormField<bool>(
                                  isExpanded: true,
                                  key: ValueKey(
                                    'sort-${state.query.newestFirst}',
                                  ),
                                  initialValue: state.query.newestFirst,
                                  decoration: const InputDecoration(
                                    labelText: 'Thứ tự bài viết',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: true,
                                      child: Text('ID giảm dần'),
                                    ),
                                    DropdownMenuItem(
                                      value: false,
                                      child: Text('ID tăng dần'),
                                    ),
                                  ],
                                  onChanged: (value) => context
                                      .read<PostsCubit>()
                                      .setNewestFirst(value ?? true),
                                ),
                              ),
                              TextButton(
                                onPressed: _reset,
                                child: const Text('Đặt lại bộ lọc'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Dành cho bạn',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${state.visiblePosts.length} bài viết',
                                style: const TextStyle(
                                  color: Color(0xFF617068),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ..._content(state),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Text(
                        'Một khoảng nghỉ, một ý tưởng mới.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF758078),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  List<Widget> _content(PostsState state) {
    if (state.status == LoadStatus.initial ||
        state.status == LoadStatus.loading) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tải bài viết...'),
              ],
            ),
          ),
        ),
      ];
    }
    if (state.status == LoadStatus.failure) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: FailurePanel(
            error: state.error ?? const AppFailure(FailureKind.unknown),
            onRetry: () => context.read<PostsCubit>().load(),
          ),
        ),
      ];
    }
    if (state.visiblePosts.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded, size: 44),
                  const SizedBox(height: 12),
                  Text(
                    state.allPosts.isEmpty
                        ? 'Chưa có bài viết nào.'
                        : 'Không tìm thấy bài viết phù hợp.',
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Đặt lại bộ lọc'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final columns = width >= 1000
                ? 3
                : width >= 660
                ? 2
                : 1;
            // Tăng chiều cao khi hệ thống dùng cỡ chữ lớn.
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 280 * textScale.clamp(1, 3),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final post = state.visiblePosts[index];
                return PostCard(post: post, onTap: () => _open(post));
              }, childCount: state.visiblePosts.length),
            );
          },
        ),
      ),
    ];
  }
}
