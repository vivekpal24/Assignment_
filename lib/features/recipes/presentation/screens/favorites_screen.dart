import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/favorites_provider.dart';
import '../widgets/recipe_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.favoritesTitle),
        elevation: 0,
      ),
      body: favoritesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return AppEmptyState(
              icon: Icons.favorite_border,
              title: AppStrings.noFavorites,
              description: 'Save your favorite recipes to see them here!',
              actionLabel: 'Browse Recipes',
              onAction: () => context.goNamed(AppRouter.home),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p16),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Stack(
                children: [
                   RecipeCard(
                    recipe: recipe,
                    isGrid: false,
                    onTap: () {
                        context.pushNamed(AppRouter.recipeDetail, pathParameters: {'id': recipe.id});
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(recipe),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
      ),
    );
  }
}
