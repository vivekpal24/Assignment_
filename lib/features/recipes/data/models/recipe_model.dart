import 'ingredient_model.dart';
import 'package:hive/hive.dart';



@HiveType(typeId: 0)
// Manually serialized
class RecipeModel {
// ...
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final String area;
  @HiveField(4)
  final String instructions;
  @HiveField(5)
  final String thumbUrl;
  @HiveField(6)
  final String? youtubeUrl;
  
  @HiveField(7)
  final List<IngredientModel> ingredients;

  @HiveField(8)
  final bool isFavorite;

  RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbUrl,
    this.youtubeUrl,
    this.ingredients = const [],
    this.isFavorite = false,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // Standard fields
    final String id = json['idMeal'] as String? ?? '';
    final String name = json['strMeal'] as String? ?? '';
    final String category = json['strCategory'] as String? ?? '';
    final String area = json['strArea'] as String? ?? '';
    final String instructions = json['strInstructions'] as String? ?? '';
    final String thumbUrl = json['strMealThumb'] as String? ?? '';
    final String? youtubeUrl = json['strYoutube'] as String?;

    // Dynamic Ingredients Mapping
    final List<IngredientModel> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      
      if (ingredient != null && ingredient is String && ingredient.trim().isNotEmpty) {
        ingredients.add(IngredientModel(
          name: ingredient.trim(),
          measure: (measure != null && measure is String) ? measure.trim() : '',
        ));
      }
    }

    return RecipeModel(
      id: id,
      name: name,
      category: category,
      area: area,
      instructions: instructions,
      thumbUrl: thumbUrl,
      youtubeUrl: youtubeUrl,
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    // Basic fields
    final val = <String, dynamic>{
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbUrl,
      'strYoutube': youtubeUrl,
    };
    
    // Flatten ingredients back to strIngredient1...20 ?
    // Or just store 'ingredients': [...] ?
    // The requirement says "RecipeModel with fromJson and toJson". 
    // Usually toJson matches the API structure if we were sending it back.
    // The API structure is flat. Let's flatten it back to be safe.
    
    for (int i = 0; i < ingredients.length && i < 20; i++) {
      val['strIngredient${i+1}'] = ingredients[i].name;
      val['strMeasure${i+1}'] = ingredients[i].measure;
    }
    
    return val;
  }
}

// End of file
