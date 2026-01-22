
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_finder/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipe_finder/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:recipe_finder/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:recipe_finder/features/recipes/presentation/widgets/animated_favorite_button.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository mockRepository;

  final tRecipe = RecipeEntity(
    id: '1',
    name: 'Test Recipe',
    category: 'Category',
    area: 'Area',
    instructions: 'Instructions',
    thumbUrl: 'url',
    ingredients: [],
    isFavorite: false,
  );

  setUp(() {
    mockRepository = MockRecipeRepository();
    registerFallbackValue(tRecipe);
  });

  Widget createWidgetUnderTest(RecipeEntity recipe) {
    return ProviderScope(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: AnimatedFavoriteButton(recipe: recipe),
        ),
      ),
    );
  }

  testWidgets('should render correctly in inactive state', (WidgetTester tester) async {
    // Arrange
    when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));

    // Act
    await tester.pumpWidget(createWidgetUnderTest(tRecipe));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });

  testWidgets('should render correctly in active state', (WidgetTester tester) async {
    // Arrange
    when(() => mockRepository.getFavorites()).thenAnswer((_) async => Right([tRecipe]));

    // Act
    await tester.pumpWidget(createWidgetUnderTest(tRecipe));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });

  testWidgets('should call repository toggle on tap', (WidgetTester tester) async {
    // Arrange
    when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));
    when(() => mockRepository.toggleFavorite(any())).thenAnswer((_) async => const Right(null));

    // Act
    await tester.pumpWidget(createWidgetUnderTest(tRecipe));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byType(AnimatedFavoriteButton));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 200)); // Finish animation

    // Assert
    verify(() => mockRepository.toggleFavorite(any())).called(1);
  });
}
