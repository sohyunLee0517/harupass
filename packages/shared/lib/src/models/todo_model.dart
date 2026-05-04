import 'package:cloud_firestore/cloud_firestore.dart';

enum TodoStatus { pending, submitted, approved, rejected }

enum TodoCreator { admin, subject }

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

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: TodoStatus.values.byName(json['status'] as String? ?? 'pending'),
        photoUrl: json['photoUrl'] as String?,
        submittedAt: json['submittedAt'] != null
            ? DateTime.parse(json['submittedAt'] as String)
            : null,
        reviewedAt: json['reviewedAt'] != null
            ? DateTime.parse(json['reviewedAt'] as String)
            : null,
        rejectReason: json['rejectReason'] as String?,
        createdBy:
            TodoCreator.values.byName(json['createdBy'] as String? ?? 'admin'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.name,
        'photoUrl': photoUrl,
        'submittedAt': submittedAt?.toIso8601String(),
        'reviewedAt': reviewedAt?.toIso8601String(),
        'rejectReason': rejectReason,
        'createdBy': createdBy.name,
      };

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
