import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/main.dart';

void main() {
  testWidgets('Splash then Login', (tester) async {
    await tester.pumpWidget(const MoneyTrackerApp());
    expect(find.text('Money Tracker'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
