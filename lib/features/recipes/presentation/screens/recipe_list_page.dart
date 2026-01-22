import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../providers/recipe_list_provider.dart';
import '../widgets/recipe_card.dart';

/// Main recipe discovery page with search, filters, and sort.
///
/// Displays recipes in grid or list view with debounced search,
/// category and area filters, and sort options.
class RecipeListPage extends ConsumerStatefulWidget {
  const RecipeListPage({super.key});
  static bool debugTestMode = false;

  @override
  ConsumerState<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends ConsumerState<RecipeListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Activate the debounce controller
    ref.watch(searchDebounceController);
    
    final recipesAsync = ref.watch(recipeListProvider);
    final isGridView = ref.watch(viewModeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedArea = ref.watch(selectedAreaProvider); // Watch Area
    final categoriesAsync = ref.watch(categoriesProvider);
    final areasAsync = ref.watch(areasProvider); // Watch Areas List
    final activeFilterCount = ref.watch(activeFilterCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          PopupMenuButton<SortOrder>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => ref.read(sortOrderProvider.notifier).state = value,
            itemBuilder: (context) => [
              const PopupMenuItem(value: SortOrder.nameAsc, child: Text('Name (A-Z)')),
              const PopupMenuItem(value: SortOrder.nameDesc, child: Text('Name (Z-A)')),
            ],
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => ref.read(viewModeProvider.notifier).state = !isGridView,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.pushNamed(AppRouter.favorites),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: AppSearchBar(
              controller: _searchController,
              onChanged: (query) {
                 ref.read(searchQueryProvider.notifier).state = query;
              },
              onClear: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
          ),
          
          // Filters Section
          Container(
             height: 150, // Increased height for two rows + headers or just two rows of chips
             padding: const EdgeInsets.only(bottom: 8),
             child: SingleChildScrollView(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Header Row with Clear Button & Badge
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(
                           children: [
                             const Text("Filters", style: TextStyle(fontWeight: FontWeight.bold)),
                             const SizedBox(width: 8),
                             Opacity(
                               opacity: activeFilterCount > 0 ? 1.0 : 0.0,
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: AppColors.primary,
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 child: Text(
                                   '$activeFilterCount',
                                   style: const TextStyle(color: Colors.white, fontSize: 12),
                                 ),
                               ),
                             ),
                           ],
                         ),
                      
                      SizedBox(
                        width: 100,
                        child: TextButton(
                          onPressed: activeFilterCount > 0 ? () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedCategoryProvider.notifier).state = null;
                            ref.read(selectedAreaProvider.notifier).state = null;
                          } : null,
                          child: const Text("Clear All"),
                        ),
                      ),
                    ],
                  ),
                ),
                   const SizedBox(height: 4),

                   // Categories Row
                   SizedBox(
                      height: 40,
                      child: categoriesAsync.when(
                        data: (data) => ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                          scrollDirection: Axis.horizontal,
                          itemCount: data.length,
                          separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p8),
                          itemBuilder: (context, index) {
                            final category = data[index];
                            final isSelected = selectedCategory == category;
                            return FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                  ref.read(selectedCategoryProvider.notifier).state = selected ? category : null;
                              },
                            );
                          },
                        ),
                        loading: () => RecipeListPage.debugTestMode 
                            ? const SizedBox() 
                            : const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                        error: (e, s) => const SizedBox(),
                      ),
                   ),
                   
                   const SizedBox(height: 8),
                   
                   // Areas Row
                   SizedBox(
                      height: 40,
                      child: areasAsync.when(
                        data: (data) => ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                          scrollDirection: Axis.horizontal,
                          itemCount: data.length,
                          separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p8),
                          itemBuilder: (context, index) {
                            final area = data[index];
                            final isSelected = selectedArea == area;
                            return FilterChip(
                              label: Text(area),
                              selected: isSelected,
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              onSelected: (selected) {
                                  ref.read(selectedAreaProvider.notifier).state = selected ? area : null;
                              },
                            );
                          },
                        ),
                        loading: () => const SizedBox(),
                        error: (e, s) => const SizedBox(),
                      ),
                   ),
                 ],
               ),
             ),
          ),

          // Recipe List
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off,
                    title: 'No Recipes Found',
                    description: 'Try adjusting your filters or search terms',
                  );
                }
                
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isGridView
                      ? GridView.builder(
                          key: const ValueKey('grid'),
                          padding: const EdgeInsets.all(AppSizes.p16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: AppSizes.p16,
                            mainAxisSpacing: AppSizes.p16,
                          ),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return RecipeCard(
                              recipe: recipe,
                              isGrid: true,
                              onTap: () => context.pushNamed(AppRouter.recipeDetail, pathParameters: {'id': recipe.id}),
                            );
                          },
                        )
                      : ListView.separated(
                          key: const ValueKey('list'),
                          padding: const EdgeInsets.all(AppSizes.p16),
                          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p16),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return RecipeCard(
                              recipe: recipe,
                              isGrid: false,
                              onTap: () => context.pushNamed(AppRouter.recipeDetail, pathParameters: {'id': recipe.id}),
                            );
                          },
                        ),
                );
              },
              loading: () => RecipeListPage.debugTestMode 
                ? const SizedBox() 
                : Shimmer.fromColors(
                  baseColor: AppColors.shimmerBase,
                  highlightColor: AppColors.shimmerHighlight,
                   child: GridView.builder(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: AppSizes.p16,
                            mainAxisSpacing: AppSizes.p16,
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) => Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.r12),
                            ),
                          ),
                ),
              ),
              error: (e, s) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(recipeListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
