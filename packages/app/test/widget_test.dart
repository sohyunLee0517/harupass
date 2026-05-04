import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harupass/screens/onboarding/role_select_screen.dart';

void main() {
  group('RoleSelectScreen', () {
    testWidgets('renders role selection options', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const RoleSelectScreen(),
          ),
          GoRoute(
            path: '/admin-signup',
            builder: (_, _) => const Scaffold(),
          ),
          GoRoute(
            path: '/subject-join',
            builder: (_, _) => const Scaffold(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('관리자'), findsOneWidget);
      expect(find.text('관리대상'), findsOneWidget);
    });

    testWidgets('shows role descriptions', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const RoleSelectScreen(),
          ),
          GoRoute(
            path: '/admin-signup',
            builder: (_, _) => const Scaffold(),
          ),
          GoRoute(
            path: '/subject-join',
            builder: (_, _) => const Scaffold(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('미션을 등록하고 검수해요'), findsOneWidget);
      expect(find.text('미션을 수행하고 인증해요'), findsOneWidget);
    });
  });
}
