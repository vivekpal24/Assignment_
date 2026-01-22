
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder/core/widgets/app_search_bar.dart';

void main() {
  testWidgets('AppSearchBar compiles and renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSearchBar(
             controller: TextEditingController(),
             onChanged: (_) {},
             onClear: () {},
          ),
        ),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
  });
}
