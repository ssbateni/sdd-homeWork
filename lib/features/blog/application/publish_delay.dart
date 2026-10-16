/// Injectable waiting points outside the atomic in-memory commit.
class PublishDelay {
  const PublishDelay();
  Future<void> beforeCommit() => Future.value();
  Future<void> afterCommitBeforeResponse() => Future.value();
}

enum PublishDemoMode { normal, beforeCommit, afterCommit }

/// Used only by debug composition; changes waiting time, never authorization.
class DemoPublishDelay extends PublishDelay {
  PublishDemoMode mode = PublishDemoMode.normal;
  @override
  Future<void> beforeCommit() => mode == PublishDemoMode.beforeCommit
      ? Future.delayed(const Duration(seconds: 3))
      : Future.value();
  @override
  Future<void> afterCommitBeforeResponse() =>
      mode == PublishDemoMode.afterCommit
      ? Future.delayed(const Duration(seconds: 3))
      : Future.value();
}
