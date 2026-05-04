import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harupass/main.dart';

void main() {
  group('AdminSignupScreen', () {
    Future<void> navigateToAdminSignup(WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: HaruPassApp()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('관리자'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows form fields', (tester) async {
      await navigateToAdminSignup(tester);

      expect(find.text('별명'), findsOneWidget);
      expect(find.text('이메일'), findsOneWidget);
      expect(find.text('중복확인'), findsOneWidget);
      expect(find.text('가입하기'), findsOneWidget);
    });

    testWidgets('validates empty nickname', (tester) async {
      await navigateToAdminSignup(tester);

      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      expect(find.text('별명을 입력해주세요'), findsOneWidget);
    });

    testWidgets('validates empty email', (tester) async {
      await navigateToAdminSignup(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, '별명을 입력하세요'),
        'Test',
      );
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      expect(find.text('이메일을 입력해주세요'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      await navigateToAdminSignup(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, '별명을 입력하세요'),
        'Test',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'example@email.com'),
        'notanemail',
      );
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsOneWidget);
    });

    testWidgets('email duplicate check button works', (tester) async {
      await navigateToAdminSignup(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'example@email.com'),
        'test@test.com',
      );
      await tester.tap(find.text('중복확인'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('사용 가능한 이메일입니다'), findsOneWidget);
    });

    testWidgets('shows snackbar if email not verified', (tester) async {
      await navigateToAdminSignup(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, '별명을 입력하세요'),
        'Test Admin',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'example@email.com'),
        'test@test.com',
      );
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      expect(find.text('이메일 중복확인을 해주세요'), findsOneWidget);
    });

    testWidgets('successful signup navigates to admin home', (tester) async {
      await navigateToAdminSignup(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, '별명을 입력하세요'),
        'Test Admin',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'example@email.com'),
        'test@test.com',
      );

      // 중복확인 먼저
      await tester.tap(find.text('중복확인'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // 가입
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      expect(find.text('관리자 모드'), findsOneWidget);
    });

    testWidgets('back button returns to role select', (tester) async {
      await navigateToAdminSignup(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('어떤 역할로 시작하시겠어요?'), findsOneWidget);
    });
  });
}
