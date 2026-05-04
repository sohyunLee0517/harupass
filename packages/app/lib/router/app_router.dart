import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/onboarding/role_select_screen.dart';
import '../screens/onboarding/admin_signup_screen.dart';
import '../screens/onboarding/subject_join_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/subject/subject_home_screen.dart';
import 'package:shared/shared.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final authNotifier = ref.read(authProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState == AuthState.authenticated;
      final isOnboarding = state.matchedLocation == '/' ||
          state.matchedLocation == '/admin-signup' ||
          state.matchedLocation == '/subject-join';

      if (!isAuth && !isOnboarding) return '/';
      if (isAuth && isOnboarding) {
        final user = authNotifier.user;
        if (user?.role == UserRole.admin) return '/admin';
        return '/subject';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RoleSelectScreen(),
      ),
      GoRoute(
        path: '/admin-signup',
        builder: (context, state) => const AdminSignupScreen(),
      ),
      GoRoute(
        path: '/subject-join',
        builder: (context, state) => const SubjectJoinScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: '/subject',
        builder: (context, state) => const SubjectHomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('페이지를 찾을 수 없습니다: ${state.error}')),
    ),
  );
});
