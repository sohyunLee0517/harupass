import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('SelfLockModel', () {
    test('calculatePoints returns correct points per 30min block', () {
      expect(SelfLockModel.calculatePoints(0), 0);
      expect(SelfLockModel.calculatePoints(15), 0);
      expect(SelfLockModel.calculatePoints(29), 0);
      expect(SelfLockModel.calculatePoints(30), 1);
      expect(SelfLockModel.calculatePoints(45), 1);
      expect(SelfLockModel.calculatePoints(59), 1);
      expect(SelfLockModel.calculatePoints(60), 2);
      expect(SelfLockModel.calculatePoints(89), 2);
      expect(SelfLockModel.calculatePoints(90), 3);
      expect(SelfLockModel.calculatePoints(110), 3);
      expect(SelfLockModel.calculatePoints(120), 4);
    });

    test('fromJson creates instant lock model', () {
      final json = {
        'id': 'lock1',
        'type': 'instant',
        'actualStart': '2026-05-01T19:00:00.000',
        'actualEnd': '2026-05-01T20:50:00.000',
        'plannedDuration': 120,
        'actualDuration': 110,
        'status': 'completed',
        'earnedPoints': 3,
        'createdAt': '2026-05-01T19:00:00.000',
      };

      final lock = SelfLockModel.fromJson(json);

      expect(lock.id, 'lock1');
      expect(lock.type, SelfLockType.instant);
      expect(lock.status, SelfLockStatus.completed);
      expect(lock.earnedPoints, 3);
      expect(lock.plannedDuration, 120);
      expect(lock.actualDuration, 110);
    });

    test('fromJson creates scheduled lock model', () {
      final json = {
        'id': 'lock2',
        'type': 'scheduled',
        'scheduledStart': '2026-05-01T14:00:00.000',
        'plannedDuration': 60,
        'status': 'scheduled',
        'createdAt': '2026-05-01T12:00:00.000',
      };

      final lock = SelfLockModel.fromJson(json);

      expect(lock.type, SelfLockType.scheduled);
      expect(lock.status, SelfLockStatus.scheduled);
      expect(lock.scheduledStart, isNotNull);
      expect(lock.actualStart, isNull);
    });

    test('toJson roundtrip preserves data', () {
      final lock = SelfLockModel(
        id: 'l1',
        type: SelfLockType.instant,
        plannedDuration: 60,
        actualDuration: 55,
        status: SelfLockStatus.completed,
        earnedPoints: 1,
        createdAt: DateTime(2026, 5, 1),
        actualStart: DateTime(2026, 5, 1, 10, 0),
        actualEnd: DateTime(2026, 5, 1, 10, 55),
      );

      final json = lock.toJson();
      final restored = SelfLockModel.fromJson(json);

      expect(restored.id, lock.id);
      expect(restored.type, lock.type);
      expect(restored.earnedPoints, lock.earnedPoints);
    });
  });
}
