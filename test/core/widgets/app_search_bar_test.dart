
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder/core/widgets/app_search_bar.dart';

void main() {
  group('AppSearchBar', () {
    testWidgets('renders correctly with hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBar(
              controller: TextEditingController(),
              onChanged: (_) {},
              onClear: () {},
              hintText: 'Custom Hint',
            ),
          ),
        ),
      );

      expect(find.text('Custom Hint'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('calls onChanged when text is entered', (WidgetTester tester) async {
      String? changedText;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBar(
              controller: TextEditingController(),
              onChanged: (val) => changedText = val,
              onClear: () {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Chicken');
      expect(changedText, 'Chicken');
    });

    testWidgets('shows clear button only when text is present', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBar(
              controller: controller,
              onChanged: (_) {},
              onClear: () {},
            ),
          ),
        ),
      );

      // Initially empty, no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'A');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Clear text via controller manually (simulating outside change)
      // Note: AppSearchBar listens to controller, so this should work if we pump
      controller.clear();
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('calls onClear when clear button is pressed', (WidgetTester tester) async {
      bool clearCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBar(
              controller: TextEditingController(text: 'Initial'),
              onChanged: (_) {},
              onClear: () => clearCalled = true,
            ),
          ),
        ),
      );

      await tester.pump(); // Ensure init state is processed
      expect(find.byIcon(Icons.clear), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.clear));
      expect(clearCalled, true);
    });
  });
}
