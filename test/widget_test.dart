import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_roost/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('FlockMateApp smoke test and launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: GoldenRoostApp()));

    // Initial pump (renders splash screen and app shell)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify app renders
    expect(find.byType(GoldenRoostApp), findsOneWidget);
  });
}
