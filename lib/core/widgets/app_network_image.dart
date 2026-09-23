import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'app_loading_indicator.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 12.0,
    this.fallbackIcon = Icons.home_repair_service_rounded,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;

    Widget placeholderWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: (height != null && height! < 50) ? 20 : 28,
          color: AppColors.primary.withValues(alpha: 0.6),
        ),
      ),
    );

    if (!hasValidUrl) {
      return placeholderWidget;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return AppSkeleton(
            width: width,
            height: height ?? 80,
            borderRadius: borderRadius,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return placeholderWidget;
        },
      ),
    );
  }
}
