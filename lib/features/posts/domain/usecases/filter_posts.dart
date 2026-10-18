import '../entities/post.dart';

final class PostQuery {
  const PostQuery({this.text = '', this.authorId, this.newestFirst = true});
  final String text;
  final int? authorId;
  final bool newestFirst;
}

/// Quy tắc tìm kiếm/lọc/sắp xếp nằm ở Domain, không nằm trong widget.
final class FilterPosts {
  const FilterPosts();

  List<Post> call(List<Post> posts, PostQuery query) {
    final keyword = query.text.trim().toLowerCase();
    final result = posts.where((post) {
      final matchesAuthor =
          query.authorId == null || post.authorId == query.authorId;
      final matchesText =
          keyword.isEmpty ||
          post.title.toLowerCase().contains(keyword) ||
          post.body.toLowerCase().contains(keyword);
      return matchesAuthor && matchesText;
    }).toList();
    result.sort(
      (a, b) => query.newestFirst ? b.id.compareTo(a.id) : a.id.compareTo(b.id),
    );
    return List.unmodifiable(result);
  }
}
