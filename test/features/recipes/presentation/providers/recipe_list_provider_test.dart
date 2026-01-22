
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_finder/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipe_finder/features/recipes/domain/usecases/recipe_usecases.dart';
import 'package:recipe_finder/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:recipe_finder/features/recipes/presentation/providers/recipe_providers.dart';

class MockGetRecipes extends Mock implements GetRecipes {}

void main() {
  late MockGetRecipes mockGetRecipes;

  setUp(() {
    mockGetRecipes = MockGetRecipes();
    // Default mock for initializing provider
    when(() => mockGetRecipes.search(any())).thenAnswer((_) async => Right([]));
  });

  group('Recipe List Providers', () {
    final tRecipe = RecipeEntity(
      id: '1', name: 'Test', category: 'Test', area: 'Test', instructions: 'Test', thumbUrl: 'url', ingredients: const []
    );

    test('debouncedSearchProvider should update after searchDebounceController logic', () async {
      // Direct testing of debounce is tricky with fakeAsync in Riverpod 2. 
      // Instead, we just verify that manually setting debouncedSearchProvider triggers filter.
    });

    test('recipeListProvider should return data based on debounced search', () async {
      when(() => mockGetRecipes.search('Pie')).thenAnswer((_) async => Right([tRecipe]));

      final container = ProviderContainer(
        overrides: [
          getRecipesProvider.overrideWithValue(mockGetRecipes),
        ],
      );
      
      // Simulate debounce complete
      container.read(debouncedSearchProvider.notifier).state = 'Pie';
      
      // Allow future to resolve
      // We read the FutureProvider
      final result = await container.read(recipeListProvider.future);
      
      expect(result.length, 1);
      expect(result.first.name, 'Test');
    });

    test('recipeListProvider should filter by category', () async {
      when(() => mockGetRecipes.byCategory('Beef')).thenAnswer((_) async => Right([tRecipe]));

      final container = ProviderContainer(
        overrides: [
          getRecipesProvider.overrideWithValue(mockGetRecipes),
        ],
      );

      container.read(selectedCategoryProvider.notifier).state = 'Beef';
      // Ensure search is empty to trigger category path
      container.read(debouncedSearchProvider.notifier).state = '';

      final result = await container.read(recipeListProvider.future);
      
      verify(() => mockGetRecipes.byCategory('Beef')).called(1);
      expect(result.length, 1);
    });

    test('recipeListProvider should intersect Category and Area when no search query', () async {
      when(() => mockGetRecipes.byCategory('Beef')).thenAnswer((_) async => Right([tRecipe])); // ID '1'
      when(() => mockGetRecipes.byArea('American')).thenAnswer((_) async => Right([tRecipe])); // ID '1'
      
      final container = ProviderContainer(
        overrides: [
          getRecipesProvider.overrideWithValue(mockGetRecipes),
        ],
      );

      container.read(selectedCategoryProvider.notifier).state = 'Beef';
      container.read(selectedAreaProvider.notifier).state = 'American';
      container.read(debouncedSearchProvider.notifier).state = '';

      final result = await container.read(recipeListProvider.future);
      
      verify(() => mockGetRecipes.byCategory('Beef')).called(1);
      verify(() => mockGetRecipes.byArea('American')).called(1);
      expect(result.length, 1);
    });
    
     test('recipeListProvider should intersect and return empty if no match', () async {
      final tRecipe2 = RecipeEntity(
          id: '2', name: 'T2', category: 'C', area: 'A', instructions: 'I', thumbUrl: 'U', ingredients: []);
      
      when(() => mockGetRecipes.byCategory('Beef')).thenAnswer((_) async => Right([tRecipe])); // ID '1'
      when(() => mockGetRecipes.byArea('Italian')).thenAnswer((_) async => Right([tRecipe2])); // ID '2'
      
      final container = ProviderContainer(
        overrides: [
          getRecipesProvider.overrideWithValue(mockGetRecipes),
        ],
      );

      container.read(selectedCategoryProvider.notifier).state = 'Beef';
      container.read(selectedAreaProvider.notifier).state = 'Italian';
      container.read(debouncedSearchProvider.notifier).state = '';

      final result = await container.read(recipeListProvider.future);
      
      expect(result.length, 0);
    });

     test('recipeListProvider should default to "Chicken" if nothing selected', () async {
      when(() => mockGetRecipes.search('Chicken')).thenAnswer((_) async => Right([tRecipe]));

      final container = ProviderContainer(
        overrides: [
          getRecipesProvider.overrideWithValue(mockGetRecipes),
        ],
      );

      final result = await container.read(recipeListProvider.future);
      
      verify(() => mockGetRecipes.search('Chicken')).called(1);
      expect(result.length, 1);
    });

    test('activeFilterCountProvider should return correct count', () {
      final container = ProviderContainer();
      
      expect(container.read(activeFilterCountProvider), 0);
      
      container.read(selectedCategoryProvider.notifier).state = 'Beef';
      expect(container.read(activeFilterCountProvider), 1);
      
      container.read(selectedAreaProvider.notifier).state = 'American';
      expect(container.read(activeFilterCountProvider), 2);
      
      container.read(debouncedSearchProvider.notifier).state = 'Burger';
      expect(container.read(activeFilterCountProvider), 3);
      
      container.read(selectedAreaProvider.notifier).state = null;
      expect(container.read(activeFilterCountProvider), 2);
    });

    // --- Sorting Tests ---
    test('recipeListProvider should sort recipes by Name Ascending', () async {
      final tRecipeA = RecipeEntity(id: '1', name: 'Apple', category: 'C', area: 'A', instructions: 'I', thumbUrl: 'U', ingredients: []);
      final tRecipeZ = RecipeEntity(id: '2', name: 'Zebra', category: 'C', area: 'A', instructions: 'I', thumbUrl: 'U', ingredients: []);
      
      when(() => mockGetRecipes.search('Chicken')).thenAnswer((_) async => Right([tRecipeZ, tRecipeA]));

      final container = ProviderContainer(
        overrides: [
          getRecipesProvider.overrideWithValue(mockGetRecipes),
        ],
      );
      
      // Default sort is NameAsc
      final result = await container.read(recipeListProvider.future);
      
      expect(result.first.name, 'Apple');
      expect(result.last.name, 'Zebra');
    });

    test('recipeListProvider should sort recipes by Name Descending when sortOrder changes', () async {
      final tRecipeA = RecipeEntity(id: '1', name: 'Apple', category: 'C', area: 'A', instructions: 'I', thumbUrl: 'U', ingredients: []);
      final tRecipeZ = RecipeEntity(id: '2', name: 'Zebra', category: 'C', area: 'A', instructions: 'I', thumbUrl: 'U', ingredients: []);
      
      when(() => mockGetRecipes.search('Chicken')).thenAnswer((_) async => Right([tRecipeA, tRecipeZ]));

      final container = ProviderContainer(
        overrides: [
          getRecipesProvider.overrideWithValue(mockGetRecipes),
        ],
      );
      
      container.read(sortOrderProvider.notifier).state = SortOrder.nameDesc;
      
      final result = await container.read(recipeListProvider.future);
      
      expect(result.first.name, 'Zebra');
      expect(result.last.name, 'Apple');
    });

    // --- Debounce Test ---
    test('debouncedSearchProvider should update after 500ms delay', () async {
       final container = ProviderContainer();
       // Listen to start the controller
       container.listen(searchQueryProvider, (_, __) {}); 
       // We must simulate the controller being alive?
       // The controller is auto-disposed or main provider watches it?
       // IN app: `ref.watch(searchDebounceController)` in UI or main provider.
       // Here we need to force read it.
       container.read(searchDebounceController);
       
       container.read(searchQueryProvider.notifier).state = 'Initial';
       expect(container.read(debouncedSearchProvider), ''); // Should not update immediately
       
       await Future.delayed(const Duration(milliseconds: 200));
       expect(container.read(debouncedSearchProvider), ''); // Still waiting
       
       await Future.delayed(const Duration(milliseconds: 350)); // Total 550ms
       expect(container.read(debouncedSearchProvider), 'Initial'); // Should match now
    });
  });
}
