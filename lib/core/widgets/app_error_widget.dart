import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../errors/failures.dart';

/// A reusable error widget for displaying error states.
///
/// Automatically displays appropriate icons and messages based on the
/// type of [Failure] provided (ConnectionFailure, ServerFailure, etc.).
/// Includes an optional retry button when [onRetry] callback is provided.
class AppErrorWidget extends StatelessWidget {
  final Failure? failure;
  final String? message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.failure,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorInfo.icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSizes.p20),
            Text(
              errorInfo.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              errorInfo.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.p24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.retry),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p24,
                    vertical: AppSizes.p12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _ErrorInfo _getErrorInfo() {
    if (failure != null) {
      if (failure is ConnectionFailure) {
        return _ErrorInfo(
          icon: Icons.wifi_off,
          title: 'No Internet Connection',
          description: AppStrings.networkError,
        );
      } else if (failure is ServerFailure) {
        return _ErrorInfo(
          icon: Icons.error_outline,
          title: 'Server Error',
          description: failure?.message ?? AppStrings.unexpectedError,
        );
      } else if (failure is CacheFailure) {
        return _ErrorInfo(
          icon: Icons.storage,
          title: 'Cache Error',
          description: failure?.message ?? 'Failed to load cached data',
        );
      }
    }

    return _ErrorInfo(
      icon: Icons.error_outline,
      title: 'Oops!',
      description: message ?? AppStrings.unexpectedError,
    );
  }
}

class _ErrorInfo {
  final IconData icon;
  final String title;
  final String description;

  _ErrorInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}
