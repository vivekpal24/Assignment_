
import '../../domain/entities/recipe_entity.dart';
import 'ingredient_model.dart';
import 'recipe_model.dart';

extension RecipeModelX on RecipeModel {
  RecipeEntity toEntity({bool isFavorite = false}) {
    return RecipeEntity(
      id: id,
      name: name,
      category: category,
      area: area,
      instructions: instructions,
      thumbUrl: thumbUrl,
      youtubeUrl: youtubeUrl,
      ingredients: ingredients.map((e) => Ingredient(name: e.name, measure: e.measure)).toList(),
      isFavorite: isFavorite,
    );
  }
}

extension RecipeEntityX on RecipeEntity {
  RecipeModel toModel() {
     return RecipeModel(
      id: id,
      name: name,
      category: category,
      area: area,
      instructions: instructions,
      thumbUrl: thumbUrl,
      youtubeUrl: youtubeUrl,
      ingredients: ingredients.map((e) => IngredientModel(name: e.name, measure: e.measure)).toList(),
      isFavorite: isFavorite,
     );
  }
}
