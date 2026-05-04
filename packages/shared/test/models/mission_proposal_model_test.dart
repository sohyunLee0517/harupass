import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('MissionProposalModel', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 'p1',
        'title': '영어 단어 외우기',
        'description': '20개 단어 암기',
        'proposedAt': '2026-05-01T10:00:00.000',
        'status': 'pending',
      };

      final proposal = MissionProposalModel.fromJson(json);

      expect(proposal.id, 'p1');
      expect(proposal.title, '영어 단어 외우기');
      expect(proposal.status, ProposalStatus.pending);
      expect(proposal.reviewedAt, isNull);
    });

    test('fromJson handles approved with modification', () {
      final json = {
        'id': 'p2',
        'title': '게임하기',
        'proposedAt': '2026-05-01T10:00:00.000',
        'reviewedAt': '2026-05-01T11:00:00.000',
        'status': 'modifiedApproved',
        'modifiedTitle': '교육용 게임 30분하기',
        'resultTodoId': 'todo5',
      };

      final proposal = MissionProposalModel.fromJson(json);

      expect(proposal.status, ProposalStatus.modifiedApproved);
      expect(proposal.modifiedTitle, '교육용 게임 30분하기');
      expect(proposal.resultTodoId, 'todo5');
    });

    test('fromJson handles rejected with reason', () {
      final json = {
        'id': 'p3',
        'title': '그냥 놀기',
        'proposedAt': '2026-05-01T10:00:00.000',
        'status': 'rejected',
        'rejectReason': '미션으로 적절하지 않아요',
      };

      final proposal = MissionProposalModel.fromJson(json);

      expect(proposal.status, ProposalStatus.rejected);
      expect(proposal.rejectReason, '미션으로 적절하지 않아요');
    });

    test('toJson roundtrip preserves data', () {
      final proposal = MissionProposalModel(
        id: 'p1',
        title: '독서',
        proposedAt: DateTime(2026, 5, 1),
        status: ProposalStatus.approved,
        reviewedAt: DateTime(2026, 5, 1, 12, 0),
        resultTodoId: 'todo1',
      );

      final json = proposal.toJson();
      final restored = MissionProposalModel.fromJson(json);

      expect(restored.id, proposal.id);
      expect(restored.status, ProposalStatus.approved);
      expect(restored.resultTodoId, 'todo1');
    });
  });
}
