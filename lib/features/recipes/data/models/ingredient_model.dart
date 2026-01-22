import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingredient_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class IngredientModel {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String measure;

  IngredientModel({required this.name, required this.measure});

  factory IngredientModel.fromJson(Map<String, dynamic> json) => _$IngredientModelFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientModelToJson(this);
}
