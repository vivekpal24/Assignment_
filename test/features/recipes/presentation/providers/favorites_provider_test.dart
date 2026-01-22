
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_finder/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipe_finder/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:recipe_finder/features/recipes/presentation/providers/favorites_provider.dart';
import 'package:recipe_finder/features/recipes/presentation/providers/recipe_providers.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository mockRepository;
  late ProviderContainer container;

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
    container = ProviderContainer(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
  });

  group('FavoritesProvider', () {
    test('initial state should be loaded with favorites from repository', () async {
      // Arrange
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => Right([tRecipe]));

      // Act
      final favorites = await container.read(favoritesProvider.future);

      // Assert
      expect(favorites, [tRecipe]);
      verify(() => mockRepository.getFavorites()).called(1);
    });

    test('toggleFavorite should call repository and invalidate state', () async {
      // Arrange
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));
      when(() => mockRepository.toggleFavorite(any())).thenAnswer((_) async => const Right(null));

      // Ensure initialization
      await container.read(favoritesProvider.future);

      // Act
      await container.read(favoritesProvider.notifier).toggleFavorite(tRecipe);
      
      // Force rebuild by reading again
      await container.read(favoritesProvider.future);

      // Assert
      verify(() => mockRepository.toggleFavorite(tRecipe)).called(1);
      // getFavorites called once on init, once on re-read after invalidate
      verify(() => mockRepository.getFavorites()).called(2);
    });

    test('isFavorite should return correct status', () async {
      // Arrange
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => Right([tRecipe]));
      
      // Wait for initialization
      await container.read(favoritesProvider.future);

      // Act & Assert
      final resultTrue = container.read(favoritesProvider.notifier).isFavorite('1');
      final resultFalse = container.read(favoritesProvider.notifier).isFavorite('2');

      expect(resultTrue, true);
      expect(resultFalse, false);
    });
  });

  group('isFavoriteProvider', () {
    test('should reflect changes in favoritesProvider', () async {
      // Arrange
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right([]));
      
      // Initial check
      var isFav = container.read(isFavoriteProvider('1'));
      expect(isFav, false);

      // Update favorites
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => Right([tRecipe]));
      
      // We need to bypass the notifier and just check the family provider behavior
      // Normally favoritesProvider would be invalidated.
      // For a unit test on the family provider, we can just check if it reacts to state changes
      
      // Actually, since isFavoriteProvider watches favoritesProvider.value, 
      // it should update when favoritesProvider updates.
      
      // Trigger a refresh/invalidation manually or via a mocked response change
      container.invalidate(favoritesProvider);
      await container.read(favoritesProvider.future);
      
      isFav = container.read(isFavoriteProvider('1'));
      expect(isFav, true);
    });
  });
}
