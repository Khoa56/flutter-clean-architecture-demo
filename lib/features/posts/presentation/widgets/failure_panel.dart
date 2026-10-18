import 'package:flutter/material.dart';

import '../../domain/failures/app_failure.dart';

String failureMessage(AppFailure error) => switch (error.kind) {
  FailureKind.network =>
    'Không kết nối được. Kiểm tra Internet rồi thử lại nhé.',
  FailureKind.timeout => 'Kết nối mất quá lâu. Bạn có thể thử tải lại.',
  FailureKind.server => 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.',
  FailureKind.notFound => 'Bài viết này không còn tồn tại.',
  FailureKind.invalidData => 'Dữ liệu nhận về chưa đúng định dạng.',
  FailureKind.unknown => 'Đã có lỗi khi tải bài viết. Vui lòng thử lại.',
};

final class FailurePanel extends StatelessWidget {
  const FailurePanel({required this.error, required this.onRetry, super.key});
  final AppFailure error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa tải được bài viết',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(failureMessage(error), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}
