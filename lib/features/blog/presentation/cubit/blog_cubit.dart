import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../application/blog_service.dart';
import '../../application/current_user_session.dart';
import '../../domain/app_user.dart';
import '../../domain/blog_result.dart';
import '../../domain/post.dart';
import '../../domain/publish_request.dart';
import 'blog_state.dart';

class BlogCubit extends Cubit<BlogState> {
  BlogCubit({
    required this._service,
    required this._session,
    this._waitLimit = const Duration(seconds: 2),
  }) : super(BlogState()) {
    _loadVisible();
  }
  final BlogService _service;
  final CurrentUserSession _session;
  final Duration _waitLimit;
  int _generation = 0;
  int _waitAttempt = 0;
  List<AppUser> get availableUsers => _session.availableUsers;
  Future<void> retry() async {
    final pending = state.pending;
    if (pending == null || state.phase != BlogPhase.unknownOutcome) return;
    await _wait(
      pending,
      _service.retryPublish(pending.requestId, pending.postId),
    );
  }

  void requestPublish() {
    final post = state.selectedPost;
    if (post == null ||
        state.phase == BlogPhase.publishing ||
        state.pending != null) {
      return;
    }
    switch (_service.preparePublish(post.id)) {
      case BlogSuccess<PendingPublish>(:final value):
        _publishState(BlogPhase.awaitingConfirmation, pending: value);
      case BlogFailure failure:
        _publishState(BlogPhase.failure, failure: failure);
    }
  }

  Future<void> confirm() async {
    final pending = state.pending;
    if (pending == null || state.phase != BlogPhase.awaitingConfirmation) {
      return;
    }
    await _wait(pending, _service.confirmPublish(pending.requestId));
  }

  Future<void> _wait(
    PendingPublish pending,
    Future<BlogResult<PublishReceipt>> operation,
  ) async {
    final generation = _generation;
    final attempt = ++_waitAttempt;
    bool isCurrent() =>
        !isClosed &&
        generation == _generation &&
        attempt == _waitAttempt &&
        state.pending?.requestId == pending.requestId;
    _publishState(BlogPhase.publishing, pending: pending);
    late final BlogResult<PublishReceipt> result;
    try {
      result = await operation.timeout(_waitLimit);
    } on TimeoutException {
      if (isCurrent()) {
        _publishState(BlogPhase.unknownOutcome, pending: pending);
      }
      return;
    }
    if (!isCurrent()) return;
    final postsResult = _service.listVisiblePosts();
    final postResult = _service.getPost(pending.postId);
    emit(
      BlogState(
        phase: result is BlogSuccess ? BlogPhase.success : BlogPhase.failure,
        user: _session.currentUser,
        posts: postsResult is BlogSuccess<List<Post>>
            ? postsResult.value
            : const [],
        selectedPost: postResult is BlogSuccess<Post> ? postResult.value : null,
        receipt: result is BlogSuccess<PublishReceipt> ? result.value : null,
        failure: result is BlogFailure ? result : null,
      ),
    );
  }

  void cancel() {
    final pending = state.pending;
    if (pending == null || state.phase != BlogPhase.awaitingConfirmation) {
      return;
    }
    final result = _service.cancelPublish(pending.requestId);
    _session.invalidatePendingContext();
    _publishState(
      result is BlogFailure ? BlogPhase.failure : BlogPhase.cancelled,
      failure: result is BlogFailure ? result : null,
    );
  }

  void _publishState(
    BlogPhase phase, {
    PendingPublish? pending,
    BlogFailure? failure,
  }) {
    emit(
      BlogState(
        phase: phase,
        user: state.user,
        posts: state.posts,
        selectedPost: state.selectedPost,
        pending: pending,
        failure: failure,
      ),
    );
  }

  void selectUser(String userId) {
    _generation++;
    _session.invalidatePendingContext();
    final result = _session.selectUser(userId);
    if (result case BlogFailure()) {
      emit(
        BlogState(
          phase: BlogPhase.failure,
          user: _session.currentUser,
          failure: result,
        ),
      );
    } else {
      refresh();
    }
  }

  void selectPost(int postId) {
    _generation++;
    _session.invalidatePendingContext();
    final result = _service.getPost(postId);
    switch (result) {
      case BlogSuccess<Post>(:final value):
        emit(
          BlogState(
            phase: BlogPhase.viewing,
            user: _session.currentUser,
            posts: state.posts,
            selectedPost: value,
          ),
        );
      case BlogFailure():
        emit(
          BlogState(
            phase: BlogPhase.failure,
            user: _session.currentUser,
            posts: state.posts,
            failure: result,
          ),
        );
    }
  }

  void refresh() {
    _generation++;
    _session.invalidatePendingContext();
    _loadVisible();
  }

  void _loadVisible() {
    final user = _session.currentUser;
    if (user == null) {
      emit(BlogState());
      return;
    }
    emit(BlogState(phase: BlogPhase.loading, user: user));
    switch (_service.listVisiblePosts()) {
      case BlogSuccess<List<Post>>(:final value):
        emit(BlogState(phase: BlogPhase.viewing, user: user, posts: value));
      case BlogFailure failure:
        emit(BlogState(phase: BlogPhase.failure, user: user, failure: failure));
    }
  }
}
