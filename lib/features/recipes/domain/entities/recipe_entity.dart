import 'package:equatable/equatable.dart';

class RecipeEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbUrl;
  final String? youtubeUrl;
  final List<Ingredient> ingredients;
  final bool isFavorite; // Added for UI convenience, managed by repo

  const RecipeEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbUrl,
    this.youtubeUrl,
    required this.ingredients,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [id, name, category, area, instructions, thumbUrl, youtubeUrl, ingredients, isFavorite];
  
  RecipeEntity copyWith({bool? isFavorite}) {
    return RecipeEntity(
      id: id,
      name: name,
      category: category,
      area: area,
      instructions: instructions,
      thumbUrl: thumbUrl,
      youtubeUrl: youtubeUrl,
      ingredients: ingredients,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class Ingredient extends Equatable {
  final String name;
  final String measure;

  const Ingredient({required this.name, required this.measure});

  @override
  List<Object?> get props => [name, measure];
}
