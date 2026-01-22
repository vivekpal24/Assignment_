import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../features/recipes/presentation/screens/recipe_detail_page.dart';

class AppImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const AppImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  static void show(BuildContext context, String imageUrl, {String? heroTag}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AppImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 500) {
            Navigator.of(context).pop();
          }
        },
        child: Center(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            boundaryMargin: const EdgeInsets.all(20),
            child: heroTag != null
                ? Hero(
                    tag: heroTag!,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => RecipeDetailPage.debugTestMode 
    ? const SizedBox.shrink() 
    : const CircularProgressIndicator(color: Colors.white),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => RecipeDetailPage.debugTestMode 
    ? const SizedBox.shrink() 
    : const CircularProgressIndicator(color: Colors.white),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
