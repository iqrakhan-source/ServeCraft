import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/features/categories/data/models/category_model.dart';

class CategoryStrip extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoryStrip({super.key, required this.categories});

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
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.categories);
                },
                child: Text(
                  'See all',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Horizontally Scrollable Lightweight Category Icons
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final iconData = _getCategoryIcon(cat.icon);

              return InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.serviceListing,
                    arguments: {
                      'categoryId': cat.id,
                      'categoryName': cat.name,
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 68,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular Icon Container
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            iconData,
                            size: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category Name
                      Text(
                        cat.name,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
