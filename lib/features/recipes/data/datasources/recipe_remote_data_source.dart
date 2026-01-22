import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> searchRecipes(String query);
  Future<RecipeModel> getRecipeDetail(String id);
  Future<List<RecipeModel>> getRecipesByCategory(String category);
  Future<List<RecipeModel>> getRecipesByArea(String area);
  Future<List<dynamic>> getCategories(); // Returns categories list
  Future<List<dynamic>> getAreas(); // Returns areas list
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final DioClient _dioClient;

  RecipeRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.search,
        queryParameters: {ApiConstants.paramSearch: query},
      );
      return _parseRecipes(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<RecipeModel> getRecipeDetail(String id) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.lookup,
        queryParameters: {ApiConstants.paramId: id},
      );
      final recipes = _parseRecipes(response);
      if (recipes.isNotEmpty) {
        return recipes.first;
      } else {
        throw const ServerFailure('Recipe not found');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByCategory(String category) async {
     try {
      final response = await _dioClient.get(
        ApiConstants.filter,
        queryParameters: {ApiConstants.paramCategory: category},
      );
      // Filter endpoint returns partial data (id, name, thumb).
      // Detailed info requires lookup, but for list view this is fine.
      return _parseRecipes(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByArea(String area) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.filter,
        queryParameters: {ApiConstants.paramArea: area},
      );
      return _parseRecipes(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
  
  @override
  Future<List<dynamic>> getCategories() async {
     try {
      final response = await _dioClient.get(ApiConstants.categories);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['categories'] != null) {
          return data['categories'] as List<dynamic>;
        }
      }
      return [];

    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getAreas() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.list,
        queryParameters: {ApiConstants.paramArea: 'list'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['meals'] != null) {
          return data['meals'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  List<RecipeModel> _parseRecipes(Response response) {
    if (response.statusCode == 200 && response.data != null) {
      if (response.data is! Map) return [];
      final data = response.data as Map<String, dynamic>;
      
      if (data['meals'] != null && data['meals'] is List) {
        final List<dynamic> meals = data['meals'];
        return meals.map((json) {
           if (json is Map<String, dynamic>) {
             return RecipeModel.fromJson(json);
           }
           return null;
        })
        .whereType<RecipeModel>()
        .toList();
      }
    }
    return [];
  }
}
