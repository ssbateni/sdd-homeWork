enum UserRole { author, editor }

final class AppUser {
  AppUser({required this.id, required this.role}) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty');
    }
  }

  final String id;
  final UserRole role;
}
