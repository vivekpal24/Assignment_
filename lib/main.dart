import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/recipes/data/models/recipe_model.dart';
import 'features/recipes/data/models/hive_adapters.dart';
import 'features/recipes/presentation/providers/recipe_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(RecipeModelAdapter());
  Hive.registerAdapter(IngredientModelAdapter());
  final recipeBox = await Hive.openBox<RecipeModel>('recipes');

  runApp(ProviderScope(
    overrides: [
      hiveBoxProvider.overrideWithValue(recipeBox),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Finder',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
