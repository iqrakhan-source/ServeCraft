import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/service_model.dart';
import '../providers/service_provider.dart';

class ServiceListingScreen extends StatefulWidget {
  final String? categoryName;
  final String? categoryId;

  const ServiceListingScreen({
    super.key,
    this.categoryName,
    this.categoryId,
    String? category,
  });

  @override
  State<ServiceListingScreen> createState() =>
      _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filters = [
    'All',
    'Popular',
    'Top Rated',
    'Under ₹1,000',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

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

  List<ServiceModel> _filterServices(
      List<ServiceModel> allServices,
      ) {
    return allServices.where((service) {
      final name = service.name.toLowerCase();
      final description =
      service.description.toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          description.contains(query);

      if (!matchesQuery) return false;

      switch (_selectedFilter) {
        case 'Popular':
// The current ServiceModel does not expose a popular field.
// Add that field to the model to filter by the API's
// actual "popular" value.
          return true;

        case 'Top Rated':
          return service.rating >= 4.9;

        case 'Under ₹1,000':
          return service.startingPrice < 1000;

        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  void _openServiceDetails(
      BuildContext context,
      ServiceModel service,
      ) {
    Navigator.pushNamed(
      context,
      AppRoutes.serviceDetails,
      arguments: {'serviceId': service.id, 'service': service},
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.categoryName ?? 'Salon Services';
    final provider = context.watch<ServiceProvider>();
    final services = _filterServices(provider.services);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: title,
        showBackButton: true,
      ),
      body: Column(
        children: [
// Search bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search $title...',
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
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
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

// Filters
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount: _filters.length,
                separatorBuilder: (_, _) =>
                const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceMuted,
                    labelStyle:
                    AppTypography.labelSmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                  );
                },
              ),
            ),
          ),

// Services count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            color: AppColors.background,
            child: Text(
              provider.isLoading
                  ? 'Loading services...'
                  : 'Showing ${services.length} services',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

// API-driven services list
          Expanded(
            child: _buildServicesContent(
              provider,
              services,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesContent(
      ServiceProvider provider,
      List<ServiceModel> services,
      ) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage ??
                    'Failed to load services.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Retry',
                isFullWidth: false,
                onPressed: () {
                  provider.fetchServices(
                    categoryId: widget.categoryId,
                    forceRefresh: true,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    if (services.isEmpty) {
      return Center(
        child: Text(
          provider.services.isEmpty
              ? 'No services available'
              : 'No services matching your criteria',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      separatorBuilder: (_, _) =>
      const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildServiceCard(
          context,
          services[index],
        );
      },
    );
  }

  Widget _buildServiceCard(
      BuildContext context,
      ServiceModel service,
      ) {
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
          onTap: () => _openServiceDetails(context, service),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
// Service image and rating
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(17),
                    ),
                    child: AppNetworkImage(
                      imageUrl: service.image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service.isActive ? 'Available' : 'Unavailable',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(
                          alpha: 0.95,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${service.rating} (${service.reviewCount})',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

// Service details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppFormatters.formatCurrency(
                            service.startingPrice,
                          ),
                          style: AppTypography.priceMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  service.duration,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      //  const SizedBox(width: 2),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: TextButton(
                                  onPressed: () =>
                                      _openServiceDetails(
                                        context,
                                        service,
                                      ),
                                  child: Text(
                                    'View Details',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              AppButton(
                                text: 'Book Now',
                                isFullWidth: false,
                                onPressed: () =>
                                    _openServiceDetails(
                                      context,
                                      service,
                                    ),
                              ),
                            ],
                          ),
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
  }
}
