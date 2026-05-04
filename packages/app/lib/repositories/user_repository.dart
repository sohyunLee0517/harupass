import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(FirestorePaths.users);

  /// 사용자 문서 생성
  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toFirestore());
  }

  /// 사용자 조��
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// 사용자 실시간 스트림
  Stream<UserModel?> userStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// 관리자의 관리대상 목록에 추가
  Future<void> addSubjectToAdmin(String adminId, String subjectId) async {
    await _usersRef.doc(adminId).update({
      'subjectIds': FieldValue.arrayUnion([subjectId]),
    });
  }

  /// 이메일 중복 확인 (Firestore에서 직접 조회)
  Future<bool> isEmailTaken(String email) async {
    final snapshot = await _usersRef
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// 관리자의 관리대상 목록 조회
  Future<List<UserModel>> getSubjects(String adminId) async {
    final adminDoc = await getUser(adminId);
    if (adminDoc == null || adminDoc.subjectIds.isEmpty) return [];

    final subjects = <UserModel>[];
    for (final subjectId in adminDoc.subjectIds) {
      final subject = await getUser(subjectId);
      if (subject != null) subjects.add(subject);
    }
    return subjects;
  }
}

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreProvider)),
);
