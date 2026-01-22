
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recipe_entity.dart';
import '../providers/favorites_provider.dart';

/// An animated favorite button with heart-beat scale effect.
///
/// Displays a heart icon that scales and changes color when toggled.
/// Automatically syncs with the favorites provider state.
class AnimatedFavoriteButton extends ConsumerStatefulWidget {
  final RecipeEntity recipe;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool showShadow;

  const AnimatedFavoriteButton({
    super.key,
    required this.recipe,
    this.size = 24,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.white,
    this.showShadow = true,
  });

  @override
  ConsumerState<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends ConsumerState<AnimatedFavoriteButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final isFavorite = ref.read(isFavoriteProvider(widget.recipe.id));
    if (!isFavorite) {
      _controller.forward(from: 0.0);
    } else {
      _controller.reverse(from: 1.0);
    }
    ref.read(favoritesProvider.notifier).toggleFavorite(widget.recipe);
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(isFavoriteProvider(widget.recipe.id));

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? widget.activeColor : widget.inactiveColor,
          size: widget.size,
          shadows: widget.showShadow 
              ? [const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
              : null,
        ),
      ),
    );
  }
}
