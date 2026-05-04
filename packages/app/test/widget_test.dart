import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harupass/main.dart';

void main() {
  group('HaruPassApp', () {
    testWidgets('renders role select screen on start', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: HaruPassApp()),
      );
      await tester.pumpAndSettle();

      expect(find.text('하루패스'), findsOneWidget);
      expect(find.text('관리자'), findsOneWidget);
      expect(find.text('관리대상'), findsOneWidget);
    });

    testWidgets('shows role descriptions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: HaruPassApp()),
      );
      await tester.pumpAndSettle();

      expect(find.text('미션을 등록하고 검수해요'), findsOneWidget);
      expect(find.text('미션을 수행하고 인증해요'), findsOneWidget);
    });
  });
}
