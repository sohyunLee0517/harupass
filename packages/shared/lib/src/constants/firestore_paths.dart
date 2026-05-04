class FirestorePaths {
  FirestorePaths._();

  // Users
  static const String users = 'users';
  static String user(String userId) => 'users/$userId';
  static String score(String userId) => 'users/$userId/score';

  // Invite Codes
  static const String inviteCodes = 'inviteCodes';
  static String inviteCode(String code) => 'inviteCodes/$code';

  // Todos
  static String todosDaily(String userId, String date) =>
      'todos/$userId/daily/$date/items';
  static String todoItem(String userId, String date, String todoId) =>
      'todos/$userId/daily/$date/items/$todoId';

  // Templates
  static String templates(String userId) => 'templates/$userId';
  static String template(String userId, String templateId) =>
      'templates/$userId/$templateId';

  // Daily State
  static String dailyState(String userId, String date) =>
      'dailyState/$userId/$date';

  // Self Locks
  static String selfLocks(String userId) => 'selfLocks/$userId';
  static String selfLock(String userId, String lockId) =>
      'selfLocks/$userId/$lockId';

  // Mission Proposals
  static String missionProposals(String userId) =>
      'missionProposals/$userId';
  static String missionProposal(String userId, String proposalId) =>
      'missionProposals/$userId/$proposalId';

  // Leagues
  static String leagueGroups(String yearWeek) =>
      'leagues/$yearWeek/groups';
  static String leagueGroup(String yearWeek, String groupId) =>
      'leagues/$yearWeek/groups/$groupId';
  static String leagueRankings(String yearWeek, String groupId) =>
      'leagues/$yearWeek/groups/$groupId/rankings';
  static String leagueRanking(
          String yearWeek, String groupId, String userId) =>
      'leagues/$yearWeek/groups/$groupId/rankings/$userId';
}
