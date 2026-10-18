/// Entity thuần Dart: không biết JSON, HTTP, Flutter hay GetIt.
final class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.title,
    required this.body,
  });

  final int id;
  final int authorId;
  final String title;
  final String body;

  int get readingMinutes {
    final words = body.trim().split(RegExp(r'\s+')).length;
    return (words / 200).ceil().clamp(1, 999);
  }
}
