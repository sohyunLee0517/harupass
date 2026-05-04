import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harupass/main.dart';

void main() {
  group('SubjectJoinScreen', () {
    Future<void> navigateToSubjectJoin(WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: HaruPassApp()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('관리대상'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows form fields', (tester) async {
      await navigateToSubjectJoin(tester);

      expect(find.text('초대코드를 입력해주세요'), findsOneWidget);
      expect(find.text('닉네임을 정해주세요'), findsOneWidget);
      expect(find.text('프로필 이모지를 선택해주세요'), findsOneWidget);
      expect(find.text('참여하기'), findsOneWidget);
    });

    testWidgets('shows emoji picker options', (tester) async {
      await navigateToSubjectJoin(tester);

      expect(find.text('😊'), findsOneWidget);
      expect(find.text('😎'), findsOneWidget);
      expect(find.text('🦊'), findsOneWidget);
    });

    testWidgets('validates empty invite code', (tester) async {
      await navigateToSubjectJoin(tester);

      await tester.tap(find.text('참여하기'));
      await tester.pumpAndSettle();

      expect(find.text('6자리 코드를 입력해주세요'), findsOneWidget);
    });

    testWidgets('validates empty nickname', (tester) async {
      await navigateToSubjectJoin(tester);

      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.tap(find.text('참여하기'));
      await tester.pumpAndSettle();

      expect(find.text('닉네임을 입력해주세요'), findsOneWidget);
    });

    testWidgets('successful join navigates to subject home', (tester) async {
      await navigateToSubjectJoin(tester);

      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.enterText(find.byType(TextFormField).last, 'TestKid');
      await tester.tap(find.text('참여하기'));
      await tester.pumpAndSettle();

      expect(find.text('오늘의 미션'), findsOneWidget);
    });

    testWidgets('back button returns to role select', (tester) async {
      await navigateToSubjectJoin(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('어떤 역할로 시작하시겠어요?'), findsOneWidget);
    });
  });
}
