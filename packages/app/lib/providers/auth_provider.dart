import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

enum AuthState { loading, unauthenticated, authenticated }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.unauthenticated);

  UserModel? _user;
  UserModel? get user => _user;

  /// Simulate login for now (Firebase later)
  Future<void> signInAsAdmin({
    required String name,
    required String email,
  }) async {
    state = AuthState.loading;
    // TODO: Firebase Auth sign in
    _user = UserModel(
      uid: 'admin_${DateTime.now().millisecondsSinceEpoch}',
      role: UserRole.admin,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    state = AuthState.authenticated;
  }

  Future<void> signInAsSubject({
    required String inviteCode,
    required String nickname,
    required String profileEmoji,
  }) async {
    state = AuthState.loading;
    // TODO: Firebase Auth anonymous + invite code validation
    _user = UserModel(
      uid: 'subject_${DateTime.now().millisecondsSinceEpoch}',
      role: UserRole.subject,
      name: nickname,
      nickname: nickname,
      profileEmoji: profileEmoji,
      adminId: 'temp_admin_id',
      createdAt: DateTime.now(),
    );
    state = AuthState.authenticated;
  }

  void signOut() {
    _user = null;
    state = AuthState.unauthenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
