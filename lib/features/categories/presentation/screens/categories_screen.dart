import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../providers/category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  final bool isTab;

  const CategoriesScreen({super.key, this.isTab = false});

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
    if (iconName == null) return Icons.spa_rounded;
    switch (iconName.toLowerCase()) {
      case 'content_cut':
        return Icons.content_cut_rounded;
      case 'palette':
        return Icons.palette_outlined;
      case 'face':
        return Icons.face_retouching_natural_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'brush':
        return Icons.brush_rounded;
      case 'auto_fix_high':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.spa_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Salon Categories',
        showBackButton: !widget.isTab,
      ),
      body: Builder(
        builder: (context) {
          if (categoryProvider.isLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (categoryProvider.hasError) {
            return AppErrorView(
              message:
                  categoryProvider.errorMessage ?? 'Failed to load categories',
              onRetry: () =>
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

          return Column(
            children: [
              // Search categories input
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.surface,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search salon categories (Hair, Skin, Spa)...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Categories Grid
              Expanded(
                child: filteredCategories.isEmpty
                    ? const AppEmptyState(
                        title: 'No Categories Found',
                        subtitle: 'Try searching for hair, facial, spa, or nails.',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredCategories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.88,
                        ),
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          final icon = _getCategoryIcon(category.icon);

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  offset: Offset(0, 3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.serviceListing,
                                    arguments: {'categoryName': category.name},
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image with category icon pill
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: AppNetworkImage(
                                              imageUrl: category.image,
                                              height: 105,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.surface
                                                    .withValues(alpha: 0.9),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                icon,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        category.name,
                                        style:
                                            AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category.description,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 10,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
