import 'package:cloud_firestore/cloud_firestore.dart';

enum LeagueResult { promoted, stayed, demoted }

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
      LeagueGroupModel(
        id: json['id'] as String,
        league: json['league'] as String,
        userIds: (json['userIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        finalizedAt: json['finalizedAt'] != null
            ? DateTime.parse(json['finalizedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'league': league,
        'userIds': userIds,
        'createdAt': createdAt.toIso8601String(),
        'finalizedAt': finalizedAt?.toIso8601String(),
      };

  factory LeagueGroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeagueGroupModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      if (data['finalizedAt'] != null)
        'finalizedAt':
            (data['finalizedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}

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
      LeagueRankingModel(
        userId: json['userId'] as String,
        rank: json['rank'] as int,
        weeklyScore: json['weeklyScore'] as int,
        nickname: json['nickname'] as String,
        profileEmoji: json['profileEmoji'] as String,
        result: json['result'] != null
            ? LeagueResult.values.byName(json['result'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'rank': rank,
        'weeklyScore': weeklyScore,
        'nickname': nickname,
        'profileEmoji': profileEmoji,
        'result': result?.name,
      };
}
