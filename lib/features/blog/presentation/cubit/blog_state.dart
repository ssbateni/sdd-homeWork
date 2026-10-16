import '../../domain/app_user.dart';
import '../../domain/blog_result.dart';
import '../../domain/post.dart';
import '../../domain/publish_request.dart';

enum BlogPhase {
  noUser,
  loading,
  viewing,
  failure,
  awaitingConfirmation,
  publishing,
  success,
  cancelled,
}

final class BlogState {
  BlogState({
    this.phase = BlogPhase.noUser,
    this.user,
    List<Post> posts = const [],
    this.selectedPost,
    this.failure,
    this.pending,
    this.receipt,
  }) : posts = List.unmodifiable(posts);
  final BlogPhase phase;
  final AppUser? user;
  final List<Post> posts;
  final Post? selectedPost;
  final BlogFailure? failure;
  final PendingPublish? pending;
  final PublishReceipt? receipt;
}
