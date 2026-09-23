import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
import 'package:prop_crm/core/widgets/app_empty_state.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_strip.dart';
import '../widgets/featured_services_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (homeProvider.isLoading || homeProvider.homeState.isInitial) {
              return _buildLoadingState();
            }

            if (homeProvider.hasError) {
              return AppErrorView(
                message: homeProvider.errorMessage ??
                    'Could not load home recommendations',
                onRetry: () => homeProvider.fetchHomeData(forceRefresh: true),
              );
            }

            if (homeProvider.isEmpty) {
              return AppEmptyState(
                icon: Icons.storefront_outlined,
                title: 'No Services Right Now',
                subtitle:
                    'Our catalog is refreshing. Please check back shortly.',
                actionText: 'Refresh',
                onActionPressed: () =>
                    homeProvider.fetchHomeData(forceRefresh: true),
              );
            }

            final data = homeProvider.homeData;
            if (data == null) {
              return _buildLoadingState();
            }

            return RefreshIndicator(
              onRefresh: () => homeProvider.fetchHomeData(forceRefresh: true),
              color: AppColors.primary,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header with Location & Notification
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: HomeHeader(),
                    ),
                    const SizedBox(height: 16),

                    // 2. Search Bar
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: HomeSearchBar(),
                    ),
                    const SizedBox(height: 22),

                    // 3. Categories (lightweight horizontal scroll)
                    CategoryStrip(categories: data.categories),
                    const SizedBox(height: 24),

                    // 4. Promotional Banners Carousel (photography-led)
                    BannerCarousel(banners: data.banners),
                    const SizedBox(height: 28),

                    // 5. Popular Services Carousel
                    FeaturedServicesSection(services: data.popularServices),
                    const SizedBox(height: 28),

                    // 6. Recommended / Quality Assurance Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: AppCard(
                        backgroundColor: AppColors.surface,
                        borderRadius: 12,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ServeCraft Quality Assurance',
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Verified professionals • On-time service • Transparent pricing guaranteed.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppSkeleton(height: 36, width: 36, borderRadius: 10),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(height: 16, width: 70),
                      SizedBox(height: 4),
                      AppSkeleton(height: 12, width: 140),
                    ],
                  ),
                ],
              ),
              AppSkeleton(height: 40, width: 40, borderRadius: 10),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar Skeleton
          const AppSkeleton(height: 48, width: double.infinity, borderRadius: 12),
          const SizedBox(height: 22),

          // Categories Skeleton
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppSkeleton(height: 18, width: 90),
              AppSkeleton(height: 14, width: 50),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (index) => const Column(
                children: [
                  AppSkeleton(height: 56, width: 56, borderRadius: 28),
                  SizedBox(height: 8),
                  AppSkeleton(height: 10, width: 50),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Banner Skeleton
          const AppSkeleton(height: 160, width: double.infinity, borderRadius: 14),
          const SizedBox(height: 28),

          // Popular Services Skeleton
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppSkeleton(height: 18, width: 120),
              AppSkeleton(height: 14, width: 50),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      AppSkeleton(height: 110, width: double.infinity, borderRadius: 0),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSkeleton(height: 12, width: 120),
                            SizedBox(height: 6),
                            AppSkeleton(height: 10, width: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      AppSkeleton(height: 110, width: double.infinity, borderRadius: 0),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSkeleton(height: 12, width: 120),
                            SizedBox(height: 6),
                            AppSkeleton(height: 10, width: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
