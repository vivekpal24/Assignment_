import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_image_viewer.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/recipe_providers.dart';
import '../widgets/animated_favorite_button.dart';

/// Recipe detail page displaying full recipe information.
///
/// Shows recipe image, ingredients, instructions, and optional video tutorial
/// in a tabbed interface using NestedScrollView.
class RecipeDetailPage extends ConsumerStatefulWidget {
  final String recipeId;
  static bool debugTestMode = false;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends ConsumerState<RecipeDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(recipeDetailProvider(widget.recipeId));

    return recipeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(recipeDetailProvider(widget.recipeId)),
        ),
      ),
      data: (recipe) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                    onPressed: () => context.pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
                    title: Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          key: const Key('recipe_image_tap'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => AppImageViewer.show(
                            context,
                            recipe.thumbUrl,
                            heroTag: 'recipe_image_${recipe.id}',
                          ),
                          child: Hero(
                            tag: 'recipe_image_${recipe.id}',
                            child: CachedNetworkImage(
                              imageUrl: recipe.thumbUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AnimatedFavoriteButton(
                        recipe: recipe,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: AppStrings.tabOverview),
                        Tab(text: AppStrings.tabIngredients),
                        Tab(text: AppStrings.tabInstructions),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Overview
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(context, 'About this Meal'),
                      const SizedBox(height: AppSizes.p12),
                      Row(
                        children: [
                          _buildInfoChip(context, Icons.restaurant_menu, recipe.category),
                          const SizedBox(width: AppSizes.p12),
                          _buildInfoChip(context, Icons.public, recipe.area),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p20),
                      if (recipe.youtubeUrl != null && recipe.youtubeUrl!.isNotEmpty) ...[
                        _buildVideoSection(recipe.youtubeUrl!),
                        const SizedBox(height: AppSizes.p20),
                      ],
                    ],
                  ),
                ),

                // Ingredients
                ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  itemCount: recipe.ingredients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p12),
                  itemBuilder: (context, index) {
                    final ing = recipe.ingredients[index];
                    return Container(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(AppSizes.p12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: AppSizes.p12),
                          Expanded(
                            child: Text(
                              ing.name,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            ing.measure,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Instructions
                () {
                  final steps = _parseInstructions(recipe.instructions);
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.p20),
                    itemCount: steps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p20),
                    itemBuilder: (context, index) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.p16),
                          Expanded(
                            child: Text(
                              steps[index],
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _parseInstructions(String instructions) {
    // Split by newlines or periods followed by spaces/newlines
    // Clean up empty strings and trim
    return instructions
        .split(RegExp(r'(?:\r?\n)+|(?<=\.)\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 3) // Filter out very short artifacts or fragments
        .toList();
  }

  Widget _buildVideoSection(String url) {
    final videoId = YoutubePlayerController.convertUrlToId(url);
    if (videoId == null) return _buildVideoFallback(url);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Video Tutorial'),
        const SizedBox(height: AppSizes.p12),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.p12),
          child: RecipeYoutubePlayer(youtubeUrl: url),
        ),
        const SizedBox(height: AppSizes.p12),
        _buildVideoFallback(url, label: 'Open in YouTube App'),
      ],
    );
  }

  Widget _buildVideoFallback(String url, {String label = AppStrings.watchVideo}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.play_circle_fill),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.p12)),
        ),
        onPressed: () {
          launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.textSecondary),
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      labelStyle: Theme.of(context).textTheme.bodyMedium,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1; // +1 to avoid pixel snapping issues

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
       // Add a bottom border for separation when pinned
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
           bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class RecipeYoutubePlayer extends StatefulWidget {
  final String youtubeUrl;
  const RecipeYoutubePlayer({super.key, required this.youtubeUrl});

  @override
  State<RecipeYoutubePlayer> createState() => _RecipeYoutubePlayerState();
}

class _RecipeYoutubePlayerState extends State<RecipeYoutubePlayer> {
  late YoutubePlayerController _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayerController.convertUrlToId(widget.youtubeUrl);
    
    if (_videoId != null && !RecipeDetailPage.debugTestMode) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _videoId!,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          mute: false,
          showControls: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_videoId != null && !RecipeDetailPage.debugTestMode) {
      _controller.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) return const SizedBox.shrink();
    
    if (RecipeDetailPage.debugTestMode) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text('YouTube Player (Test Mode)', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return YoutubePlayer(
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }
}
