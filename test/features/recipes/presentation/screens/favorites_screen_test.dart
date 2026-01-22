import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_finder/core/constants/app_strings.dart';
import 'package:recipe_finder/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:recipe_finder/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:recipe_finder/features/recipes/presentation/screens/favorites_screen.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  testWidgets('FavoritesScreen shows empty message when no favorites', (WidgetTester tester) async {
    final mockRepository = MockRecipeRepository();
    when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      ),
    );
     // Pump to allow the FutureProvider/StateNotifier to resolve
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noFavorites), findsOneWidget);
  });
}
