import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harupass/screens/onboarding/admin_signup_screen.dart';

void main() {
  group('AdminSignupScreen', () {
    Widget buildScreen() {
      final router = GoRouter(
        initialLocation: '/admin-signup',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('role_select')),
          ),
          GoRoute(
            path: '/admin-signup',
            builder: (_, _) => const AdminSignupScreen(),
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

      expect(find.text('회원가입'), findsOneWidget);
      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('signup tab shows form fields', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('별명'), findsOneWidget);
      expect(find.text('이메일'), findsOneWidget);
      expect(find.text('비밀번호'), findsWidgets);
      expect(find.text('가입하기'), findsOneWidget);
    });

    testWidgets('validates empty nickname', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      expect(find.text('별명을 입력해주세요'), findsOneWidget);
    });

    testWidgets('validates empty email', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '별명을 입력하세요'),
        'Test',
      );
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      expect(find.text('이메일을 입력해주세요'), findsOneWidget);
    });

    testWidgets('validates password length', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '별명을 입력하세요'),
        'Test',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'example@email.com'),
        'test@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '6자 이상 입력하세요'),
        '12345',
      );
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      expect(find.text('비밀번호는 6자 이상이어야 합니다'), findsOneWidget);
    });

    testWidgets('validates password confirmation mismatch', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '별명을 입력하세요'),
        'Test',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'example@email.com'),
        'test@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '6자 이상 입력하세요'),
        '123456',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '비밀번호를 다시 입력하세요'),
        '654321',
      );
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      expect(find.text('비밀번호가 일치하지 않습니다'), findsOneWidget);
    });

    testWidgets('login tab shows form fields', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('로그인'));
      await tester.pumpAndSettle();

      expect(find.text('로그인'), findsWidgets);
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
