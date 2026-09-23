import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
import 'package:prop_crm/core/widgets/app_empty_state.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String? iconName) {
    if (iconName == null) return Icons.home_repair_service_outlined;
    switch (iconName.toLowerCase()) {
      case 'cleaning_services':
        return Icons.cleaning_services_outlined;
      case 'build':
        return Icons.build_outlined;
      case 'bolt':
        return Icons.bolt_outlined;
      case 'plumbing':
        return Icons.plumbing_outlined;
      case 'format_paint':
        return Icons.format_paint_outlined;
      case 'handyman':
        return Icons.handyman_outlined;
      case 'pest_control':
        return Icons.pest_control_outlined;
      case 'spa':
        return Icons.spa_outlined;
      default:
        return Icons.home_repair_service_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'All Categories',
      ),
      body: Builder(
        builder: (context) {
          if (categoryProvider.isLoading) {
            return _buildLoadingGrid();
          }

          if (categoryProvider.hasError) {
            return AppErrorView(
              message:
                  categoryProvider.errorMessage ?? 'Failed to load categories',
              onRetry: () =>
                  categoryProvider.fetchCategories(forceRefresh: true),
            );
          }

          if (categoryProvider.isEmpty) {
            return AppEmptyState(
              icon: Icons.category_outlined,
              title: 'No Categories Available',
              subtitle: 'Please check back later for service categories.',
              actionText: 'Retry',
              onActionPressed: () =>
                  categoryProvider.fetchCategories(forceRefresh: true),
            );
          }

          final allCategories = categoryProvider.categories;
          final filteredCategories = _searchQuery.isEmpty
              ? allCategories
              : allCategories
                  .where((c) =>
                      c.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      c.description
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList();

          return RefreshIndicator(
            onRefresh: () =>
                categoryProvider.fetchCategories(forceRefresh: true),
            color: AppColors.primary,
            child: Column(
              children: [
                // Search categories field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // 2-column grid of moderate-sized category cards
                Expanded(
                  child: filteredCategories.isEmpty
                      ? AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No Matching Categories',
                          subtitle: 'Try a different search term.',
                          actionText: 'Clear Search',
                          onActionPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 1.05,
                          ),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            final iconData = _getCategoryIcon(category.icon);

                            return AppCard(
                              padding: const EdgeInsets.all(14.0),
                              borderRadius: 12.0,
                              onTap: () {
                                categoryProvider.selectCategory(category);
                                Navigator.of(context).pushNamed(
                                  AppRoutes.serviceListing,
                                  arguments: {
                                    'categoryId': category.id,
                                    'categoryName': category.name,
                                  },
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Consistent Icon Container
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        iconData,
                                        size: 22,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Category Details
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style:
                                            AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        category.description,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          height: 1.25,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: AppSkeleton(
            height: 48,
            width: double.infinity,
            borderRadius: 12,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 1.05,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return const AppCard(
                padding: EdgeInsets.all(14),
                borderRadius: 12.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppSkeleton(height: 44, width: 44, borderRadius: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton(height: 14, width: 100),
                        SizedBox(height: 6),
                        AppSkeleton(height: 10, width: 120),
                        SizedBox(height: 4),
                        AppSkeleton(height: 10, width: 80),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
