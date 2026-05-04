import 'package:flutter_test/flutter_test.dart';
import 'package:admin_app/main.dart';

void main() {
  testWidgets('Admin app renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const HaruPassAdminApp());
    expect(find.text('하루패스'), findsWidgets);
    expect(find.text('관리자 앱'), findsOneWidget);
  });
}
