
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class GetRecipes {
  final RecipeRepository repository;

  GetRecipes(this.repository);

  /// Search recipes by name
  Future<Either<Failure, List<RecipeEntity>>> search(String query) {
    return repository.searchRecipes(query);
  }
  
  /// Get recipes by category
  Future<Either<Failure, List<RecipeEntity>>> byCategory(String category) {
    return repository.getRecipesByCategory(category);
  }
  
  /// Get recipes by area
  Future<Either<Failure, List<RecipeEntity>>> byArea(String area) {
    return repository.getRecipesByArea(area);
  }
  
  /// Get list of categories
  Future<Either<Failure, List<String>>> getCategories() {

    return repository.getCategories();
  }

  /// Get list of areas
  Future<Either<Failure, List<String>>> getAreas() {
    return repository.getAreas();
  }
}

class GetRecipeDetail {
  final RecipeRepository repository;

  GetRecipeDetail(this.repository);

  Future<Either<Failure, RecipeEntity>> call(String id) {
    return repository.getRecipeDetail(id);
  }
}

class ToggleFavorite {
  final RecipeRepository repository;

  ToggleFavorite(this.repository);

  Future<Either<Failure, void>> call(RecipeEntity recipe) {
    return repository.toggleFavorite(recipe);
  }
}

class GetFavorites {
  final RecipeRepository repository;

  GetFavorites(this.repository);

  Future<Either<Failure, List<RecipeEntity>>> call() {
    return repository.getFavorites();
  }
}
