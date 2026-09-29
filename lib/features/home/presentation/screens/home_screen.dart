import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/features/home/presentation/screens/story_section.dart';
import 'package:prop_crm/features/services/presentation/screens/service_listing_screen.dart';

import '../widgets/home_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  int _currentBanner = 0;
  Timer? _bannerTimer;

  // ============================================================
  // BANNER IMAGES
  // ============================================================

  final List<String> _headerImages = [
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c',
    'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea',
    'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0',
  ];

  // ============================================================
  // SERVICES
  // ============================================================

  final List<Map<String, String>> _services = [
    {
      'title': 'Cleaning',
      'image':
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=300',
    },
    {
      'title': 'Plumbing',
      'image':
      'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=300',
    },
    {
      'title': 'Electrical',
      'image':
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=300',
    },
    {
      'title': 'AC Service',
      'image':
      'https://images.unsplash.com/photo-1631545806609-7c8d7e5f4b5f?w=300',
    },
    {
      'title': 'Painting',
      'image':
      'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=300',
    },
    {
      'title': 'Carpentry',
      'image':
      'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=300',
    },
    {
      'title': 'Pest Control',
      'image':
      'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?w=300',
    },
    {
      'title': 'More',
      'image':
      'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=300',
    },
  ];

  // ============================================================
  // NEW & NOTEWORTHY
  // ============================================================

  final List<Map<String, String>> _newServices = [
    {
      'title': 'Full Home Cleaning',
      'image':
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600',
      'price': '₹999',
      'rating': '4.8',
      'time': '2 hrs',
    },
    {
      'title': 'AC Service & Repair',
      'image':
      'https://images.unsplash.com/photo-1631545806609-7c8d7e5f4b5f?w=600',
      'price': '₹499',
      'rating': '4.7',
      'time': '1 hr',
    },
    {
      'title': 'Bathroom Cleaning',
      'image':
      'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600',
      'price': '₹399',
      'rating': '4.9',
      'time': '1 hr',
    },
    {
      'title': 'Home Painting',
      'image':
      'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=600',
      'price': '₹1,499',
      'rating': '4.8',
      'time': '4 hrs',
    },
  ];

  // ============================================================
  // MOST BOOKED
  // ============================================================

  final List<Map<String, String>> _mostBooked = [
    {
      'title': 'Deep Home Cleaning',
      'image':
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600',
      'price': '₹799',
      'rating': '4.9',
      'time': '2 hrs',
    },
    {
      'title': 'Kitchen Cleaning',
      'image':
      'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600',
      'price': '₹499',
      'rating': '4.8',
      'time': '1 hr',
    },
    {
      'title': 'Fan & Light Repair',
      'image':
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600',
      'price': '₹299',
      'rating': '4.7',
      'time': '45 mins',
    },
    {
      'title': 'Bathroom Deep Cleaning',
      'image':
      'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600',
      'price': '₹599',
      'rating': '4.9',
      'time': '1.5 hrs',
    },
  ];

  // ============================================================
  // AUTO SLIDE
  // ============================================================

  void _startBannerAutoSlide() {
    _bannerTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) {
        if (!mounted || !_pageController.hasClients) {
          return;
        }

        final nextPage = (_currentBanner + 1) % _headerImages.length;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startBannerAutoSlide();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ======================================================
            // HEADER
            // ======================================================

            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,

              automaticallyImplyLeading: false,

              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,

              expandedHeight: 128,
              toolbarHeight: 64,

              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final topPadding = MediaQuery.of(context).padding.top;

                  final currentHeight = constraints.biggest.height;

                  const double expandedHeight = 128;
                  const double collapsedHeight = 64;

                  final collapseProgress =
                  ((currentHeight - collapsedHeight) /
                      (expandedHeight - collapsedHeight))
                      .clamp(0.0, 1.0);

                  return Container(
                    color: AppColors.surface,
                    child: Stack(
                      children: [
                        // =====================================================
                        // UPPER LOCATION HEADER
                        // =====================================================

                        Positioned(
                          top: topPadding + 10,
                          left: 16,
                          right: 16,
                          child: Opacity(
                            opacity: collapseProgress,
                            child: SizedBox(
                              height: 42,
                              child: Row(
                                children: [
                                  // LOCATION
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_outlined,
                                      color: AppColors.primary,
                                      size: 21,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // ADDRESS
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your location',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                            fontSize: 11,
                                            color:
                                            AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Your Address',
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                            color:
                                            AppColors.textPrimary,
                                            fontWeight:
                                            FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // NOTIFICATION
                                  _buildSliverHeaderIcon(
                                    icon:
                                    Icons.notifications_none_rounded,
                                    onTap: () {},
                                  ),

                                  const SizedBox(width: 8),

                                  // PROFILE
                                  _buildSliverHeaderIcon(
                                    icon:
                                    Icons.person_outline_rounded,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // =====================================================
                        // SEARCH BAR
                        // =====================================================

                        Positioned(
                          left: 16,
                          right: 16,

                          // Moves from below the header
                          // to the top as the app bar collapses.
                          top: Tween<double>(
                            begin: topPadding + 62,
                            end: topPadding + 8,
                          ).transform(
                            1 - collapseProgress,
                          ),

                          child: const SizedBox(
                            height: 48,
                            child: HomeSearchBar(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ======================================================
            // SERVICES
            // ======================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  28,
                  16,
                  0,
                ),
                child: _buildServicesSection(),
              ),
            ),

            // ======================================================
            // PROMOTIONAL BANNER
            // ======================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  28,
                  16,
                  0,
                ),
                child: _buildPromoBanner(),
              ),
            ),

            // ======================================================
            // NEW & NOTEWORTHY
            // ======================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  30,
                  0,
                  0,
                ),
                child: _buildServiceSection(
                  title: 'New & Noteworthy',
                  services: _newServices,
                ),
              ),
            ),

            // ======================================================
            // CURATED STORIES
            // ======================================================

            const SliverToBoxAdapter(
              child: CuratedStoriesSection(),
            ),

            // ======================================================
            // MOST BOOKED
            // ======================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  30,
                  0,
                  100,
                ),
                child: _buildServiceSection(
                  title: 'Most Booked',
                  services: _mostBooked,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER ICON
  // ============================================================

  Widget _buildSliverHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 21,
        ),
      ),
    );
  }

  // ============================================================
  // SERVICES SECTION
  // ============================================================

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.categories,
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'View all',
                style: AppTypography.buttonMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _services.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 18,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final service = _services[index];

            return _buildServiceItem(
              title: service['title']!,
              image: service['image']!,
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // SERVICE ITEM
  // ============================================================

  Widget _buildServiceItem({
    required String title,
    required String image,
  }) {
    return InkWell(
      onTap: () {
        if (title == 'More') {
          Navigator.pushNamed(
            context,
            AppRoutes.categories,
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceListingScreen(
              category: title,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              image,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.home_repair_service_outlined,
                  color: AppColors.primary,
                  size: 28,
                );
              },
            ),
          ),

          const SizedBox(height: 7),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROMOTIONAL BANNER
  // ============================================================

  Widget _buildPromoBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 190,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _headerImages.length,
              onPageChanged: (index) {
                if (!mounted) return;

                setState(() {
                  _currentBanner = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  _headerImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: AppColors.primary,
                    );
                  },
                );
              },
            ),

            // GRADIENT
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.70),
                      Colors.black.withOpacity(0.10),
                    ],
                  ),
                ),
              ),
            ),

            // TEXT
            Positioned(
              left: 18,
              top: 24,
              right: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MAKE YOUR HOME',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Feel brand new',
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Professional home services at your doorstep.',
                    maxLines: 2,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 14),

                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.categories,
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Book Now',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // DOTS
            Positioned(
              bottom: 14,
              left: 18,
              child: Row(
                children: List.generate(
                  _headerImages.length,
                      (index) {
                    final bool active =
                        index == _currentBanner;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 5),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SERVICE CAROUSEL SECTION
  // ============================================================

  Widget _buildServiceSection({
    required String title,
    required List<Map<String, String>> services,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 238,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: services.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final service = services[index];

              return _buildPopularServiceCard(
                title: service['title']!,
                image: service['image']!,
                price: service['price']!,
                rating: service['rating']!,
                time: service['time']!,
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SERVICE CARD
  // ============================================================

  Widget _buildPopularServiceCard({
    required String title,
    required String image,
    required String price,
    required String rating,
    required String time,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceListingScreen(
              category: title,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            SizedBox(
              height: 125,
              width: double.infinity,
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: AppColors.primaryLight,
                    child: const Icon(
                      Icons.home_repair_service_outlined,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  );
                },
              ),
            ),

            // DETAILS
            Padding(
              padding: const EdgeInsets.fromLTRB(
                11,
                10,
                11,
                10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.amber,
                      ),

                      const SizedBox(width: 3),

                      Text(
                        rating,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Expanded(
                        child: Text(
                          time,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Text(
                    'Starting $price',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}