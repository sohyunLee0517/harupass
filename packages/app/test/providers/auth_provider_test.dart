import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'package:harupass/providers/auth_provider.dart';

// AuthNotifier는 이제 Firebase 의존성이 있으므로
// 단위 테스트는 Repository 레벨에서 수행하고,
// 통합 테스트에서 전체 플로우를 검증합니다.

void main() {
  group('AuthState', () {
    test('AuthState has expected values', () {
      expect(AuthState.values.length, 3);
      expect(AuthState.loading, isNotNull);
      expect(AuthState.unauthenticated, isNotNull);
      expect(AuthState.authenticated, isNotNull);
    });
  });

  group('UserModel role check', () {
    test('admin user has correct role', () {
      final admin = UserModel(
        uid: 'test',
        role: UserRole.admin,
        name: 'Admin',
        email: 'a@b.com',
        createdAt: DateTime.now(),
      );
      expect(admin.role, UserRole.admin);
    });

    test('subject user has correct role and fields', () {
      final subject = UserModel(
        uid: 'test',
        role: UserRole.subject,
        name: 'Kid',
        nickname: 'Kid',
        profileEmoji: '🦊',
        adminId: 'admin_123',
        createdAt: DateTime.now(),
      );
      expect(subject.role, UserRole.subject);
      expect(subject.nickname, 'Kid');
      expect(subject.profileEmoji, '🦊');
      expect(subject.adminId, 'admin_123');
    });
  });
}
