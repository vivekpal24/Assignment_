
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/recipe_local_data_source.dart';
import '../../data/datasources/recipe_remote_data_source.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/recipe_usecases.dart';

// --- Core ---
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final hiveBoxProvider = Provider<Box<RecipeModel>>((ref) {
  throw UnimplementedError('Hive box must be initialized in main.dart and overridden');
});

// --- Data Sources ---
final remoteDataSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  return RecipeRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final localDataSourceProvider = Provider<RecipeLocalDataSource>((ref) {
  return RecipeLocalDataSourceImpl(ref.watch(hiveBoxProvider));
});

// --- Repository ---
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(
    ref.watch(remoteDataSourceProvider),
    ref.watch(localDataSourceProvider),
  );
});

// --- Use Cases ---
final getRecipesProvider = Provider<GetRecipes>((ref) {
  return GetRecipes(ref.watch(recipeRepositoryProvider));
});

final getRecipeDetailProvider = Provider<GetRecipeDetail>((ref) {
  return GetRecipeDetail(ref.watch(recipeRepositoryProvider));
});

final toggleFavoriteProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.watch(recipeRepositoryProvider));
});

final getFavoritesProvider = Provider<GetFavorites>((ref) {
  return GetFavorites(ref.watch(recipeRepositoryProvider));
});


final recipeDetailProvider =
FutureProvider.family<RecipeEntity, String>((ref, recipeId) async {
  final getRecipeDetail = ref.read(getRecipeDetailProvider);
  final result = await getRecipeDetail(recipeId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (recipe) => recipe, // RecipeEntity ✔
  );
});

