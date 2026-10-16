import '../domain/app_user.dart';
import '../domain/blog_result.dart';

/// Demo identity selection, not real authentication.
class CurrentUserSession {
  CurrentUserSession({required List<AppUser> users})
    : _users = List.unmodifiable(users);
  final List<AppUser> _users;
  String? _userId;
  int _epoch = 0;
  int _contextEpoch = 0;

  List<AppUser> get availableUsers => _users;
  AppUser? get currentUser {
    for (final user in _users) {
      if (user.id == _userId) return user;
    }
    return null;
  }

  int get epoch => _epoch;
  int get contextEpoch => _contextEpoch;

  BlogResult<AppUser> selectUser(String userId) {
    for (final user in _users) {
      if (user.id == userId) {
        if (_userId != userId) {
          _userId = userId;
          _epoch++;
          invalidatePendingContext();
        }
        return BlogSuccess(user);
      }
    }
    return const BlogFailure(
      code: BlogErrorCode.invalidArguments,
      message: 'کاربر نامعتبر است.',
    );
  }

  void invalidatePendingContext() {
    _contextEpoch++;
  }
}
