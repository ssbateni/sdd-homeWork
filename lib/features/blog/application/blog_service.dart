import 'dart:async';
import 'dart:math';

import '../domain/blog_result.dart';
import '../domain/app_user.dart';
import '../domain/post.dart';
import '../domain/post_repository.dart';
import '../domain/publish_request.dart';
import 'current_user_session.dart';
import 'publish_delay.dart';

/// Shared authorization and publishing logic for a single in-memory app scope.
class BlogService {
  BlogService({required this._repository, required this._session, this._delay = const PublishDelay()});
  final PublishDelay _delay;
  final PostRepository _repository;
  final CurrentUserSession _session;
  final String _runNonce =
      '${Random.secure().nextInt(1 << 30)}-${Random.secure().nextInt(1 << 30)}';
  int _requestCounter = 0;
  final Map<String, PublishRecord> _requests = {};

  BlogResult<List<Post>> listVisiblePosts() {
    final user = _session.currentUser;
    if (user == null) return _denied;
    return BlogSuccess(
      List.unmodifiable(
        _repository
            .readAll()
            .map((stored) => stored.post)
            .where(
              (post) =>
                  user.role == UserRole.editor || post.authorId == user.id,
            ),
      ),
    );
  }

  BlogResult<Post> getPost(int postId) {
    if (postId <= 0) {
      return const BlogFailure(
        code: BlogErrorCode.invalidArguments,
        message: 'شناسهٔ پست نامعتبر است.',
      );
    }
    final user = _session.currentUser;
    if (user == null) return _denied;
    final stored = _repository.readById(postId);
    if (stored == null) {
      return const BlogFailure(
        code: BlogErrorCode.notFound,
        message: 'پست یافت نشد.',
      );
    }
    if (user.role != UserRole.editor && stored.post.authorId != user.id) {
      return _denied;
    }
    return BlogSuccess(stored.post);
  }

  static const _denied = BlogFailure(
    code: BlogErrorCode.permissionDenied,
    message: 'اجازهٔ مشاهده ندارید.',
  );
  BlogResult<PendingPublish> preparePublish(int postId) {
    final checked = _eligiblePost(postId);
    if (checked case BlogFailure()) return checked;
    final stored = (checked as BlogSuccess<StoredPost>).value;
    final fingerprint = PublishFingerprint(
      actorId: _session.currentUser!.id,
      postId: postId,
    );
    final requestId = '$_runNonce-${++_requestCounter}';
    _requests[requestId] = PublishRecord(
      fingerprint: fingerprint,
      snapshot: ConfirmationSnapshot(
        fingerprint: fingerprint,
        sessionEpoch: _session.epoch,
        contextEpoch: _session.contextEpoch,
        postRevision: stored.revision,
      ),
    );
    return BlogSuccess(
      PendingPublish(
        requestId: requestId,
        postId: postId,
        title: stored.post.title,
      ),
    );
  }

  BlogResult<StoredPost> _eligiblePost(int postId) {
    if (postId <= 0) return _publishFailure(BlogErrorCode.invalidArguments);
    if (_session.currentUser?.role != UserRole.editor) {
      return _publishFailure(BlogErrorCode.permissionDenied);
    }
    final stored = _repository.readById(postId);
    if (stored == null) return _publishFailure(BlogErrorCode.notFound);
    if (stored.post.status == PostStatus.published) {
      return _publishFailure(BlogErrorCode.alreadyPublished);
    }
    if (stored.post.status != PostStatus.draft) {
      return _publishFailure(BlogErrorCode.invalidStatus);
    }
    if (!stored.post.approved) {
      return _publishFailure(BlogErrorCode.notApproved);
    }
    return BlogSuccess(stored);
  }

  BlogFailure _publishFailure(BlogErrorCode code) =>
      BlogFailure(code: code, message: 'انتشار انجام نشد (${code.value}).');

  /// Only the trusted application's explicit confirmation event may call this.
  Future<BlogResult<PublishReceipt>> confirmPublish(String requestId) {
    final lookup = _recordFor(requestId);
    if (lookup case BlogFailure()) return Future.value(lookup);
    final record = (lookup as BlogSuccess<PublishRecord>).value;
    if (record.terminalResult != null) return Future.value(record.terminalResult!);
    if (record.inFlight != null) return record.inFlight!;
    record.confirmedByUser = true;
    record.phase = PublishPhase.executing;
    return _start(requestId, record);
  }

