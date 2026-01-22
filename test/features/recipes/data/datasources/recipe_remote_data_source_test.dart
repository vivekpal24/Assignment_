
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_finder/core/constants/api_constants.dart';
import 'package:recipe_finder/core/errors/failures.dart';
import 'package:recipe_finder/core/network/dio_client.dart';
import 'package:recipe_finder/features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'package:recipe_finder/features/recipes/data/models/recipe_model.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late RecipeRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = RecipeRemoteDataSourceImpl(mockDioClient);
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('searchRecipes', () {
    const tQuery = 'chicken';
    final tMap = {
      'meals': [
        {
          'idMeal': '1',
          'strMeal': 'Chicken Test',
          'strCategory': 'Chicken',
          'strArea': 'Test',
          'strInstructions': 'Test',
          'strMealThumb': 'url'
        }
      ]
    };

    test('should return List<RecipeModel> when response code is 200', () async {
      when(() => mockDioClient.get(
            ApiConstants.search,
            queryParameters: {ApiConstants.paramSearch: tQuery},
          )).thenAnswer((_) async => Response(
            data: tMap,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.search),
          ));

      final result = await dataSource.searchRecipes(tQuery);

      expect(result, isA<List<RecipeModel>>());
      expect(result.length, 1);
      expect(result.first.name, 'Chicken Test');
    });

    test('should throw ServerFailure when exception occurs', () async {
      when(() => mockDioClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(Exception());

      final call = dataSource.searchRecipes;

      expect(() => call(tQuery), throwsA(isA<ServerFailure>()));
    });
  });
  
  group('getRecipeDetail', () {
    const tId = '1';
    final tMap = {
      'meals': [
        {
          'idMeal': '1',
          'strMeal': 'Chicken Test',
          'strCategory': 'Chicken',
          'strArea': 'Test',
          'strInstructions': 'Test',
          'strMealThumb': 'url'
        }
      ]
    };

    test('should return RecipeModel when response is 200 and data exists', () async {
      when(() => mockDioClient.get(
            ApiConstants.lookup,
            queryParameters: {ApiConstants.paramId: tId},
          )).thenAnswer((_) async => Response(
            data: tMap,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.lookup),
      ));

      final result = await dataSource.getRecipeDetail(tId);

      expect(result, isA<RecipeModel>());
      expect(result.id, '1');
    });
  });

  group('getCategories', () {
    test('should return List<dynamic> when response is 200', () async {
      final tCategoriesRaw = {
        'categories': [
          {'strCategory': 'Beef'},
          {'strCategory': 'Chicken'}
        ]
      };
      
      when(() => mockDioClient.get(ApiConstants.categories))
          .thenAnswer((_) async => Response(
              data: tCategoriesRaw,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiConstants.categories)));

      final result = await dataSource.getCategories();

      expect(result, isA<List<dynamic>>());
      expect(result.length, 2);
    });
  });

  group('getRecipesByCategory', () {
    const tCategory = 'Beef';
    final tMap = {'meals': [{'idMeal': '1', 'strMeal': 'Beef 1', 'strMealThumb': 'url', 'strCategory': 'Beef', 'strArea': 'Test', 'strInstructions': 'Test'}]};

    test('should return List<RecipeModel> when response is 200', () async {
      when(() => mockDioClient.get(
            ApiConstants.filter,
            queryParameters: {ApiConstants.paramCategory: tCategory},
          )).thenAnswer((_) async => Response(
              data: tMap,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiConstants.filter)));

      final result = await dataSource.getRecipesByCategory(tCategory);

      expect(result, isA<List<RecipeModel>>());
      expect(result.first.name, 'Beef 1');
    });
  });
  
  group('getRecipesByArea', () {
    const tArea = 'American';
    final tMap = {'meals': [{'idMeal': '1', 'strMeal': 'Burger', 'strMealThumb': 'url', 'strCategory': 'Beef', 'strArea': 'American', 'strInstructions': 'Test'}]};

    test('should return List<RecipeModel> when response is 200', () async {
      when(() => mockDioClient.get(
            ApiConstants.filter,
            queryParameters: {ApiConstants.paramArea: tArea},
          )).thenAnswer((_) async => Response(
              data: tMap,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiConstants.filter)));

      final result = await dataSource.getRecipesByArea(tArea);

      expect(result, isA<List<RecipeModel>>());
      expect(result.first.name, 'Burger');
    });
  });
}
