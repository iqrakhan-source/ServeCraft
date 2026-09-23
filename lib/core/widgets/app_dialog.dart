import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import 'app_button.dart';

abstract class AppDialog {
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = AppStrings.continueText,
    String cancelText = AppStrings.cancel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppTypography.titleMedium),
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              cancelText,
              style: AppTypography.buttonMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          AppButton(
            text: confirmText,
            isFullWidth: false,
            height: 40,
            variant: isDestructive ? AppButtonVariant.danger : AppButtonVariant.primary,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }

  static Future<void> alert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = AppStrings.done,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppTypography.titleMedium),
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          AppButton(
            text: buttonText,
            isFullWidth: false,
            height: 40,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
