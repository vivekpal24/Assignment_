
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recipe_entity.dart';
import 'recipe_providers.dart';

// --- Enums ---
enum SortOrder {
  nameAsc,
  nameDesc,
}

// --- View State Providers ---

/// Toggles between Grid (true) and List (false) view
final viewModeProvider = StateProvider<bool>((ref) => true);

/// Current Sort Order
final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.nameAsc);

/// Selected Category Filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Selected Area Filter
final selectedAreaProvider = StateProvider<String?>((ref) => null);

// --- Search Providers ---

/// Raw Search Query (connected to text field)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Debounced Search Query (used for API calls)
/// Updates 500ms after searchQueryProvider changes
final debouncedSearchProvider = StateProvider<String>((ref) => '');

/// Controller provider to manage the debounce logic
final searchDebounceController = Provider<void>((ref) {
  Timer? timer;
  
  ref.listen<String>(searchQueryProvider, (previous, next) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 500), () {
      ref.read(debouncedSearchProvider.notifier).state = next;
    });
  });
  
  // Cleanup
  ref.onDispose(() {
    timer?.cancel();
  });
});


// --- Mappings for UI ---
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final result = await ref.read(getRecipesProvider).getCategories();
  return result.fold((l) => [], (r) => r);
});

final areasProvider = FutureProvider<List<String>>((ref) async {
  final result = await ref.read(getRecipesProvider).getAreas();
  return result.fold((l) => [], (r) => r);
});

// --- Main List Provider ---


// --- Active Filter Count ---
final activeFilterCountProvider = Provider<int>((ref) {
  int count = 0;
  if (ref.watch(debouncedSearchProvider).isNotEmpty) count++;
  if (ref.watch(selectedCategoryProvider) != null) count++;
  if (ref.watch(selectedAreaProvider) != null) count++;
  return count;
});

final recipeListProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  // Ensure the debounce controller is alive
  ref.watch(searchDebounceController);
  
  // Watch inputs
  final query = ref.watch(debouncedSearchProvider);
  final category = ref.watch(selectedCategoryProvider);
  final area = ref.watch(selectedAreaProvider);
  final sortOrder = ref.watch(sortOrderProvider);
  
  final getRecipes = ref.watch(getRecipesProvider);
  
  List<RecipeEntity> recipes = [];
  
  // 1. Fetching Logic
  if (query.isNotEmpty) {
     // Scenario A: Search (Returns full details, so we can filter locally)
     final result = await getRecipes.search(query);
     recipes = result.fold((l) => [], (r) => r);
     
     // Local filtering on full details
     if (category != null) {
       recipes = recipes.where((r) => r.category == category).toList();
     }
     if (area != null) {
       recipes = recipes.where((r) => r.area == area).toList();
     }
  } else {
    // Scenario B: No Search (API partial data)
    if (category != null && area != null) {
      // Intersection: Fetch both lists and find common IDs
      final catResult = await getRecipes.byCategory(category);
      final areaResult = await getRecipes.byArea(area);
      
      final catList = catResult.fold((l) => <RecipeEntity>[], (r) => r);
      final areaList = areaResult.fold((l) => <RecipeEntity>[], (r) => r);
      
      final areaIds = areaList.map((e) => e.id).toSet();
      recipes = catList.where((e) => areaIds.contains(e.id)).toList();
      
    } else if (category != null) {
       final result = await getRecipes.byCategory(category);
       recipes = result.fold((l) => [], (r) => r);
    } else if (area != null) {
        final result = await getRecipes.byArea(area);
        recipes = result.fold((l) => [], (r) => r);
    } else {
      // Default initial load
      final result = await getRecipes.search('Chicken');
      recipes = result.fold((l) => [], (r) => r);
    }
  }
  
  // 2. Sorting
  // ... (sorting logic remains the same)
  recipes.sort((a, b) {
    switch (sortOrder) {
      case SortOrder.nameAsc:
        return a.name.compareTo(b.name);
      case SortOrder.nameDesc:
        return b.name.compareTo(a.name);
    }
  });

  return recipes;
});

// --- Actions (Helper class or top-level functions) ---
// We can use the StateNotifier.notifier.state for updates to simple providers.
// But we might want a Facade class if complex logic arises.
// For now, updating the providers directly from UI is "No setState".
