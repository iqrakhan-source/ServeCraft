import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';

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

  final List<String> _filters = [
    'All',
    'Popular',
    'Top Rated',
    'Under ₹500',
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Deep Home Cleaning',
      'subtitle': 'Complete home cleaning service',
      'image':
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
      'price': 799,
      'rating': '4.9',
      'reviews': '2.4k',
      'duration': '2 hrs',
      'tag': 'Bestseller',
    },
    {
      'title': 'Full Home Cleaning',
      'subtitle': 'Detailed cleaning for your home',
      'image':
      'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?w=800',
      'price': 999,
      'rating': '4.8',
      'reviews': '1.8k',
      'duration': '2.5 hrs',
      'tag': 'Popular',
    },
    {
      'title': 'Bathroom Cleaning',
      'subtitle': 'Deep cleaning and sanitization',
      'image':
      'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
      'price': 399,
      'rating': '4.9',
      'reviews': '3.1k',
      'duration': '1 hr',
      'tag': 'Top Rated',
    },
    {
      'title': 'Kitchen Cleaning',
      'subtitle': 'Deep cleaning for kitchen spaces',
      'image':
      'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=800',
      'price': 499,
      'rating': '4.8',
      'reviews': '2.2k',
      'duration': '1.5 hrs',
      'tag': 'Popular',
    },
    {
      'title': 'Sofa Cleaning',
      'subtitle': 'Professional sofa deep cleaning',
      'image':
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
      'price': 449,
      'rating': '4.7',
      'reviews': '1.2k',
      'duration': '1 hr',
      'tag': 'Value',
    },
    {
      'title': 'Move-in Cleaning',
      'subtitle': 'Get your new home ready',
      'image':
      'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800',
      'price': 1299,
      'rating': '4.9',
      'reviews': '980',
      'duration': '3 hrs',
      'tag': 'Premium',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryName =
    widget.categoryName?.isNotEmpty == true
        ? widget.categoryName!
        : 'Home Services';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(categoryName),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  0,
                ),
                child: _buildSearchBar(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  0,
                ),
                child: _buildCategoryIntro(categoryName),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 22,
                  bottom: 4,
                ),
                child: _buildFilters(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  22,
                  16,
                  14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Popular in $categoryName',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${_services.length} services',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                110,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final service = _services[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: _buildServiceCard(service),
                    );
                  },
                  childCount: _services.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  Widget _buildAppBar(String categoryName) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: false,

      titleSpacing: 16,

      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      title: Text(
        categoryName,
        style: AppTypography.titleLarge.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),

      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search for services',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
            icon: const Icon(
              Icons.tune_rounded,
              color: AppColors.primary,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildCategoryIntro(String categoryName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$categoryName services',
          style: AppTypography.displayMedium.copyWith(
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Trusted professionals, transparent pricing and '
              'convenient service at your doorstep.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            _buildTrustItem(
              Icons.verified_rounded,
              'Verified pros',
            ),
            const SizedBox(width: 18),
            _buildTrustItem(
              Icons.star_rounded,
              'Top rated',
            ),
            const SizedBox(width: 18),
            _buildTrustItem(
              Icons.shield_outlined,
              'Safe & reliable',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrustItem(
      IconData icon,
      String text,
      ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == _selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Text(
                filter,
                style: AppTypography.labelLarge.copyWith(
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SERVICE CARD
  // ============================================================

  Widget _buildServiceCard(
      Map<String, dynamic> service,
      ) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          _openService(service);
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    service['image'],
                    width: 118,
                    height: 128,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 118,
                        height: 128,
                        color: AppColors.primaryLight,
                        child: const Icon(
                          Icons.home_repair_service_rounded,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 13),

                // DETAILS
                Expanded(
                  child: SizedBox(
                    height: 128,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        if (service['tag'] != null)
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius:
                              BorderRadius.circular(6),
                            ),
                            child: Text(
                              service['tag'],
                              style: AppTypography.labelSmall
                                  .copyWith(
                                color: AppColors.primaryDark,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),

                        const SizedBox(height: 7),

                        Text(
                          service['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium
                              .copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          service['subtitle'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall
                              .copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const Spacer(),

                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              service['rating'],
                              style: AppTypography.labelLarge
                                  .copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${service['reviews']})',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(width: 7),
                            Container(
                              width: 3,
                              height: 3,
                              decoration:
                              const BoxDecoration(
                                color:
                                AppColors.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              service['duration'],
                              style: AppTypography.bodySmall
                                  .copyWith(
                                color:
                                AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        Row(
                          children: [
                            Text(
                              '₹${service['price']}',
                              style: AppTypography.priceMedium
                                  .copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const Spacer(),

                            SizedBox(
                              height: 34,
                              child: OutlinedButton(
                                onPressed: () {
                                  _openService(service);
                                },
                                style:
                                OutlinedButton.styleFrom(
                                  foregroundColor:
                                  AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      9,
                                    ),
                                  ),
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 15,
                                  ),
                                ),
                                child: const Text(
                                  'Add',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SERVICE ACTION
  // ============================================================

  void _openService(
      Map<String, dynamic> service,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                service['title'],
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                service['subtitle'],
                style: AppTypography.bodyMedium,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  _buildBottomSheetInfo(
                    Icons.star_rounded,
                    service['rating'],
                  ),
                  const SizedBox(width: 20),
                  _buildBottomSheetInfo(
                    Icons.schedule_rounded,
                    service['duration'],
                  ),
                  const SizedBox(width: 20),
                  _buildBottomSheetInfo(
                    Icons.currency_rupee_rounded,
                    'From ${service['price']}',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    // TODO:
                    // Navigate to booking flow.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Continue to Book',
                    style: AppTypography.buttonLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetInfo(
      IconData icon,
      String value,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.primary,
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}