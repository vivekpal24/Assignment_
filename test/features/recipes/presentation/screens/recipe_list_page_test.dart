import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_finder/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipe_finder/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:recipe_finder/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:recipe_finder/features/recipes/presentation/screens/recipe_list_page.dart';
import 'package:recipe_finder/features/recipes/presentation/widgets/recipe_card.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
    RecipeListPage.debugTestMode = true;
    RecipeCard.debugTestMode = true;
  });
  testWidgets('RecipeListPage has SearchBar', (WidgetTester tester) async {
    final mockRepository = MockRecipeRepository();
    
    // Mock initial search call which happens on init
    // Mock initial search call which happens on init
    when(() => mockRepository.searchRecipes(any())).thenAnswer((_) async => const Right([]));
    when(() => mockRepository.getCategories()).thenAnswer((_) async => const Right(['Chicken', 'Beef']));
    when(() => mockRepository.getAreas()).thenAnswer((_) async => const Right(['American', 'British']));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: RecipeListPage(),
        ),
      ),
    );
    
    // Pump to settle any initial async calls
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget); // AppSearchBar contains TextField
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Chicken'), findsAny); // Category Chip
    expect(find.text('American'), findsAny); // Area Chip
  });

  testWidgets('View toggle button switches between Grid and List', (WidgetTester tester) async {
    final mockRepository = MockRecipeRepository();
    
    // Mock data to ensure list is populated
    final tRecipes = [
      RecipeEntity(id: '1', name: 'R1', category: 'C', area: 'A', instructions: 'I', thumbUrl: 'U', ingredients: []),
    ];
    
    when(() => mockRepository.searchRecipes(any())).thenAnswer((_) async => Right(tRecipes));
    when(() => mockRepository.getCategories()).thenAnswer((_) async => const Right([]));
    when(() => mockRepository.getAreas()).thenAnswer((_) async => const Right([]));
    when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));
    // Also mock calls that might happen due to provider initialization
    when(() => mockRepository.isFavorite(any())).thenAnswer((_) async => const Right(false));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: RecipeListPage(),
        ),
      ),
    );
    
    await tester.pumpAndSettle(); // Wait for data to load

    // Initial state: Grid View (default)
    expect(find.byKey(const ValueKey('grid')), findsOneWidget);
    expect(find.byKey(const ValueKey('list')), findsNothing);
    expect(find.byIcon(Icons.view_list), findsOneWidget); // Icon to switch TO list

    // Tap toggle button
    await tester.tap(find.byIcon(Icons.view_list));
    await tester.pumpAndSettle();

    // New state: List View
    expect(find.byKey(const ValueKey('list')), findsOneWidget);
    expect(find.byKey(const ValueKey('grid')), findsNothing);
    expect(find.byIcon(Icons.grid_view), findsOneWidget); // Icon to switch TO grid
  });

}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

