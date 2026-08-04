import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/main.dart';

void main() {
  testWidgets('Delivery App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const SolarisDeliveryApp());
    expect(find.text('Solaris Driver'), findsOneWidget);
  });
}
