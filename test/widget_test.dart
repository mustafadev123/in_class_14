import 'package:cloud_courier/main.dart';
import 'package:cloud_courier/models/payload_result.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valid promo payload selects the bundled event image', () {
    final result = validatePayload(const {
      'action': 'update_ui',
      'asset': 'promo',
    });

    expect(result, isA<ValidPayload>());
    expect((result as ValidPayload).asset, CampusAsset.promo);
  });

  test('unsupported asset is rejected with a diagnostic', () {
    final result = validatePayload(const {
      'action': 'update_ui',
      'asset': 'unknown',
    });

    expect(result, isA<InvalidPayload>());
    expect((result as InvalidPayload).reason, contains('unsupported asset'));
  });

  test('missing asset is rejected with a diagnostic', () {
    final result = validatePayload(const {'action': 'update_ui'});

    expect(result, isA<InvalidPayload>());
    expect((result as InvalidPayload).reason, contains('missing'));
  });

  testWidgets('initial screen shows safe default content', (tester) async {
    await tester.pumpWidget(const CloudCourierApp(startMessaging: false));

    expect(find.text('Cloud Courier'), findsOneWidget);
    expect(find.text('Campus updates'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('diagnostic')), 300);
    expect(find.text('Waiting for a cloud message.'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
