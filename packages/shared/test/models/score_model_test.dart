import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('ScoreModel', () {
    test('default values are all zero/empty', () {
      const score = ScoreModel();

      expect(score.totalStamps, 0);
      expect(score.bonusPoints, 0);
      expect(score.selfLockPoints, 0);
      expect(score.totalScore, 0);
      expect(score.currentStreak, 0);
      expect(score.maxStreak, 0);
      expect(score.achievedMilestones, isEmpty);
      expect(score.weeklyStamps, 0);
      expect(score.weeklyScore, 0);
      expect(score.currentLeague, 'dawn');
    });

    test('fromJson creates model with correct values', () {
      final json = {
        'totalStamps': 15,
        'bonusPoints': 15,
        'selfLockPoints': 8,
        'totalScore': 38,
        'currentStreak': 5,
        'maxStreak': 7,
        'lastCompletedDate': '2026-05-01',
        'achievedMilestones': [3, 5],
        'weeklyStamps': 5,
        'weeklyBonus': 5,
        'weeklySelfLockPoints': 3,
        'weeklyScore': 13,
        'currentLeague': 'morning',
        'currentGroupId': 'group1',
        'bestLeague': 'noon',
      };

      final score = ScoreModel.fromJson(json);

      expect(score.totalStamps, 15);
      expect(score.selfLockPoints, 8);
      expect(score.totalScore, 38);
      expect(score.currentStreak, 5);
      expect(score.achievedMilestones, [3, 5]);
      expect(score.currentLeague, 'morning');
      expect(score.bestLeague, 'noon');
    });

    test('toJson roundtrip preserves data', () {
      const score = ScoreModel(
        totalStamps: 10,
        bonusPoints: 8,
        selfLockPoints: 4,
        totalScore: 22,
        currentStreak: 3,
        maxStreak: 5,
        achievedMilestones: [3],
        currentLeague: 'noon',
      );

      final json = score.toJson();
      final restored = ScoreModel.fromJson(json);

      expect(restored.totalStamps, score.totalStamps);
      expect(restored.bonusPoints, score.bonusPoints);
      expect(restored.currentLeague, score.currentLeague);
    });

    test('fromJson handles missing fields with defaults', () {
      final score = ScoreModel.fromJson({});

      expect(score.totalStamps, 0);
      expect(score.currentLeague, 'dawn');
      expect(score.achievedMilestones, isEmpty);
    });
  });
}
