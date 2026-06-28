import 'package:flutter_test/flutter_test.dart';
import 'package:nima_app/main.dart';

void main() {
  testWidgets('NIMA app starts', (tester) async {
    await tester.pumpWidget(const NimaApp());
    expect(find.text('NIMA'), findsWidgets);
  });
}
