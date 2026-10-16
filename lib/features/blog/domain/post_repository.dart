import 'post.dart';

/// Internal data access. Only BlogService may use the write operation.
abstract interface class PostRepository {
  /// Returns an unmodifiable list of immutable snapshots; does not authorize.
  List<StoredPost> readAll();

  /// Returns null when absent; permission checks belong to BlogService.
  StoredPost? readById(int postId);

  /// Synchronous write, after service checks: only status and revision change.
  ///
  /// Requires an existing post and a matching revision. Increases revision by
  /// one. Violating these preconditions is a programming error. No I/O or await
  /// is allowed in the in-memory implementation's commit section.
  void replacePublished(int postId, int expectedRevision);
}
