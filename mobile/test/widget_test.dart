import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_mobile/main.dart';

void main() {
  testWidgets('Vibe app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VibeApp());
    expect(find.byType(VibeApp), findsOneWidget);
  });
}
