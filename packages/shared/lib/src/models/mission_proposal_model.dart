import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mission_proposal_model.g.dart';

enum ProposalStatus { pending, approved, modifiedApproved, rejected }

@JsonSerializable()
class MissionProposalModel {
  final String id;
  final String title;
  final String? description;
  final DateTime proposedAt;
  final DateTime? reviewedAt;
  final ProposalStatus status;
  final String? rejectReason;
  final String? modifiedTitle;
  final String? resultTodoId;

  const MissionProposalModel({
    required this.id,
    required this.title,
    this.description,
    required this.proposedAt,
    this.reviewedAt,
    this.status = ProposalStatus.pending,
    this.rejectReason,
    this.modifiedTitle,
    this.resultTodoId,
  });

  factory MissionProposalModel.fromJson(Map<String, dynamic> json) =>
      _$MissionProposalModelFromJson(json);
  Map<String, dynamic> toJson() => _$MissionProposalModelToJson(this);

  factory MissionProposalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MissionProposalModel.fromJson({
      'id': doc.id,
      ...data,
      'proposedAt':
          (data['proposedAt'] as Timestamp).toDate().toIso8601String(),
      if (data['reviewedAt'] != null)
        'reviewedAt':
            (data['reviewedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}
