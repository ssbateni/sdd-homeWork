/// Stable domain codes. Timeout belongs to the waiting UI, not a terminal result.
enum BlogErrorCode {
  invalidArguments('invalid_arguments'),
  permissionDenied('permission_denied'),
  notFound('not_found'),
  alreadyPublished('already_published'),
  invalidStatus('invalid_status'),
  notApproved('not_approved'),
  confirmationRequired('confirmation_required'),
  staleConfirmation('stale_confirmation'),
  cancelled('cancelled'),
  requestConflict('request_conflict');

  const BlogErrorCode(this.value);
  final String value;
}

sealed class BlogResult<T> {
  const BlogResult();
}

final class BlogSuccess<T> extends BlogResult<T> {
  const BlogSuccess(this.value);
  final T value;
}

/// No Post or credentials payload: callers must supply a safe display message.
final class BlogFailure extends BlogResult<Never> {
  const BlogFailure({required this.code, required this.message});
  final BlogErrorCode code;
  final String message;
}
