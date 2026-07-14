import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  testWidgets('Calculator shows initial state', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
    expect(find.text('0'), findsOneWidget);
    expect(find.text('AC'), findsOneWidget);
  });
}
