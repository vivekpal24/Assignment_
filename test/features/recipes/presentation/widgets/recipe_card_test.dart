
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipe_finder/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:recipe_finder/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:recipe_finder/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';

import '../screens/recipe_list_page_test.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
    RecipeCard.debugTestMode = true;
  });

  final tRecipe = RecipeEntity(
    id: '1',
    name: 'Test Recipe',
    category: 'Test Category',
    area: 'Test Area',
    instructions: 'Instructions',
    thumbUrl: 'https://example.com/image.jpg',
    ingredients: [],
    isFavorite: false,
  );

  Widget createWidgetUnderTest(VoidCallback onTap, {bool isGrid = true, RecipeRepository? mockRepository}) {
    return ProviderScope(
      overrides: [
        if (mockRepository != null)
          recipeRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: RecipeCard(
            recipe: tRecipe,
            onTap: onTap,
            isGrid: isGrid,
          ),
        ),
      ),
    );
  }

  group('RecipeCard', () {
    testWidgets('renders correctly in Grid mode', (WidgetTester tester) async {
      final mockRepository = MockRecipeRepository();
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));
      
      await tester.pumpWidget(createWidgetUnderTest(() {}, isGrid: true, mockRepository: mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('Test Area • Test Category'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('renders correctly in List mode', (WidgetTester tester) async {
      final mockRepository = MockRecipeRepository();
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createWidgetUnderTest(() {}, isGrid: false, mockRepository: mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('Test Area | Test Category'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      final mockRepository = MockRecipeRepository();
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));

      bool tapped = false;
      await tester.pumpWidget(createWidgetUnderTest(() => tapped = true, mockRepository: mockRepository));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard));
      expect(tapped, true);
    });
    
    testWidgets('shows favorite icon only in List mode if isFavorite is true', (WidgetTester tester) async {
       final favRecipe = RecipeEntity(
        id: '1',
        name: 'Test Recipe',
        category: 'C',
        area: 'A',
        instructions: 'I',
        thumbUrl: 'U',
        ingredients: [],
        isFavorite: true,
      );
      
      final mockRepository = MockRecipeRepository();
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => Right([favRecipe]));
      
      // Grid Mode (Implementation now shows animated button in grid)
      await tester.pumpWidget(ProviderScope(
        overrides: [recipeRepositoryProvider.overrideWithValue(mockRepository)],
        child: MaterialApp(home: Scaffold(body: RecipeCard(recipe: favRecipe, onTap: (){}, isGrid: true)))
      ));
      await tester.pumpAndSettle();
      
      // We check for AnimatedFavoriteButton which has a heart icon
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // List Mode (Implementation SHOWS favorite icon at the end)
      await tester.pumpWidget(ProviderScope(
        overrides: [recipeRepositoryProvider.overrideWithValue(mockRepository)],
        child: MaterialApp(home: Scaffold(body: RecipeCard(recipe: favRecipe, onTap: (){}, isGrid: false)))
      ));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsNWidgets(1)); // Only the one at the end for list mode
    });
  });
}
