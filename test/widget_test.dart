import 'package:flutter_test/flutter_test.dart';
import 'package:snapshot/app/app.dart';

void main() {
  testWidgets('home page creates a local mock snapshot', (tester) async {
    await tester.pumpWidget(const SnapshotApp());

    expect(find.text('Create Test Snapshot'), findsOneWidget);
    expect(find.text('View Snapshot History'), findsOneWidget);

    await tester.tap(find.text('Create Test Snapshot'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Created snapshot_'), findsOneWidget);
  });
}
