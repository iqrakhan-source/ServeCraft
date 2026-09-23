import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/widgets/app_network_image.dart';
import 'package:prop_crm/features/home/data/models/banner_model.dart';

class BannerCarousel extends StatelessWidget {
  final List<BannerModel> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: banners.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final banner = banners[index];

          return InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.serviceListing);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 310,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background photography from data model
                    if (banner.imageUrl != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 160,
                        child: AppNetworkImage(
                          imageUrl: banner.imageUrl,
                          fit: BoxFit.cover,
                          borderRadius: 0,
                        ),
                      ),

                    // Contrast gradient overlay for clean readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0F172A),
                            const Color(0xFF0F172A).withValues(alpha: 0.90),
                            const Color(0xFF0F172A).withValues(alpha: 0.35),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),

                    // Foreground content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (banner.discountTag != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.5),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    banner.discountTag!,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: const Color(0xFF34D399),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                banner.title,
                                style: AppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                banner.subtitle,
                                style: AppTypography.bodySmall.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // Single CTA
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore services',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
