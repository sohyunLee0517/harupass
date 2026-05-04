import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('FirestorePaths', () {
    test('user paths', () {
      expect(FirestorePaths.users, 'users');
      expect(FirestorePaths.user('u1'), 'users/u1');
      expect(FirestorePaths.score('u1'), 'users/u1/score');
    });

    test('invite code paths', () {
      expect(FirestorePaths.inviteCodes, 'inviteCodes');
      expect(FirestorePaths.inviteCode('ABC'), 'inviteCodes/ABC');
    });

    test('todo paths', () {
      expect(
        FirestorePaths.todosDaily('u1', '2026-05-01'),
        'todos/u1/daily/2026-05-01/items',
      );
      expect(
        FirestorePaths.todoItem('u1', '2026-05-01', 't1'),
        'todos/u1/daily/2026-05-01/items/t1',
      );
    });

    test('self lock paths', () {
      expect(FirestorePaths.selfLocks('u1'), 'selfLocks/u1');
      expect(FirestorePaths.selfLock('u1', 'l1'), 'selfLocks/u1/l1');
    });

    test('league paths', () {
      expect(
        FirestorePaths.leagueGroups('2026-W18'),
        'leagues/2026-W18/groups',
      );
      expect(
        FirestorePaths.leagueRanking('2026-W18', 'g1', 'u1'),
        'leagues/2026-W18/groups/g1/rankings/u1',
      );
    });
  });
}
