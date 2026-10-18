import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/post_detail_cubit.dart';
import '../widgets/failure_panel.dart';

final class PostDetailPage extends StatelessWidget {
  const PostDetailPage({required this.postId, super.key});
  final int postId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Đọc bài viết')),
    body: SafeArea(
      child: BlocBuilder<PostDetailCubit, PostDetailState>(
        builder: (context, state) => switch (state) {
          DetailLoading() => const Center(child: CircularProgressIndicator()),
          DetailFailed(:final error) => FailurePanel(
            error: error,
            onRetry: () => context.read<PostDetailCubit>().load(postId),
          ),
          DetailReady(:final post) => SelectionArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: Text(
                            'Bài ${post.id} · ${post.readingMinutes} phút đọc',
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          post.title,
                          style: TextStyle(
                            fontSize: MediaQuery.sizeOf(context).width < 400
                                ? 30
                                : 38,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            CircleAvatar(child: Text('${post.authorId}')),
                            const SizedBox(width: 12),
                            Text(
                              'Tác giả ${post.authorId}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(),
                        ),
                        Text(
                          post.body,
                          style: const TextStyle(fontSize: 18, height: 1.9),
                        ),
                        const SizedBox(height: 32),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Về danh sách'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        },
      ),
    ),
  );
}
