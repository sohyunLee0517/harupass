import 'package:flutter_test/flutter_test.dart';
import 'package:subject_app/main.dart';

void main() {
  testWidgets('Subject app renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const HaruPassSubjectApp());
    expect(find.text('하루패스 미션'), findsWidgets);
  });
}
