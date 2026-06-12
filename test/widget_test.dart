// Smoke test: the app boots into the splash screen and then the selection page.
import 'package:flutter_test/flutter_test.dart';

import 'package:studioapp/main.dart';

void main() {
  testWidgets('App boots to splash then selection page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Splash shows the brand.
    expect(find.text('DOGANLAR'), findsOneWidget);

    // After the 2s splash timer, it navigates to the selection page.
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Hoş geldiňiz!'), findsOneWidget);
  });
}
