import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo_model.g.dart';

enum TodoStatus { pending, submitted, approved, rejected }

enum TodoCreator { admin, subject }

@JsonSerializable()
class TodoModel {
  final String id;
  final String title;
  final String? description;
  final TodoStatus status;
  final String? photoUrl;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? rejectReason;
  final TodoCreator createdBy;

  const TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.status = TodoStatus.pending,
    this.photoUrl,
    this.submittedAt,
    this.reviewedAt,
    this.rejectReason,
    this.createdBy = TodoCreator.admin,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);
  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  factory TodoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoModel.fromJson({
      'id': doc.id,
      ...data,
      if (data['submittedAt'] != null)
        'submittedAt':
            (data['submittedAt'] as Timestamp).toDate().toIso8601String(),
      if (data['reviewedAt'] != null)
        'reviewedAt':
            (data['reviewedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  bool get isCompleted => status == TodoStatus.approved;
}
