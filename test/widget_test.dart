import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_pos/auth/demo_auth.dart';
import 'package:restaurant_pos/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('login requires a valid email format', (tester) async {
    await tester.pumpWidget(const RestaurantPosApp());

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, 'Admin@123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Show All'), findsNothing);
  });

  testWidgets('demo credentials open the POS dashboard', (tester) async {
    await tester.pumpWidget(const RestaurantPosApp());

    await tester.enterText(find.byType(TextFormField).first, DemoAuth.email);
    await tester.enterText(find.byType(TextFormField).last, DemoAuth.password);
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Show All'), findsOneWidget);
    expect(find.text('Veg Spring Roll'), findsOneWidget);
  });
}
