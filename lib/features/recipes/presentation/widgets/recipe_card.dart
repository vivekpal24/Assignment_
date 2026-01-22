import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/recipe_entity.dart';
import 'animated_favorite_button.dart';

/// A card widget displaying recipe information.
///
/// Supports both grid and list layouts with recipe image, name,
/// category, and area information.
class RecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  final VoidCallback onTap;
  final bool isGrid;
  static bool debugTestMode = false;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: isGrid
            ? _buildGridContent(context)
            : _buildListContent(context),
      ),
    );
  }

  Widget _buildGridContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Hero(
            tag: 'recipe_image_${recipe.id}',
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: recipe.thumbUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => RecipeCard.debugTestMode 
                    ? const SizedBox() 
                    : Shimmer.fromColors(
                    baseColor: AppColors.shimmerBase,
                    highlightColor: AppColors.shimmerHighlight,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedFavoriteButton(
                    recipe: recipe,
                    inactiveColor: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
// ... (rest of the file remains same, I'll update both occurrences)
        Padding(
          padding: const EdgeInsets.all(AppSizes.p8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.p4),
              Text(
                '${recipe.area} • ${recipe.category}',
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListContent(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Hero(
            tag: 'recipe_image_${recipe.id}',
            child: CachedNetworkImage(
              imageUrl: recipe.thumbUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => RecipeCard.debugTestMode 
                ? const SizedBox() 
                : Shimmer.fromColors(
                baseColor: AppColors.shimmerBase,
                highlightColor: AppColors.shimmerHighlight,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) =>
              const Icon(Icons.error),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  '${recipe.area} | ${recipe.category}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
        if (recipe.isFavorite)
          const Padding(
            padding: EdgeInsets.only(right: AppSizes.p16),
            child: Icon(Icons.favorite, color: Colors.red),
          ),
      ],
    );
  }
}
