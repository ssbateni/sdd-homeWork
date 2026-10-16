import 'blog_result.dart';
import 'post.dart';

/// Display data only. Possessing this value does not confirm an operation.
final class PendingPublish {
  PendingPublish({
    required this.requestId,
    required this.postId,
    required this.title,
  }) {
    if (requestId.isEmpty) throw ArgumentError('Request identity is required');
  }
  final String requestId;
  final int postId;
  final String title;
  PostStatus get fromStatus => PostStatus.draft;
  PostStatus get toStatus => PostStatus.published;
}

final class PublishFingerprint {
  const PublishFingerprint({required this.actorId, required this.postId});
  final String actorId;
  final int postId;
  String get operation => 'publish';
}

final class ConfirmationSnapshot {
  const ConfirmationSnapshot({
    required this.fingerprint,
    required this.sessionEpoch,
    required this.contextEpoch,
    required this.postRevision,
  });
  final PublishFingerprint fingerprint;
  final int sessionEpoch;
  final int contextEpoch;
  final int postRevision;
}

enum PublishPhase {
  awaitingConfirmation,
  executing,
  committed,
  cancelled,
  rejected,
}

/// Internal service-owned state; never returned to UI or model adapters.
final class PublishRecord {
  PublishRecord({required this.fingerprint, required this.snapshot});
  final PublishFingerprint fingerprint;
  final ConfirmationSnapshot snapshot;
  PublishPhase phase = PublishPhase.awaitingConfirmation;
  bool confirmedByUser = false;
  Future<BlogResult<PublishReceipt>>? inFlight;
  BlogResult<PublishReceipt>? terminalResult;
}

final class PublishReceipt {
  PublishReceipt({required this.requestId, required this.postId}) {
    if (requestId.isEmpty) throw ArgumentError('Request identity is required');
  }
  final String requestId;
  final int postId;
  PostStatus get status => PostStatus.published;
}
