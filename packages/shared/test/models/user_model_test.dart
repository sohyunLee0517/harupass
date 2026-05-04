import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates correct admin model', () {
      final json = {
        'uid': 'user123',
        'role': 'admin',
        'email': 'test@test.com',
        'name': 'Test Admin',
        'createdAt': '2026-01-01T00:00:00.000',
        'subjectIds': ['child1', 'child2'],
        'nickname': '',
        'profileEmoji': '😊',
      };

      final user = UserModel.fromJson(json);

      expect(user.uid, 'user123');
      expect(user.role, UserRole.admin);
      expect(user.email, 'test@test.com');
      expect(user.name, 'Test Admin');
      expect(user.subjectIds, ['child1', 'child2']);
      expect(user.adminId, isNull);
    });

    test('fromJson creates correct subject model', () {
      final json = {
        'uid': 'child1',
        'role': 'subject',
        'name': 'Test Child',
        'createdAt': '2026-01-01T00:00:00.000',
        'adminId': 'user123',
        'nickname': 'SuperKid',
        'profileEmoji': '🦊',
      };

      final user = UserModel.fromJson(json);

      expect(user.uid, 'child1');
      expect(user.role, UserRole.subject);
      expect(user.adminId, 'user123');
      expect(user.nickname, 'SuperKid');
      expect(user.profileEmoji, '🦊');
      expect(user.subjectIds, isEmpty);
    });

    test('toJson roundtrip preserves data', () {
      final user = UserModel(
        uid: 'u1',
        role: UserRole.admin,
        name: 'Admin',
        email: 'a@b.com',
        createdAt: DateTime(2026, 1, 1),
        subjectIds: ['c1'],
      );

      final json = user.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored.uid, user.uid);
      expect(restored.role, user.role);
      expect(restored.email, user.email);
      expect(restored.subjectIds, user.subjectIds);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'uid': 'u1',
        'role': 'subject',
        'name': 'Child',
        'createdAt': '2026-05-01T00:00:00.000',
      };

      final user = UserModel.fromJson(json);

      expect(user.email, isNull);
      expect(user.adminId, isNull);
      expect(user.nickname, '');
      expect(user.profileEmoji, '😊');
      expect(user.subjectIds, isEmpty);
    });
  });
}
