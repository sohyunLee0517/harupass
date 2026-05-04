import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harupass/screens/onboarding/subject_join_screen.dart';

void main() {
  group('SubjectJoinScreen', () {
    Widget buildScreen() {
      final router = GoRouter(
        initialLocation: '/subject-join',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('role_select')),
          ),
          GoRoute(
            path: '/subject-join',
            builder: (_, _) => const SubjectJoinScreen(),
          ),
        ],
      );

      return ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('shows signup and login tabs', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('새로 참여'), findsOneWidget);
      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('signup tab shows invite code input first', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('초대코드를 입력해주세요'), findsOneWidget);
      expect(find.text('확인'), findsOneWidget);
    });

    testWidgets('shows emoji picker options', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Step 1에서는 이모지가 보이지 않음
      expect(find.text('😊'), findsNothing);
    });

    testWidgets('login tab shows id and password fields', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // '로그인' 탭 탭 (탭 바에서)
      await tester.tap(find.byType(Tab).last);
      await tester.pumpAndSettle();

      expect(find.text('아이디'), findsOneWidget);
      expect(find.text('비밀번호'), findsOneWidget);
    });

    testWidgets('back button returns to role select', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('role_select'), findsOneWidget);
    });
  });
}
