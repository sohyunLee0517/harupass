import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/invite_code_repository.dart';

enum AuthState { loading, unauthenticated, authenticated }

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;
  final InviteCodeRepository _inviteCodeRepo;

  AuthNotifier(this._authRepo, this._userRepo, this._inviteCodeRepo)
      : super(AuthState.loading) {
    _init();
  }

  UserModel? _user;
  UserModel? get user => _user;

  bool _isSigningIn = false;

  /// 관리대상 아이디를 Firebase 이메일 형식으로 변환
  static String subjectIdToEmail(String id) => '$id@harupass.app';

  Future<void> _init() async {
    _authRepo.authStateChanges().listen((firebaseUser) async {
      if (_isSigningIn) return;

      if (firebaseUser == null) {
        _user = null;
        state = AuthState.unauthenticated;
      } else {
        await _loadUser(firebaseUser.uid);
      }
    });
  }

  Future<void> _loadUser(String uid) async {
    final userModel = await _userRepo.getUser(uid);
    if (userModel != null) {
      _user = userModel;
      state = AuthState.authenticated;
    } else {
      state = AuthState.unauthenticated;
    }
  }

  /// 관리자: 이메일/비밀번호 회원가입
  Future<void> signUpAsAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    state = AuthState.loading;
    _isSigningIn = true;
    try {
      final credential = await _authRepo.signUpWithEmail(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final userModel = UserModel(
        uid: uid,
        role: UserRole.admin,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _userRepo.createUser(userModel);
      _user = userModel;
      state = AuthState.authenticated;
    } on FirebaseAuthException {
      state = AuthState.unauthenticated;
      rethrow;
    } finally {
      _isSigningIn = false;
    }
  }

  /// 관리자: 이메일/비밀번호 로그인
  Future<void> signInAsAdmin({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading;
    _isSigningIn = true;
    try {
      final credential = await _authRepo.signInWithEmail(
        email: email,
        password: password,
      );
      await _loadUser(credential.user!.uid);
    } on FirebaseAuthException {
      state = AuthState.unauthenticated;
      rethrow;
    } finally {
      _isSigningIn = false;
    }
  }

  /// 관리대상: 초대코드 + 아이디/비밀번호로 첫 참여
  Future<void> signUpAsSubject({
    required String inviteCode,
    required String loginId,
    required String password,
    required String nickname,
    required String profileEmoji,
  }) async {
    state = AuthState.loading;
    _isSigningIn = true;
    try {
      // 1. 이메일/비밀번호로 계정 생성
      final email = subjectIdToEmail(loginId);
      final credential = await _authRepo.signUpWithEmail(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      // 2. 초대코드 검증
      final code = await _inviteCodeRepo.validateCode(inviteCode);
      if (code == null) {
        await credential.user?.delete();
        _user = null;
        state = AuthState.unauthenticated;
        throw Exception('유효하지 않은 초대코드입니다');
      }

      // 3. 사용자 문서 생성
      final userModel = UserModel(
        uid: uid,
        role: UserRole.subject,
        name: nickname,
        nickname: nickname,
        profileEmoji: profileEmoji,
        adminId: code.adminId,
        createdAt: DateTime.now(),
      );

      await _userRepo.createUser(userModel);

      // 4. 초대코드 사용 처리
      await _inviteCodeRepo.useCode(inviteCode, uid);

      // 5. 관리자의 subjectIds에 추가
      await _userRepo.addSubjectToAdmin(code.adminId, uid);

      _user = userModel;
      state = AuthState.authenticated;
    } on FirebaseAuthException catch (e) {
      state = AuthState.unauthenticated;
      if (e.code == 'email-already-in-use') {
        throw Exception('이미 사용 중인 아이디입니다');
      }
      rethrow;
    } catch (e) {
      if (state != AuthState.unauthenticated) {
        state = AuthState.unauthenticated;
      }
      rethrow;
    } finally {
      _isSigningIn = false;
    }
  }

  /// 관리대상: 아이디/비밀번호로 재로그인
  Future<void> signInAsSubject({
    required String loginId,
    required String password,
  }) async {
    state = AuthState.loading;
    _isSigningIn = true;
    try {
      final email = subjectIdToEmail(loginId);
      final credential = await _authRepo.signInWithEmail(
        email: email,
        password: password,
      );
      await _loadUser(credential.user!.uid);
    } on FirebaseAuthException {
      state = AuthState.unauthenticated;
      rethrow;
    } finally {
      _isSigningIn = false;
    }
  }

  /// 이메일 중복 확인 (Firestore 조회)
  Future<bool> isEmailAvailable(String email) async {
    final taken = await _userRepo.isEmailTaken(email);
    return !taken;
  }

  /// 관리대상 아이디 중복 확인 (Firestore 조회)
  Future<bool> isSubjectIdAvailable(String loginId) async {
    final email = subjectIdToEmail(loginId);
    final taken = await _userRepo.isEmailTaken(email);
    return !taken;
  }

  /// 관리자 전용 로그아웃
  Future<void> signOut() async {
    await _authRepo.signOut();
    _user = null;
    state = AuthState.unauthenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
    ref.watch(inviteCodeRepositoryProvider),
  ),
);
