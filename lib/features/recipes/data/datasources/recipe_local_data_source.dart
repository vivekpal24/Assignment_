
import 'package:hive/hive.dart';
import '../models/recipe_model.dart';
import '../../../../core/errors/failures.dart';

abstract class RecipeLocalDataSource {
  Future<List<RecipeModel>> getCachedRecipes();
  Future<List<RecipeModel>> getFavorites();
  Future<void> cacheRecipe(RecipeModel recipe);
  Future<RecipeModel?> getCachedRecipe(String id);
  Future<bool> isFavorite(String id);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  final Box<RecipeModel> _box;

  RecipeLocalDataSourceImpl(this._box);

  @override
  Future<List<RecipeModel>> getCachedRecipes() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<List<RecipeModel>> getFavorites() async {
    try {
      return _box.values.where((recipe) => recipe.isFavorite).toList();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> cacheRecipe(RecipeModel recipe) async {
     try {
      await _box.put(recipe.id, recipe);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<RecipeModel?> getCachedRecipe(String id) async {
    return _box.get(id);
  }
  
  @override
  Future<bool> isFavorite(String id) async {
    final recipe = _box.get(id);
    return recipe?.isFavorite ?? false;
  }
}
