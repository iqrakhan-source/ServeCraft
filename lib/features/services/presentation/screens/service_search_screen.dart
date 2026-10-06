import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';

class ServiceSearchScreen extends StatefulWidget {
  const ServiceSearchScreen({super.key});

  @override
  State<ServiceSearchScreen> createState() => _ServiceSearchScreenState();
}

class _ServiceSearchScreenState extends State<ServiceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _query = '';

  final List<String> _categories = [
    'All',
    'Haircut & Styling',
    'Facials & Skin',
    'Hair Spa',
    'Mani & Pedi',
    'Bridal Makeup',
    'Beard & Shave',
  ];

  final List<Map<String, dynamic>> _mockServices = [
    {
      'id': 'srv_exec_haircut',
      'name': 'Executive Haircut & Styling',
      'category': 'Haircut & Styling',
      'description':
          'Precision haircut customized to your profile with clarifying wash and blow-dry.',
      'image':
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600',
      'price': 499.0,
      'duration': '45 mins',
      'rating': 4.9,
      'reviewCount': 380,
    },
    {
      'id': 'srv_women_haircut',
      'name': 'Signature Cut & Blow Dry',
      'category': 'Haircut & Styling',
      'description':
          'Consultation, clarifying wash, bespoke layer haircut, and luxury volume blowout.',
      'image':
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600',
      'price': 899.0,
      'duration': '60 mins',
      'rating': 4.8,
      'reviewCount': 295,
    },
    {
      'id': 'srv_hydra_facial',
      'name': 'Hydra Medi-Facial & Glow',
      'category': 'Facials & Skin',
      'description':
          '6-step clinical grade hydra-dermabrasion with peptide infusions and LED mask.',
      'image':
          'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=600',
      'price': 1799.0,
      'duration': '60 mins',
      'rating': 4.9,
      'reviewCount': 510,
    },
    {
      'id': 'srv_moroccan_spa',
      'name': 'Moroccan Argan Hair Spa',
      'category': 'Hair Spa',
      'description':
          'Deep restorative mask with pure argan elixir, scalp massage and ozone steaming.',
      'image':
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600',
      'price': 1299.0,
      'duration': '60 mins',
      'rating': 4.8,
      'reviewCount': 240,
    },
    {
      'id': 'srv_gel_mani_pedi',
      'name': 'Luxury Gel Mani & Pedi',
      'category': 'Mani & Pedi',
      'description':
          'Exfoliating foot soak, cuticles shaping, massage, and long-lasting gel polish finish.',
      'image':
          'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=600',
      'price': 1499.0,
      'duration': '75 mins',
      'rating': 4.8,
      'reviewCount': 190,
    },
    {
      'id': 'srv_bridal_hd',
      'name': 'HD Bridal & Engagement Makeup',
      'category': 'Bridal Makeup',
      'description':
          'High definition bridal makeup with premium skin prep, lash extensions, and draping.',
      'image':
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=600',
      'price': 4999.0,
      'duration': '120 mins',
      'rating': 5.0,
      'reviewCount': 120,
    },
    {
      'id': 'srv_beard_spa',
      'name': 'Royal Beard Spa & Hot Towel Shave',
      'category': 'Beard & Shave',
      'description':
          'Essential oils massage, hot towel treatment, straight-razor detailing & beard balm.',
      'image':
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600',
      'price': 399.0,
      'duration': '30 mins',
      'rating': 4.8,
      'reviewCount': 210,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredServices {
    return _mockServices.where((service) {
      final matchesQuery = _query.isEmpty ||
          service['name']
              .toString()
              .toLowerCase()
              .contains(_query.toLowerCase()) ||
          service['category']
              .toString()
              .toLowerCase()
              .contains(_query.toLowerCase()) ||
          service['description']
              .toString()
              .toLowerCase()
              .contains(_query.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' || service['category'] == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredServices;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (val) => setState(() => _query = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search haircut, facial, spa, manicure...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
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

          // Result Count Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.background,
            child: Text(
              'Showing ${results.length} salon services',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Results List
          Expanded(
            child: results.isEmpty
                ? _buildEmptyResults()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final service = results[index];
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.serviceDetails,
              arguments: {'serviceId': service['id']},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppNetworkImage(
                    imageUrl: service['image'] as String,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          service['category'] as String,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['name'] as String,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['description'] as String,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppFormatters.formatCurrency(
                                    service['price'] as double),
                                style: AppTypography.priceMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 11, color: AppColors.textTertiary),
                                  const SizedBox(width: 3),
                                  Text(
                                    service['duration'] as String,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          AppButton(
                            text: 'Book',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Services Found',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We could not find any salon services matching "$_query". Try browsing categories or checking spelling.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
