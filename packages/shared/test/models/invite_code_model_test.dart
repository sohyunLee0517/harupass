import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('InviteCodeModel', () {
    test('fromJson creates correct model', () {
      final json = {
        'code': 'ABC123',
        'adminId': 'admin1',
        'createdAt': '2026-05-01T00:00:00.000',
        'expiresAt': '2026-05-02T00:00:00.000',
        'status': 'active',
      };

      final code = InviteCodeModel.fromJson(json);

      expect(code.code, 'ABC123');
      expect(code.adminId, 'admin1');
      expect(code.status, InviteCodeStatus.active);
      expect(code.usedBy, isNull);
    });

    test('isExpired returns true for past expiry', () {
      final expired = InviteCodeModel(
        code: 'EXP001',
        adminId: 'admin1',
        createdAt: DateTime(2020, 1, 1),
        expiresAt: DateTime(2020, 1, 2),
      );

      expect(expired.isExpired, true);
      expect(expired.isUsable, false);
    });

    test('isUsable returns true for active non-expired code', () {
      final valid = InviteCodeModel(
        code: 'VAL001',
        adminId: 'admin1',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        status: InviteCodeStatus.active,
      );

      expect(valid.isExpired, false);
      expect(valid.isUsable, true);
    });

    test('isUsable returns false for used code', () {
      final used = InviteCodeModel(
        code: 'USE001',
        adminId: 'admin1',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        status: InviteCodeStatus.used,
        usedBy: 'child1',
      );

      expect(used.isUsable, false);
    });

    test('toJson roundtrip preserves data', () {
      final code = InviteCodeModel(
        code: 'RT0001',
        adminId: 'a1',
        createdAt: DateTime(2026, 5, 1),
        expiresAt: DateTime(2026, 5, 2),
        status: InviteCodeStatus.used,
        usedBy: 'c1',
      );

      final json = code.toJson();
      final restored = InviteCodeModel.fromJson(json);

      expect(restored.code, code.code);
      expect(restored.status, InviteCodeStatus.used);
      expect(restored.usedBy, 'c1');
    });
  });
}
