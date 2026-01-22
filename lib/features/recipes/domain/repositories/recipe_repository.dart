import 'package:dartz/dartz.dart'; // We need dartz or similar for Either, or just use Record/Result class. 
// User didn't specify fpdart/dartz, but Clean Arch often uses Either<Failure, Success>.
// I'll adds dartz dependencies or use a simple Result class. 
// Given the prompt didn't specify, I will use dartz as it's standard in many Flutter Clean Arch tutorials.
// OR I can use a simple (Failure?, Data?) record or custom Result class to avoid extra deps if I want to be lean.
// Let's stick to standard Either for robustness.
// Wait, I didn't add dartz to pubspec. 
// I'll add dartz.

import '../../../../core/errors/failures.dart';
import '../entities/recipe_entity.dart';

abstract class RecipeRepository {
  Future<Either<Failure, List<RecipeEntity>>> searchRecipes(String query);
  Future<Either<Failure, RecipeEntity>> getRecipeDetail(String id);
  Future<Either<Failure, List<RecipeEntity>>> getRecipesByCategory(String category);
  Future<Either<Failure, List<RecipeEntity>>> getRecipesByArea(String area);
  Future<Either<Failure, List<String>>> getCategories();
  Future<Either<Failure, List<String>>> getAreas(); // Just strings for now or simple objects
  
  // Local storage / Favorites
  Future<Either<Failure, List<RecipeEntity>>> getFavorites();
  Future<Either<Failure, bool>> isFavorite(String id);
  Future<Either<Failure, void>> toggleFavorite(RecipeEntity recipe);
}
