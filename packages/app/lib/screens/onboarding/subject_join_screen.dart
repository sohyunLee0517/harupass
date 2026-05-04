import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/invite_code_repository.dart';
import '../../repositories/user_repository.dart';

class SubjectJoinScreen extends ConsumerStatefulWidget {
  const SubjectJoinScreen({super.key});

  @override
  ConsumerState<SubjectJoinScreen> createState() => _SubjectJoinScreenState();
}

class _SubjectJoinScreenState extends ConsumerState<SubjectJoinScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('관리대상'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '새로 참여'),
            Tab(text: '로그인'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SubjectSignupFlow(),
          _SubjectLoginTab(),
        ],
      ),
    );
  }
}

// ─── 새로 참여: 2단계 플로우 ───

class _SubjectSignupFlow extends ConsumerStatefulWidget {
  const _SubjectSignupFlow();

  @override
  ConsumerState<_SubjectSignupFlow> createState() => _SubjectSignupFlowState();
}

class _SubjectSignupFlowState extends ConsumerState<_SubjectSignupFlow> {
  // Step 1: 초대코드 / Step 2: 회원정보
  int _step = 1;
  String _validatedCode = '';
  String _adminName = '';

  void _onCodeValidated(String code, String adminName) {
    setState(() {
      _validatedCode = code;
      _adminName = adminName;
      _step = 2;
    });
  }

  void _goBackToStep1() {
    setState(() => _step = 1);
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 1) {
      return _InviteCodeStep(onValidated: _onCodeValidated);
    }
    return _SignupFormStep(
      inviteCode: _validatedCode,
      adminName: _adminName,
      onBack: _goBackToStep1,
    );
  }
}

// ─── Step 1: 초대코드 입력 ───

class _InviteCodeStep extends ConsumerStatefulWidget {
  final void Function(String code, String adminName) onValidated;

  const _InviteCodeStep({required this.onValidated});

  @override
  ConsumerState<_InviteCodeStep> createState() => _InviteCodeStepState();
}

class _InviteCodeStepState extends ConsumerState<_InviteCodeStep> {
  final _codeController = TextEditingController();
  bool _isChecking = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final code = _codeController.text.trim();
    if (code.length != AppConstants.inviteCodeLength) {
      setState(() => _errorMessage = '${AppConstants.inviteCodeLength}자리 코드를 입력해주세요');
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final inviteCode =
          await ref.read(inviteCodeRepositoryProvider).validateCode(code);

      if (inviteCode == null) {
        setState(() => _errorMessage = '유효하지 않은 초대코드입니다');
        return;
      }

      // 관리자 이름 가져오기
      final adminUser =
          await ref.read(userRepositoryProvider).getUser(inviteCode.adminId);
      final adminName = adminUser?.name ?? '관리자';

      widget.onValidated(code, adminName);
    } catch (e) {
      setState(() => _errorMessage = '코드 확인 중 오류가 발생했습니다');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              '초대코드를 입력해주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '관리자에게 받은 6자리 코드를 입력하세요',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            TextFormField(
              controller: _codeController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLength: AppConstants.inviteCodeLength,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isChecking ? null : _validateCode,
              child: _isChecking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('확인', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2: 회원정보 입력 ───

class _SignupFormStep extends ConsumerStatefulWidget {
  final String inviteCode;
  final String adminName;
  final VoidCallback onBack;

  const _SignupFormStep({
    required this.inviteCode,
    required this.adminName,
    required this.onBack,
  });

  @override
  ConsumerState<_SignupFormStep> createState() => _SignupFormStepState();
}

class _SignupFormStepState extends ConsumerState<_SignupFormStep> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  String _selectedEmoji = '😊';
  bool _isLoading = false;
  bool _isCheckingId = false;
  bool? _isIdAvailable;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  static const _emojiOptions = [
    '😊', '😎', '🦊', '🐱', '🐶', '🦁',
    '🐻', '🐼', '🐰', '🦄', '🌟', '🚀',
  ];

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _checkIdDuplicate() async {
    final id = _idController.text.trim();
    if (id.isEmpty || id.length < 4) {
      _formKey.currentState?.validate();
      return;
    }

    final idRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!idRegex.hasMatch(id)) {
      _formKey.currentState?.validate();
      return;
    }

    setState(() {
      _isCheckingId = true;
      _isIdAvailable = null;
    });

    try {
      final available =
          await ref.read(authProvider.notifier).isSubjectIdAvailable(id);
      if (mounted) setState(() => _isIdAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _isIdAvailable = null);
    } finally {
      if (mounted) setState(() => _isCheckingId = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isIdAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디 중복확인을 해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signUpAsSubject(
            inviteCode: widget.inviteCode,
            loginId: _idController.text.trim(),
            password: _passwordController.text,
            nickname: _nicknameController.text.trim(),
            profileEmoji: _selectedEmoji,
          );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.code == 'email-already-in-use'
              ? '이미 사용 중인 아이디입니다'
              : '오류가 발생했습니다: ${e.code}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 초대 확인 배너
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${widget.adminName}님이 보낸 초대예요',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onBack,
                      child: const Text('다시 입력'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 아이디/비밀번호
              const Text(
                '로그인 정보를 설정해주세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _idController,
                      onChanged: (_) {
                        if (_isIdAvailable != null) {
                          setState(() => _isIdAvailable = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: '아이디',
                        hintText: '영문, 숫자 4자 이상',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person_outline),
                        suffixIcon: _isIdAvailable == true
                            ? const Icon(Icons.check_circle,
                                color: AppColors.success)
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '아이디를 입력해주세요';
                        }
                        if (value.trim().length < 4) {
                          return '아이디는 4자 이상이어야 합니다';
                        }
                        final idRegex = RegExp(r'^[a-zA-Z0-9_]+$');
                        if (!idRegex.hasMatch(value.trim())) {
                          return '영문, 숫자, 밑줄만 사용 가능합니다';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isCheckingId ? null : _checkIdDuplicate,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isCheckingId
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('중복확인'),
                    ),
                  ),
                ],
              ),
              if (_isIdAvailable == true)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '사용 가능한 아이디입니다',
                    style: TextStyle(color: AppColors.success, fontSize: 13),
                  ),
                ),
              if (_isIdAvailable == false)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '이미 사용 중인 아이디입니다',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '6자 이상',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // 닉네임 + 이모지
              const Text(
                '프로필을 설정해주세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  hintText: '랭킹에 표시될 이름이에요',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                '프로필 이모지',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _emojiOptions.map((emoji) {
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight.withAlpha(51)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('참여하기', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 로그인 탭 ───

class _SubjectLoginTab extends ConsumerStatefulWidget {
  const _SubjectLoginTab();

  @override
  ConsumerState<_SubjectLoginTab> createState() => _SubjectLoginTabState();
}

class _SubjectLoginTabState extends ConsumerState<_SubjectLoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signInAsSubject(
            loginId: _idController.text.trim(),
            password: _passwordController.text,
          );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          switch (e.code) {
            case 'user-not-found':
              _errorMessage = '등록되지 않은 아이디입니다';
            case 'wrong-password':
            case 'invalid-credential':
              _errorMessage = '아이디 또는 비밀번호가 올바르지 않습니다';
            default:
              _errorMessage = '오류가 발생했습니다: ${e.code}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                '아이디와 비밀번호를\n입력해주세요',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '아이디를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('로그인', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
