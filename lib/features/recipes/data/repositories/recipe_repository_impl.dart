import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';
import '../datasources/recipe_remote_data_source.dart';
import '../models/recipe_mapper.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource _remoteDataSource;
  final RecipeLocalDataSource _localDataSource;

  RecipeRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<RecipeEntity>>> searchRecipes(String query) async {
    try {
      final models = await _remoteDataSource.searchRecipes(query);
      final entities = await Future.wait(models.map((model) async {
        final isFav = await _localDataSource.isFavorite(model.id);
        return model.toEntity(isFavorite: isFav);
      }));
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> getRecipeDetail(String id) async {
    try {
      final cachedModel = await _localDataSource.getCachedRecipe(id);
      final isFav = cachedModel?.isFavorite ?? false;

      try {
        final remoteModel = await _remoteDataSource.getRecipeDetail(id);
        // Map to model with existing favorite status
        final modelToCache = RecipeModel(
          id: remoteModel.id,
          name: remoteModel.name,
          category: remoteModel.category,
          area: remoteModel.area,
          instructions: remoteModel.instructions,
          thumbUrl: remoteModel.thumbUrl,
          youtubeUrl: remoteModel.youtubeUrl,
          ingredients: remoteModel.ingredients,
          isFavorite: isFav,
        );
        await _localDataSource.cacheRecipe(modelToCache);
        return Right(modelToCache.toEntity(isFavorite: isFav));
      } catch (e) {
        if (cachedModel != null) {
          // Fallback to local cache if offline/remote fails
          return Right(cachedModel.toEntity(isFavorite: isFav));
        }
        if (e is Failure) return Left(e);
        return Left(ServerFailure(e.toString()));
      }
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntity>>> getRecipesByArea(
      String area) async {
    try {
      final models = await _remoteDataSource.getRecipesByArea(area);
      final entities = await Future.wait(models.map((model) async {
        final isFav = await _localDataSource.isFavorite(model.id);
        return model.toEntity(isFavorite: isFav);
      }));
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntity>>> getRecipesByCategory(
      String category) async {
    try {
      final models = await _remoteDataSource.getRecipesByCategory(category);
      final entities = await Future.wait(models.map((model) async {
        final isFav = await _localDataSource.isFavorite(model.id);
        return model.toEntity(isFavorite: isFav);
      }));
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final raw = await _remoteDataSource.getCategories();
      final categories = raw
          .where((e) => e is Map<String, dynamic> && e['strCategory'] != null)
          .map((e) => e['strCategory'] as String)
          .toList();
      return Right(categories);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  // ✅ 🔥 THIS IS THE MISSING METHOD (MAIN FIX)
  @override
  Future<Either<Failure, List<String>>> getAreas() async {
    try {
      final raw = await _remoteDataSource.getAreas();
      final areas = raw
          .where((e) => e is Map<String, dynamic> && e['strArea'] != null)
          .map((e) => e['strArea'] as String)
          .toList();
      return Right(areas);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntity>>> getFavorites() async {
    try {
      final models = await _localDataSource.getFavorites();
      final entities =
      models.map((e) => e.toEntity(isFavorite: true)).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String id) async {
    try {
      final result = await _localDataSource.isFavorite(id);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(
      RecipeEntity recipe) async {
    try {
      final isFav = await _localDataSource.isFavorite(recipe.id);
      final modelToCache = recipe.copyWith(isFavorite: !isFav).toModel();
      
      await _localDataSource.cacheRecipe(modelToCache);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
