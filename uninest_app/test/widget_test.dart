import 'package:flutter_test/flutter_test.dart';
import 'package:uninest_app/main.dart';

void main() {
  testWidgets('Uninest app loads successfully', (WidgetTester tester) async {

    // Build the app
    await tester.pumpWidget(const UninestApp());

    // Allow widgets to render
    await tester.pumpAndSettle();

    // Verify app loaded
    expect(find.byType(UninestApp), findsOneWidget);
  });
}