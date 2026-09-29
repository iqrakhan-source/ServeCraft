import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
  dangerOutline,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final bool isFullWidth;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.width,
    this.height = 50,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isDisabled ? AppColors.primaryMuted : AppColors.primary;
        foregroundColor = AppColors.textInverse;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isDisabled ? AppColors.surfaceMuted : AppColors.primaryLight;
        foregroundColor = isDisabled ? AppColors.textTertiary : AppColors.primary;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? AppColors.textTertiary : AppColors.primary;
        borderSide = BorderSide(
          color: isDisabled ? AppColors.border : AppColors.primary,
          width: 1.5,
        );
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? AppColors.textTertiary : AppColors.primary;
        break;
      case AppButtonVariant.danger:
        backgroundColor = isDisabled ? AppColors.errorLight : AppColors.error;
        foregroundColor = AppColors.textInverse;
        break;
      case AppButtonVariant.dangerOutline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? AppColors.textTertiary : AppColors.error;
        borderSide = BorderSide(
          color: isDisabled ? AppColors.border : AppColors.error,
          width: 1.5,
        );
        break;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: AppTypography.buttonLarge.copyWith(color: foregroundColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: variant == AppButtonVariant.primary && !isDisabled ? 1 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderSide ?? BorderSide.none,
          ),
        ),
        child: content,
      ),
    );
  }
}
