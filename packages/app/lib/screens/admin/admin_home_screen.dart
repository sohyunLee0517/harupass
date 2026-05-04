import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import '../../providers/auth_provider.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider.notifier).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('하루패스'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요, ${user?.name ?? ''}님!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '관리자 모드',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _AdminMenuCard(
              icon: Icons.group_add,
              title: '자녀 초대',
              subtitle: '초대코드를 생성하여 자녀를 추가하세요',
              onTap: () => context.go('/admin/invite'),
            ),
            const SizedBox(height: 12),
            _AdminMenuCard(
              icon: Icons.assignment,
              title: '미션 관리',
              subtitle: '오늘의 미션을 등록하고 관리하세요',
              onTap: () {
                // TODO: 미션 관리 화면
              },
            ),
            const SizedBox(height: 12),
            _AdminMenuCard(
              icon: Icons.fact_check,
              title: '검수하기',
              subtitle: '자녀가 제출한 미션을 검수하세요',
              onTap: () {
                // TODO: 검수 화면
              },
            ),
            const SizedBox(height: 12),
            _AdminMenuCard(
              icon: Icons.bar_chart,
              title: '통계',
              subtitle: '자녀의 미션 수행 현황을 확인하세요',
              onTap: () {
                // TODO: 통계 화면
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withAlpha(51),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }
}
