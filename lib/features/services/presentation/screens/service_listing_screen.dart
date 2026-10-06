import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/custom_app_bar.dart';

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
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filters = [
    'All',
    'Popular',
    'Top Rated',
    'Under ₹1,000',
  ];

  final List<Map<String, dynamic>> _salonServices = [
    {
      'id': 'srv_exec_haircut',
      'title': 'Executive Haircut & Styling',
      'subtitle':
          'Precision haircut customized to your face profile with clarifying wash and blow-dry styling.',
      'image':
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
      'price': 499.0,
      'rating': 4.9,
      'reviews': '380',
      'duration': '45 mins',
      'tag': 'Bestseller',
      'category': 'Hair',
    },
    {
      'id': 'srv_women_haircut',
      'title': 'Signature Cut & Blow Dry',
      'subtitle':
          'Bespoke consultation, clarifying wash, layer haircut, and professional volume blowout.',
      'image':
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
      'price': 899.0,
      'rating': 4.8,
      'reviews': '295',
      'duration': '60 mins',
      'tag': 'Popular',
      'category': 'Hair',
    },
    {
      'id': 'srv_hydra_facial',
      'title': 'Hydra Medi-Facial & Glow',
      'subtitle':
          '6-step clinical grade hydra-dermabrasion with peptide infusions, gold mask & LED light therapy.',
      'image':
          'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=800',
      'price': 1799.0,
      'rating': 4.9,
      'reviews': '510',
      'duration': '60 mins',
      'tag': 'Top Rated',
      'category': 'Skin',
    },
    {
      'id': 'srv_moroccan_spa',
      'title': 'Moroccan Argan Hair Spa',
      'subtitle':
          'Deep restorative mask with pure argan elixir, intense scalp massage and ozone steaming.',
      'image':
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
      'price': 1299.0,
      'rating': 4.8,
      'reviews': '240',
      'duration': '60 mins',
      'tag': 'Popular',
      'category': 'Spa',
    },
    {
      'id': 'srv_gel_mani_pedi',
      'title': 'Luxury Gel Mani & Pedi',
      'subtitle':
          'Exfoliating foot soak, cuticles shaping, massage, and long-lasting glossy gel polish finish.',
      'image':
          'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=800',
      'price': 1499.0,
      'rating': 4.8,
      'reviews': '190',
      'duration': '75 mins',
      'tag': 'Luxury',
      'category': 'Nails',
    },
    {
      'id': 'srv_balayage',
      'title': 'Artisan Balayage & Glossing',
      'subtitle':
          'Sun-kissed dimensional coloring with premium Olaplex bond protection and toner gloss.',
      'image':
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800',
      'price': 3499.0,
      'rating': 4.9,
      'reviews': '160',
      'duration': '120 mins',
      'tag': 'Signature',
      'category': 'Hair',
    },
    {
      'id': 'srv_beard_spa',
      'title': 'Royal Beard Spa & Hot Towel Shave',
      'subtitle':
          'Essential oils massage, hot towel treatment, straight-razor detailing & beard conditioning.',
      'image':
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
      'price': 399.0,
      'rating': 4.8,
      'reviews': '210',
      'duration': '30 mins',
      'tag': 'Value',
      'category': 'Grooming',
    },
    {
      'id': 'srv_bridal_hd',
      'title': 'HD Bridal & Engagement Makeup',
      'subtitle':
          'High definition bridal makeup with skin prep, mink lash extensions, and saree draping.',
      'image':
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800',
      'price': 4999.0,
      'rating': 5.0,
      'reviews': '120',
      'duration': '120 mins',
      'tag': 'Exclusive',
      'category': 'Makeup',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredServices {
    return _salonServices.where((service) {
      final name = service['title'].toString().toLowerCase();
      final sub = service['subtitle'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesQuery = _searchQuery.isEmpty || name.contains(query) || sub.contains(query);

      if (!matchesQuery) return false;

      switch (_selectedFilter) {
        case 'Popular':
          return service['tag'] == 'Popular' || service['tag'] == 'Bestseller';
        case 'Top Rated':
          return (service['rating'] as double) >= 4.9;
        case 'Under ₹1,000':
          return (service['price'] as double) < 1000;
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.categoryName ?? 'Salon Services';
    final services = _filteredServices;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: title,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
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

          // Filters Row
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceMuted,
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  );
                },
              ),
            ),
          ),

          // Services Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.background,
            child: Text(
              'Showing ${services.length} services',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Services List
          Expanded(
            child: services.isEmpty
                ? Center(
                    child: Text(
                      'No services matching your criteria',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: services.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return _buildServiceCard(context, service);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
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
              AppRoutes.serviceDetails,
              arguments: {'serviceId': service['id']},
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with tag & rating
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(17)),
                    child: AppNetworkImage(
                      imageUrl: service['image'],
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
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service['tag'],
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
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 3),
                          Text(
                            '${service['rating']} (${service['reviews']})',
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

              // Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            service['title'],
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppFormatters.formatCurrency(service['price']),
                          style: AppTypography.priceMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service['subtitle'],
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 14, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              service['duration'],
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.serviceDetails,
                                  arguments: {'serviceId': service['id']},
                                );
                              },
                              child: Text(
                                'View Details',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppButton(
                              text: 'Book Now',
                              isFullWidth: false,
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.serviceDetails,
                                  arguments: {'serviceId': service['id']},
                                );
                              },
                            ),
                          ],
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