  Future<BlogResult<PublishReceipt>> _start(String requestId, PublishRecord record) {
    final completer = Completer<BlogResult<PublishReceipt>>();
    record.inFlight = completer.future;
    Future.sync(() => _execute(requestId, record)).then((result) {
      if (record.terminalResult == null && result is BlogFailure) _reject(record, result);
      completer.complete(result);
    }, onError: completer.completeError);
    return completer.future;
  }

  Future<BlogResult<PublishReceipt>> _execute(String requestId, PublishRecord record) async {
    await _delay.beforeCommit();
    final result = _confirm(requestId);
    if (result is BlogSuccess<PublishReceipt>) {
      await _delay.afterCommitBeforeResponse();
    }
    return result;
  }

  BlogResult<PublishReceipt> _confirm(String requestId) {
    final lookup = _recordFor(requestId);
    if (lookup case BlogFailure()) return lookup;
    final record = (lookup as BlogSuccess<PublishRecord>).value;
    if (record.terminalResult != null) return record.terminalResult!;
    final checked = _eligiblePost(record.fingerprint.postId);
    if (checked case BlogFailure()) return _reject(record, checked);
    final stored = (checked as BlogSuccess<StoredPost>).value;
    final snapshot = record.snapshot;
    if (snapshot.sessionEpoch != _session.epoch ||
        snapshot.contextEpoch != _session.contextEpoch ||
        snapshot.postRevision != stored.revision) {
      return _reject(record, _publishFailure(BlogErrorCode.staleConfirmation));
    }
    record.confirmedByUser = true;
    record.phase = PublishPhase.executing;
    // Single-isolate synchronous commit: no await or external callbacks here.
    _repository.replacePublished(stored.post.id, stored.revision);
    final result = BlogSuccess(
      PublishReceipt(requestId: requestId, postId: stored.post.id),
    );
    record.terminalResult = result;
    record.phase = PublishPhase.committed;
    return result;
  }

  BlogResult<PublishRecord> _recordFor(String requestId) {
    if (requestId.isEmpty) {
      return _publishFailure(BlogErrorCode.invalidArguments);
    }
    if (_session.currentUser?.role != UserRole.editor) {
      return _publishFailure(BlogErrorCode.permissionDenied);
    }
    final record = _requests[requestId];
    if (record == null) return _publishFailure(BlogErrorCode.staleConfirmation);
    if (record.fingerprint.actorId != _session.currentUser!.id) {
      return _publishFailure(BlogErrorCode.requestConflict);
    }
    return BlogSuccess(record);
  }

  BlogFailure _reject(PublishRecord record, BlogFailure failure) {
    record.phase = PublishPhase.rejected;
    record.terminalResult = failure;
    return failure;
  }

  BlogResult<void> cancelPublish(String requestId) {
    final lookup = _recordFor(requestId);
    if (lookup case BlogFailure()) return lookup;
    final record = (lookup as BlogSuccess<PublishRecord>).value;
    if (record.phase == PublishPhase.committed) {
      return _publishFailure(BlogErrorCode.alreadyPublished);
    }
    if (record.phase == PublishPhase.rejected) {
      return record.terminalResult! as BlogFailure;
    }
    record.phase = PublishPhase.cancelled;
    record.confirmedByUser = false;
    record.terminalResult = _publishFailure(BlogErrorCode.cancelled);
    return const BlogSuccess<void>(null);
  }

  Future<BlogResult<PublishReceipt>> retryPublish(
    String requestId,
    int postId,
  ) {
    if (postId <= 0 || requestId.isEmpty) return Future.value(_publishFailure(BlogErrorCode.invalidArguments));
    final lookup = _recordFor(requestId);
    if (lookup case BlogFailure()) return Future.value(lookup);
    final record = (lookup as BlogSuccess<PublishRecord>).value;
    if (record.fingerprint.postId != postId) return Future.value(_publishFailure(BlogErrorCode.requestConflict));
    if (record.terminalResult != null) return Future.value(record.terminalResult!);
    if (!record.confirmedByUser) return Future.value(_publishFailure(BlogErrorCode.confirmationRequired));
    return record.inFlight ?? _start(requestId, record);
  }
}
