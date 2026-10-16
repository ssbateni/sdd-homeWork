enum PostStatus { draft, published, archived }

final class Post {
  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.approved,
    required this.authorId,
    required this.createdAt,
  }) {
    if (id <= 0) {
      throw ArgumentError.value(id, 'id', 'Must be positive');
    }
  }

  final int id;
  final String title;
  final String content;
  final PostStatus status;
  final bool approved;
  final String authorId;
  final DateTime createdAt;
}

final class StoredPost {
  const StoredPost({required this.post, required this.revision});

  final Post post;
  final int revision;
}
