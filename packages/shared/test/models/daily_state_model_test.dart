import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('DailyStateModel', () {
    test('default values', () {
      const state = DailyStateModel();

      expect(state.allCompleted, false);
      expect(state.lockReleasedAt, isNull);
      expect(state.stampType, isNull);
    });

    test('fromJson creates correct model', () {
      final json = {
        'allCompleted': true,
        'lockReleasedAt': '2026-05-01T15:30:00.000',
        'stampType': 'milestone',
      };

      final state = DailyStateModel.fromJson(json);

      expect(state.allCompleted, true);
      expect(state.lockReleasedAt, isNotNull);
      expect(state.stampType, StampType.milestone);
    });

    test('fromJson handles missing fields', () {
      final state = DailyStateModel.fromJson({});

      expect(state.allCompleted, false);
      expect(state.lockReleasedAt, isNull);
      expect(state.stampType, isNull);
    });

    test('toJson roundtrip preserves data', () {
      final state = DailyStateModel(
        allCompleted: true,
        lockReleasedAt: DateTime(2026, 5, 1, 15, 30),
        stampType: StampType.normal,
      );

      final json = state.toJson();
      final restored = DailyStateModel.fromJson(json);

      expect(restored.allCompleted, true);
      expect(restored.stampType, StampType.normal);
    });
  });
}
