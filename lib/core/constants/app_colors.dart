import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Palette (Modern Indigo)
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryMuted = Color(0xFFC7D2FE);

  // Secondary Accent (Teal / Emerald)
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFECFDF5);
  static const Color secondaryDark = Color(0xFF047857);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color surfaceDark = Color(0xFF0F172A);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF64748B);

  // Semantic Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Domain Booking Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF3B82F6);
  static const Color statusProviderAssigned = Color(0xFF6366F1);
  static const Color statusProviderOnTheWay = Color(0xFF8B5CF6);
  static const Color statusServiceStarted = Color(0xFF06B6D4);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);

  // Domain Payment Status Colors
  static const Color paymentPending = Color(0xFFF59E0B);
  static const Color paymentSuccess = Color(0xFF10B981);
  static const Color paymentFailed = Color(0xFFEF4444);
  static const Color paymentRefunded = Color(0xFF64748B);

  // Shadows
  static const Color shadow = Color(0x0A0F172A);
  static const Color shadowMedium = Color(0x140F172A);
}
