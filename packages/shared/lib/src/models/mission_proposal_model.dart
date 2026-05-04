import 'package:cloud_firestore/cloud_firestore.dart';

enum ProposalStatus { pending, approved, modifiedApproved, rejected }

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
      MissionProposalModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        proposedAt: DateTime.parse(json['proposedAt'] as String),
        reviewedAt: json['reviewedAt'] != null
            ? DateTime.parse(json['reviewedAt'] as String)
            : null,
        status: ProposalStatus.values
            .byName(json['status'] as String? ?? 'pending'),
        rejectReason: json['rejectReason'] as String?,
        modifiedTitle: json['modifiedTitle'] as String?,
        resultTodoId: json['resultTodoId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'proposedAt': proposedAt.toIso8601String(),
        'reviewedAt': reviewedAt?.toIso8601String(),
        'status': status.name,
        'rejectReason': rejectReason,
        'modifiedTitle': modifiedTitle,
        'resultTodoId': resultTodoId,
      };

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
