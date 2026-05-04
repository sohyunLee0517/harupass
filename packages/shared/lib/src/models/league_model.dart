import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'league_model.g.dart';

enum LeagueResult { promoted, stayed, demoted }

@JsonSerializable()
class LeagueGroupModel {
  final String id;
  final String league;
  final List<String> userIds;
  final DateTime createdAt;
  final DateTime? finalizedAt;

  const LeagueGroupModel({
    required this.id,
    required this.league,
    required this.userIds,
    required this.createdAt,
    this.finalizedAt,
  });

  factory LeagueGroupModel.fromJson(Map<String, dynamic> json) =>
      _$LeagueGroupModelFromJson(json);
  Map<String, dynamic> toJson() => _$LeagueGroupModelToJson(this);

  factory LeagueGroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeagueGroupModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      if (data['finalizedAt'] != null)
        'finalizedAt':
            (data['finalizedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}

@JsonSerializable()
class LeagueRankingModel {
  final String userId;
  final int rank;
  final int weeklyScore;
  final String nickname;
  final String profileEmoji;
  final LeagueResult? result;

  const LeagueRankingModel({
    required this.userId,
    required this.rank,
    required this.weeklyScore,
    required this.nickname,
    required this.profileEmoji,
    this.result,
  });

  factory LeagueRankingModel.fromJson(Map<String, dynamic> json) =>
      _$LeagueRankingModelFromJson(json);
  Map<String, dynamic> toJson() => _$LeagueRankingModelToJson(this);
}
