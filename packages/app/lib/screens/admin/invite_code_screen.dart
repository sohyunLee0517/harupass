import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/invite_code_repository.dart';

class InviteCodeScreen extends ConsumerStatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  ConsumerState<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends ConsumerState<InviteCodeScreen> {
  InviteCodeModel? _generatedCode;
  bool _isGenerating = false;
  List<InviteCodeModel> _activeCodes = [];
  bool _isLoadingCodes = true;

  @override
  void initState() {
    super.initState();
    _loadActiveCodes();
  }

  Future<void> _loadActiveCodes() async {
    final user = ref.read(authProvider.notifier).user;
    if (user == null) return;

    try {
      final codes = await ref
          .read(inviteCodeRepositoryProvider)
          .getActiveCodesForAdmin(user.uid);
      if (mounted) {
        setState(() {
          _activeCodes = codes;
          _isLoadingCodes = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCodes = false);
    }
  }

  Future<void> _generateCode() async {
    final user = ref.read(authProvider.notifier).user;
    if (user == null) return;

    setState(() => _isGenerating = true);
    try {
      final code = await ref
          .read(inviteCodeRepositoryProvider)
          .createInviteCode(user.uid);
      setState(() {
        _generatedCode = code;
        _activeCodes.insert(0, code);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('코드 생성 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('초대코드가 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('자녀 초대'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '초대코드를 생성하여\n자녀에게 전달해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '코드는 24시간 동안 유효합니다',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // 생성된 코드 표시
            if (_generatedCode != null) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '초대코드',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _generatedCode!.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _copyCode(_generatedCode!.code),
                      icon:
                          const Icon(Icons.copy, color: Colors.white, size: 18),
                      label: const Text(
                        '복사하기',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateCode,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add),
              label: Text(
                _generatedCode == null ? '초대코드 생성' : '새 코드 생성',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 32),

            // 활성 코드 목록
            if (!_isLoadingCodes && _activeCodes.isNotEmpty) ...[
              const Text(
                '활성 초대코드',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _activeCodes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final code = _activeCodes[index];
                    final remaining =
                        code.expiresAt.difference(DateTime.now());
                    final hours = remaining.inHours;
                    final minutes = remaining.inMinutes % 60;

                    return Card(
                      child: ListTile(
                        title: Text(
                          code.code,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                          ),
                        ),
                        subtitle: Text('남은 시간: $hours시간 $minutes분'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyCode(code.code),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (_isLoadingCodes)
              const Center(child: CircularProgressIndicator()),

            if (!_isLoadingCodes && _activeCodes.isEmpty && _generatedCode == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_add_outlined,
                        size: 64,
                        color: AppColors.textHint.withAlpha(128),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '아직 생성된 초대코드가 없어요',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
