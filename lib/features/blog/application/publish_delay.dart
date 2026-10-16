/// Injectable waiting points outside the atomic in-memory commit.
class PublishDelay {
  const PublishDelay();
  Future<void> beforeCommit() => Future.value();
  Future<void> afterCommitBeforeResponse() => Future.value();
}
