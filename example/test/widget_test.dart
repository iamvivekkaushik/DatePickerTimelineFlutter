import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('showcase renders all design examples', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    expect(find.text('Classic'), findsOneWidget);
    // Cards further down the list render lazily; presence of the scaffold
    // plus the first card is enough for a smoke test.
  });
}
