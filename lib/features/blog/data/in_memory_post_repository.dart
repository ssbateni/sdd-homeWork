import '../domain/post.dart';
import '../domain/post_repository.dart';

final class InMemoryPostRepository implements PostRepository {
  InMemoryPostRepository(List<Post> posts) {
    for (final post in posts) {
      if (_posts.containsKey(post.id)) {
        throw ArgumentError('Duplicate post id');
      }
      _posts[post.id] = StoredPost(post: post, revision: 0);
    }
  }
  final Map<int, StoredPost> _posts = {};
  @override
  List<StoredPost> readAll() => List.unmodifiable(_posts.values);
  @override
  StoredPost? readById(int postId) => _posts[postId];
  @override
  void replacePublished(int postId, int expectedRevision) {
    final stored = _posts[postId];
    if (stored == null || stored.revision != expectedRevision) {
      throw StateError('Post must exist with the expected revision');
    }
    final old = stored.post;
    _posts[postId] = StoredPost(
      post: Post(
        id: old.id,
        title: old.title,
        content: old.content,
        status: PostStatus.published,
        approved: old.approved,
        authorId: old.authorId,
        createdAt: old.createdAt,
      ),
      revision: stored.revision + 1,
    );
  }
}
