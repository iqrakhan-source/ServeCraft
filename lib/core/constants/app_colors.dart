import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Palette (Luxury Rose Bronze & Onyx)
  static const Color primary = Color(0xFF8B5A42);
  static const Color primaryDark = Color(0xFF1C1917);
  static const Color primaryLight = Color(0xFFF9F5F1);
  static const Color primaryMuted = Color(0xFFDCC8B8);

  // Secondary Accent (Warm Champagne Gold)
  static const Color secondary = Color(0xFFB88E58);
  static const Color secondaryLight = Color(0xFFFDF8EE);
  static const Color secondaryDark = Color(0xFF7E5B2E);

  // Background & Surfaces
  static const Color background = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4EFEA);
  static const Color surfaceDark = Color(0xFF1C1917);

  // Borders & Dividers
  static const Color border = Color(0xFFEBE4DC);
  static const Color borderSubtle = Color(0xFFF5F0E9);
  static const Color borderStrong = Color(0xFFD6CBC0);

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF57534E);
  static const Color textTertiary = Color(0xFF8C857E);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF78716C);

  // Semantic Feedback Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Domain Booking Status Colors
  static const Color statusPending = Color(0xFFD97706);
  static const Color statusConfirmed = Color(0xFF8B5A42);
  static const Color statusProviderAssigned = Color(0xFFB88E58);
  static const Color statusProviderOnTheWay = Color(0xFF78716C);
  static const Color statusServiceStarted = Color(0xFF0284C7);
  static const Color statusCompleted = Color(0xFF16A34A);
  static const Color statusCancelled = Color(0xFFDC2626);

  // Domain Payment Status Colors
  static const Color paymentPending = Color(0xFFD97706);
  static const Color paymentSuccess = Color(0xFF16A34A);
  static const Color paymentFailed = Color(0xFFDC2626);
  static const Color paymentRefunded = Color(0xFF78716C);

  // Shadows
  static const Color shadow = Color(0x0C1C1917);
  static const Color shadowMedium = Color(0x181C1917);
}
