import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'package:harupass/providers/auth_provider.dart';

void main() {
  group('AuthNotifier', () {
    late AuthNotifier notifier;

    setUp(() {
      notifier = AuthNotifier();
    });

    test('initial state is unauthenticated', () {
      expect(notifier.debugState, AuthState.unauthenticated);
      expect(notifier.user, isNull);
    });

    test('signInAsAdmin sets authenticated state and admin user', () async {
      await notifier.signInAsAdmin(name: 'Admin', email: 'a@b.com');

      expect(notifier.debugState, AuthState.authenticated);
      expect(notifier.user, isNotNull);
      expect(notifier.user!.role, UserRole.admin);
      expect(notifier.user!.name, 'Admin');
      expect(notifier.user!.email, 'a@b.com');
    });

    test('signInAsSubject sets authenticated state and subject user', () async {
      await notifier.signInAsSubject(
        inviteCode: '123456',
        nickname: 'Kid',
        profileEmoji: '🦊',
      );

      expect(notifier.debugState, AuthState.authenticated);
      expect(notifier.user, isNotNull);
      expect(notifier.user!.role, UserRole.subject);
      expect(notifier.user!.nickname, 'Kid');
      expect(notifier.user!.profileEmoji, '🦊');
    });

    test('signOut clears user and returns to unauthenticated', () async {
      await notifier.signInAsAdmin(name: 'Admin', email: 'a@b.com');
      expect(notifier.debugState, AuthState.authenticated);

      notifier.signOut();

      expect(notifier.debugState, AuthState.unauthenticated);
      expect(notifier.user, isNull);
    });
  });
}
