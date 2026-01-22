
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recipe_entity.dart';
import 'recipe_providers.dart';

class FavoritesNotifier extends AsyncNotifier<List<RecipeEntity>> {
  @override
  FutureOr<List<RecipeEntity>> build() async {
    final getFavorites = ref.read(getFavoritesProvider);
    final result = await getFavorites();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (favorites) => favorites,
    );
  }

  Future<void> toggleFavorite(RecipeEntity recipe) async {
    final toggleFavoriteUseCase = ref.read(toggleFavoriteProvider);
    
    final result = await toggleFavoriteUseCase(recipe);
    
    result.fold(
      (failure) => null, // In production, we'd show an error message
      (_) {
        // Refresh the list after toggling to ensure UI consistency
        ref.invalidateSelf();
      },
    );
  }

  bool isFavorite(String recipeId) {
    if (state.value == null) return false;
    return state.value!.any((r) => r.id == recipeId);
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<RecipeEntity>>(
  () => FavoritesNotifier(),
);

final isFavoriteProvider = Provider.family<bool, String>((ref, id) {
  final favorites = ref.watch(favoritesProvider).value ?? [];
  return favorites.any((r) => r.id == id);
});
