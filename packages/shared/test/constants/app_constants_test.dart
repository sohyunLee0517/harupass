import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('AppConstants', () {
    test('invite code length is 6', () {
      expect(AppConstants.inviteCodeLength, 6);
    });

    test('self lock constraints', () {
      expect(AppConstants.selfLockMinMinutes, 30);
      expect(AppConstants.selfLockMaxMinutes, 120);
      expect(AppConstants.selfLockStepMinutes, 30);
      expect(AppConstants.selfLockPointsPerStep, 1);
    });

    test('milestone days and bonus are consistent', () {
      expect(AppConstants.milestoneDays, [3, 5, 7]);
      for (final day in AppConstants.milestoneDays) {
        expect(AppConstants.milestoneBonus.containsKey(day), true);
        expect(AppConstants.milestoneBonus[day], day);
      }
    });

    test('league tiers have 7 levels', () {
      expect(AppConstants.leagueTiers, hasLength(7));
      expect(AppConstants.leagueTiers.first, 'dawn');
      expect(AppConstants.leagueTiers.last, 'sun');
    });

    test('league names match tiers', () {
      for (final tier in AppConstants.leagueTiers) {
        expect(AppConstants.leagueNames.containsKey(tier), true);
      }
    });

    test('league group size and promote/demote counts are valid', () {
      expect(AppConstants.leagueGroupSize, 30);
      expect(
        AppConstants.leaguePromoteCount + AppConstants.leagueDemoteCount,
        lessThanOrEqualTo(AppConstants.leagueGroupSize),
      );
    });
  });
}
