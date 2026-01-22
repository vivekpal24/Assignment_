import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_finder/core/widgets/app_image_viewer.dart';
import 'package:recipe_finder/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipe_finder/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:recipe_finder/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:recipe_finder/features/recipes/presentation/screens/recipe_detail_page.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
    registerFallbackValue(Uri());
    RecipeDetailPage.debugTestMode = true;
  });

  testWidgets(
    'RecipeDetailPage renders correctly with YouTube player',
    (WidgetTester tester) async {
      final tRecipe = RecipeEntity(
        id: '1',
        name: 'Test Recipe',
        category: 'Test Category',
        area: 'Test Area',
        instructions: 'Step 1. Step 2.',
        thumbUrl: 'https://example.com/image.jpg',
        youtubeUrl: 'https://www.youtube.com/watch?v=aqz-KE-bpKQ',
        ingredients: const [
          Ingredient(name: 'Ingredient 1', measure: '1 cup'),
          Ingredient(name: 'Ingredient 2', measure: '2 tbsp'),
        ],
        isFavorite: false,
      );

      final mockRepository = MockRecipeRepository();
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(mockRepository),
            recipeDetailProvider.overrideWith(
              (ref, recipeId) async => tRecipe,
            ),
          ],
          child: const MaterialApp(
            home: RecipeDetailPage(recipeId: '1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title & info
      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);

      // Video section
      expect(find.text('Video Tutorial'), findsOneWidget);
      expect(find.text('Open in YouTube App'), findsOneWidget);

      // Ingredients tab
      await tester.tap(find.text('Ingredients'));
      await tester.pumpAndSettle();
      expect(find.text('Ingredient 1'), findsOneWidget);

      // Instructions tab
      await tester.tap(find.text('Instructions'));
      await tester.pumpAndSettle();
      expect(find.text('Step 1.'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Step number 1

      // Image Viewer
      await tester.tap(find.byKey(const Key('recipe_image_tap')), warnIfMissed: false);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1)); 
      
      expect(find.byType(AppImageViewer), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    },
  );
}
