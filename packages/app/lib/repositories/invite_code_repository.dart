import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'user_repository.dart';

class InviteCodeRepository {
  final FirebaseFirestore _firestore;

  InviteCodeRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _codesRef =>
      _firestore.collection(FirestorePaths.inviteCodes);

  /// 6자리 랜덤 코드 생성
  String _generateCode() {
    final random = Random();
    return List.generate(
      AppConstants.inviteCodeLength,
      (_) => random.nextInt(10),
    ).join();
  }

  /// 초대코드 발급 (관리자용)
  Future<InviteCodeModel> createInviteCode(String adminId) async {
    // 중복되지 않는 코드 생성
    String code;
    do {
      code = _generateCode();
    } while ((await _codesRef.doc(code).get()).exists);

    final now = DateTime.now();
    final model = InviteCodeModel(
      code: code,
      adminId: adminId,
      createdAt: now,
      expiresAt: now.add(AppConstants.inviteCodeExpiry),
    );

    await _codesRef.doc(code).set({
      'adminId': model.adminId,
      'createdAt': Timestamp.fromDate(model.createdAt),
      'expiresAt': Timestamp.fromDate(model.expiresAt),
      'usedBy': null,
      'status': model.status.name,
    });

    return model;
  }

  /// 초대코드 검증
  Future<InviteCodeModel?> validateCode(String code) async {
    final doc = await _codesRef.doc(code).get();
    if (!doc.exists) return null;

    final model = InviteCodeModel.fromFirestore(doc);
    if (!model.isUsable) return null;

    return model;
  }

  /// 초대코드 사용 처리 (관리대상이 참여 시)
  Future<void> useCode(String code, String subjectId) async {
    await _codesRef.doc(code).update({
      'usedBy': subjectId,
      'status': InviteCodeStatus.used.name,
    });
  }

  /// 관리자의 활성 초대코드 조회
  Future<List<InviteCodeModel>> getActiveCodesForAdmin(String adminId) async {
    final snapshot = await _codesRef
        .where('adminId', isEqualTo: adminId)
        .where('status', isEqualTo: InviteCodeStatus.active.name)
        .get();

    return snapshot.docs
        .map((doc) => InviteCodeModel.fromFirestore(doc))
        .where((code) => code.isUsable)
        .toList();
  }
}

final inviteCodeRepositoryProvider = Provider<InviteCodeRepository>(
  (ref) => InviteCodeRepository(ref.watch(firestoreProvider)),
);
