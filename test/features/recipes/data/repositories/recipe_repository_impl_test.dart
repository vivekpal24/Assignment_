
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_finder/core/errors/failures.dart';
import 'package:recipe_finder/features/recipes/data/datasources/recipe_local_data_source.dart';
import 'package:recipe_finder/features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'package:recipe_finder/features/recipes/data/models/recipe_model.dart';
import 'package:recipe_finder/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:recipe_finder/features/recipes/domain/entities/recipe_entity.dart';

class MockRemoteDataSource extends Mock implements RecipeRemoteDataSource {}
class MockLocalDataSource extends Mock implements RecipeLocalDataSource {}

void main() {
  late RecipeRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;

  setUp(() {
    registerFallbackValue(RecipeModel(
      id: '', 
      name: '', 
      category: '', 
      area: '', 
      instructions: '', 
      thumbUrl: '', 
      ingredients: const [],
    ));
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    repository = RecipeRepositoryImpl(mockRemoteDataSource, mockLocalDataSource);
  });
  
  final tRecipeModel = RecipeModel(
      id: '1', 
      name: 'Test', 
      category: 'Test', 
      area: 'Test', 
      instructions: 'Test', 
      thumbUrl: 'url',
      ingredients: const [],
  );
  
  final tRecipeEntity = RecipeEntity(
    id: '1', 
    name: 'Test', 
    category: 'Test', 
    area: 'Test', 
    instructions: 'Test', 
    thumbUrl: 'url',
    ingredients: const []
   );

  group('searchRecipes', () {
    const tQuery = 'test';

    test('should return data from remote data source and check favorites', () async {
      // Arrange
      when(() => mockRemoteDataSource.searchRecipes(tQuery))
          .thenAnswer((_) async => [tRecipeModel]);
      when(() => mockLocalDataSource.isFavorite('1'))
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.searchRecipes(tQuery);

      // Assert
      verify(() => mockRemoteDataSource.searchRecipes(tQuery));
      verify(() => mockLocalDataSource.isFavorite('1'));
      expect(result, isA<Right<Failure, List<RecipeEntity>>>());
    });
    
    test('should return ServerFailure when remote data source fails', () async {
      // Arrange
      when(() => mockRemoteDataSource.searchRecipes(tQuery))
          .thenThrow(ServerFailure());

      // Act
      final result = await repository.searchRecipes(tQuery);

      // Assert
      expect(result, isA<Left<Failure, List<RecipeEntity>>>());
    });
  });

  group('Favorites', () {
     test('toggleFavorite should update cache with new favorite status', () async {
       when(() => mockLocalDataSource.isFavorite('1')).thenAnswer((_) async => false);
       when(() => mockLocalDataSource.cacheRecipe(any())).thenAnswer((_) async => Future.value());
       
       await repository.toggleFavorite(tRecipeEntity);
       
       verify(() => mockLocalDataSource.isFavorite('1')).called(1);
       verify(() => mockLocalDataSource.cacheRecipe(any())).called(1);
     });
  });

  group('getRecipeDetail', () {
    const tId = '1';

    test('should return remote data and cache it when call is successful', () async {
      when(() => mockLocalDataSource.getCachedRecipe(tId)).thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.getRecipeDetail(tId)).thenAnswer((_) async => tRecipeModel);
      when(() => mockLocalDataSource.cacheRecipe(any())).thenAnswer((_) async => Future.value());

      final result = await repository.getRecipeDetail(tId);

      verify(() => mockRemoteDataSource.getRecipeDetail(tId));
      verify(() => mockLocalDataSource.cacheRecipe(any()));
      expect(result, equals(Right(tRecipeEntity)));
    });

    test('should return local cache when remote fails', () async {
      when(() => mockLocalDataSource.getCachedRecipe(tId)).thenAnswer((_) async => tRecipeModel);
      when(() => mockRemoteDataSource.getRecipeDetail(tId)).thenThrow(ServerFailure());

      final result = await repository.getRecipeDetail(tId);

      verify(() => mockLocalDataSource.getCachedRecipe(tId));
      expect(result.isRight(), true); 
      result.fold((l) => fail('should be right'), (r) => expect(r.id, '1'));
    });
    
    test('should return failure when remote fails and not in cache', () async {
       when(() => mockLocalDataSource.getCachedRecipe(tId)).thenAnswer((_) async => null);
       when(() => mockRemoteDataSource.getRecipeDetail(tId)).thenThrow(ServerFailure());
       
       final result = await repository.getRecipeDetail(tId);
       
       expect(result, isA<Left>());
    });
  });

  group('getCategories', () {
    test('should return list of strings from remote', () async {
      final tRawCategories = [{'strCategory': 'Beef'}, {'strCategory': 'Chicken'}];
      when(() => mockRemoteDataSource.getCategories()).thenAnswer((_) async => tRawCategories);

      final result = await repository.getCategories();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), ['Beef', 'Chicken']);
    });
    
    test('should filter out invalid category objects', () async {
        final tRawCategories = [{'strCategory': 'Beef'}, {'invalid': 'structure'}];
        when(() => mockRemoteDataSource.getCategories()).thenAnswer((_) async => tRawCategories);
        
        final result = await repository.getCategories();
        
        expect(result.fold((l) => [], (r) => r), ['Beef']);
    });
  });

  group('getFavorites', () {
    test('should return list of recipes from local data source', () async {
      when(() => mockLocalDataSource.getFavorites()).thenAnswer((_) async => [tRecipeModel]);

      final result = await repository.getFavorites();

      verify(() => mockLocalDataSource.getFavorites());
      expect(result.fold((l) => [], (r) => r).length, 1); 
    });
  });
}
