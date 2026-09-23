import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_empty_state.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/app_network_image.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';

class ServiceListingScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ServiceListingScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices(
            categoryId: widget.categoryId,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final services = serviceProvider.services;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.categoryName ?? 'All Services',
      ),
      body: Column(
        children: [
          // Filter / Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => serviceProvider.searchServices(val),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search in ${widget.categoryName ?? 'services'}...',
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
                          serviceProvider.searchServices('');
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

          // Count Subheader
          if (!serviceProvider.isLoading && !serviceProvider.hasError && services.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    '${services.length} ${services.length == 1 ? 'service' : 'services'} available',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Main vertical list area
          Expanded(
            child: Builder(
              builder: (context) {
                if (serviceProvider.isLoading) {
                  return _buildLoadingList();
                }

                if (serviceProvider.hasError) {
                  return AppErrorView(
                    message: serviceProvider.errorMessage ??
                        'Failed to load services',
                    onRetry: () => serviceProvider.fetchServices(
                      categoryId: widget.categoryId,
                      forceRefresh: true,
                    ),
                  );
                }

                if (serviceProvider.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No Services Found',
                    subtitle:
                        'Try adjusting your search query or explore other categories.',
                    actionText: 'View All',
                    onActionPressed: () {
                      _searchController.clear();
                      serviceProvider.clearFilter();
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => serviceProvider.fetchServices(
                    categoryId: widget.categoryId,
                    forceRefresh: true,
                  ),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final service = services[index];

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.serviceDetails,
                            arguments: {'serviceId': service.id},
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Full-width Service Photo
                                SizedBox(
                                  height: 140,
                                  width: double.infinity,
                                  child: AppNetworkImage(
                                    imageUrl: service.image,
                                    width: double.infinity,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    borderRadius: 0,
                                  ),
                                ),

                                // Content Details
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Service Name
                                      Text(
                                        service.name,
                                        style: AppTypography.titleMedium
                                            .copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),

                                      // Rating and Reviews
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: AppColors.warning,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${service.rating.toStringAsFixed(1)} · ${service.reviewCount} reviews',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Price onwards and duration
                                      Text(
                                        '${AppFormatters.formatCurrency(service.startingPrice)} onwards · ${service.duration}',
                                        style: AppTypography.bodySmall
                                            .copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // Description & Forward Indicator
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              service.description,
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                                height: 1.3,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                            color: AppColors.primary,
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(height: 140, width: double.infinity, borderRadius: 0),
              Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(height: 16, width: 200),
                    SizedBox(height: 6),
                    AppSkeleton(height: 12, width: 130),
                    SizedBox(height: 8),
                    AppSkeleton(height: 14, width: 170),
                    SizedBox(height: 8),
                    AppSkeleton(height: 12, width: double.infinity),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
