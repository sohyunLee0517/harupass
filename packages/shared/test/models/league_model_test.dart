import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('LeagueGroupModel', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 'group1',
        'league': 'morning',
        'userIds': ['u1', 'u2', 'u3'],
        'createdAt': '2026-05-01T00:00:00.000',
      };

      final group = LeagueGroupModel.fromJson(json);

      expect(group.id, 'group1');
      expect(group.league, 'morning');
      expect(group.userIds, hasLength(3));
      expect(group.finalizedAt, isNull);
    });

    test('toJson roundtrip preserves data', () {
      final group = LeagueGroupModel(
        id: 'g1',
        league: 'star',
        userIds: ['u1', 'u2'],
        createdAt: DateTime(2026, 5, 1),
        finalizedAt: DateTime(2026, 5, 7),
      );

      final json = group.toJson();
      final restored = LeagueGroupModel.fromJson(json);

      expect(restored.id, group.id);
      expect(restored.league, 'star');
      expect(restored.userIds, hasLength(2));
      expect(restored.finalizedAt, isNotNull);
    });
  });

  group('LeagueRankingModel', () {
    test('fromJson creates correct model', () {
      final json = {
        'userId': 'u1',
        'rank': 1,
        'weeklyScore': 37,
        'nickname': '골든보이',
        'profileEmoji': '🦁',
        'result': 'promoted',
      };

      final ranking = LeagueRankingModel.fromJson(json);

      expect(ranking.userId, 'u1');
      expect(ranking.rank, 1);
      expect(ranking.weeklyScore, 37);
      expect(ranking.nickname, '골든보이');
      expect(ranking.result, LeagueResult.promoted);
    });

    test('fromJson handles null result', () {
      final json = {
        'userId': 'u2',
        'rank': 15,
        'weeklyScore': 10,
        'nickname': '테스터',
        'profileEmoji': '😎',
      };

      final ranking = LeagueRankingModel.fromJson(json);

      expect(ranking.result, isNull);
    });
  });
}
