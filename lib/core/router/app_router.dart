import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/recipes/presentation/screens/favorites_screen.dart'; // Will create
import '../../features/recipes/presentation/screens/recipe_detail_page.dart';
import '../../features/recipes/presentation/screens/recipe_list_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static const String home = 'home';
  static const String recipeDetail = 'recipeDetail';
  static const String favorites = 'favorites';

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: home,
        builder: (context, state) => const RecipeListPage(),
      ),
      GoRoute(
        path: '/recipe/:id',
        name: recipeDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RecipeDetailPage(recipeId: id);
        },
      ),
      GoRoute(
        path: '/favorites',
        name: favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
    ],
  );
}
