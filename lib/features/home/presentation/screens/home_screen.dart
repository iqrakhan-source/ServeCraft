import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bookings/data/models/booking_model.dart';
import '../../../bookings/presentation/providers/booking_provider.dart';
import '../../../branches/data/models/branch_model.dart';
import '../../../branches/presentation/providers/branch_provider.dart';
import '../../../branches/presentation/screens/branch_details_screen.dart';
import '../../../branches/presentation/screens/branch_selection_screen.dart';
import '../../../services/presentation/screens/service_listing_screen.dart';
import '../../../services/presentation/screens/service_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _offerPageController = PageController(viewportFraction: 0.92);
  int _currentOfferPage = 0;
  Timer? _offerTimer;

  // Realistic mock offers
  final List<Map<String, String>> _mockOffers = [
    {
      'title': '20% OFF on Hair Services',
      'code': 'LUXE20',
      'subtitle': 'Valid on haircuts, balayage, and organic styling',
      'gradientStart': '0xFF8B5A42',
      'gradientEnd': '0xFF1C1917',
      'tag': 'MOST POPULAR',
    },
    {
      'title': 'Weekend Spa Special',
      'code': 'RELAX500',
      'subtitle': 'Flat ₹500 OFF on Moroccan Argan and detox therapies',
      'gradientStart': '0xFFB88E58',
      'gradientEnd': '0xFF2B211B',
      'tag': 'WEEKEND ONLY',
    },
    {
      'title': 'New Client Radiance Offer',
      'code': 'FIRSTGLOW',
      'subtitle': 'Flat ₹200 OFF on all Hydra Medi-Facials & skin glow',
      'gradientStart': '0xFF9E654C',
      'gradientEnd': '0xFF2D2328',
      'tag': 'EXCLUSIVE',
    },
  ];

  // Salon Categories
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Hair',
      'image': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      'icon': Icons.content_cut_rounded,
    },
    {
      'title': 'Skin',
      'image': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
      'icon': Icons.face_retouching_natural_rounded,
    },
    {
      'title': 'Makeup',
      'image': 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400',
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'title': 'Spa',
      'image': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400',
      'icon': Icons.spa_rounded,
    },
    {
      'title': 'Nails',
      'image': 'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=400',
      'icon': Icons.brush_rounded,
    },
  ];

  // Popular Services
  final List<Map<String, dynamic>> _popularServices = [
    {
      'id': 'srv_exec_haircut',
      'name': 'Executive Haircut & Styling',
      'price': 499.0,
      'duration': '45 mins',
      'rating': 4.9,
      'reviews': 380,
      'image': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600',
      'category': 'Hair',
    },
    {
      'id': 'srv_women_haircut',
      'name': 'Signature Cut & Blow Dry',
      'price': 899.0,
      'duration': '60 mins',
      'rating': 4.8,
      'reviews': 295,
      'image': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600',
      'category': 'Hair',
    },
    {
      'id': 'srv_hydra_facial',
      'name': 'Hydra Medi-Facial & Glow',
      'price': 1799.0,
      'duration': '60 mins',
      'rating': 4.9,
      'reviews': 510,
      'image': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=600',
      'category': 'Skin',
    },
    {
      'id': 'srv_moroccan_spa',
      'name': 'Moroccan Argan Hair Spa',
      'price': 1299.0,
      'duration': '60 mins',
      'rating': 4.8,
      'reviews': 240,
      'image': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600',
      'category': 'Spa',
    },
    {
      'id': 'srv_gel_mani_pedi',
      'name': 'Luxury Gel Mani & Pedi',
      'price': 1499.0,
      'duration': '75 mins',
      'rating': 4.8,
      'reviews': 190,
      'image': 'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=600',
      'category': 'Nails',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startOfferTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookingProvider>().loadBookings();
        context.read<BranchProvider>().loadBranches();
      }
    });
  }

  void _startOfferTimer() {
    _offerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_offerPageController.hasClients) return;
      final next = (_currentOfferPage + 1) % _mockOffers.length;
      _offerPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    _offerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final userName = user?.name.isNotEmpty == true ? user!.name.split(' ').first : 'Sophia';

    final branchProvider = context.watch<BranchProvider>();
    final selectedBranch = branchProvider.selectedBranch ??
        (branchProvider.branches.isNotEmpty ? branchProvider.branches.first : null);

    final bookingProvider = context.watch<BookingProvider>();
    final upcomingBookings = bookingProvider.upcomingBookings;
    final upcomingBooking = upcomingBookings.isNotEmpty ? upcomingBookings.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header (Greeting, Branch Selector, Notification, Avatar)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    // Customer Greeting & Branch
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hello, $userName',
                                style: AppTypography.titleLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.auto_awesome_rounded,
                                  size: 16, color: AppColors.secondary),
                            ],
                          ),
                          const SizedBox(height: 2),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BranchSelectionScreen(
                                      isSelectionMode: true),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    selectedBranch?.name ?? 'Downtown Luxury Lounge',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    size: 16, color: AppColors.textTertiary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification Icon with unread badge
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded,
                              size: 24, color: AppColors.textPrimary),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.notifications);
                          },
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Profile Avatar
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          userName.substring(0, 1).toUpperCase(),
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServiceSearchScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Search services, treatments, styling...',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Upcoming Appointment (if exists)
            if (upcomingBooking != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: _buildUpcomingAppointmentCard(upcomingBooking),
                ),
              ),

            // 4. Categories Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.categories);
                      },
                      child: Text(
                        'View All',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 104,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return _buildCategoryItem(cat);
                  },
                ),
              ),
            ),

            // 5. Offers Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_offer_rounded,
                            size: 18, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'Exclusive Salon Offers',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.offers);
                      },
                      child: Text(
                        'All Offers',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: _offerPageController,
                  itemCount: _mockOffers.length,
                  onPageChanged: (idx) => setState(() => _currentOfferPage = idx),
                  itemBuilder: (context, index) {
                    final offer = _mockOffers[index];
                    return _buildOfferBanner(offer);
                  },
                ),
              ),
            ),

            // 6. Popular Services
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Salon Services',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.serviceListing,
                          arguments: {'categoryName': 'Haircut & Styling'},
                        );
                      },
                      child: Text(
                        'View All',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _popularServices.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final service = _popularServices[index];
                    return _buildPopularServiceCard(service);
                  },
                ),
              ),
            ),

            // 7. Branches Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Our Salon Lounges',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.branchSelection,
                          arguments: {'isSelectionMode': false},
                        );
                      },
                      child: Text(
                        'All Branches',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final branches =
                        branchProvider.branches.where((b) => b.isActive).toList();
                    if (branches.isEmpty) return const SizedBox.shrink();
                    final branch = branches[index % branches.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBranchHomeCard(branch),
                    );
                  },
                  childCount: branchProvider.branches
                      .where((b) => b.isActive)
                      .length
                      .clamp(0, 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'UPCOMING APPOINTMENT',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.bookingReference,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            booking.service.name,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.storefront_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.branch?.name ?? 'Downtown Luxury Lounge',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '${booking.scheduledDate.dayName}, ${booking.scheduledDate.dayNumber} ${booking.scheduledDate.monthName} • ${booking.timeSlot.startTime}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'View Appointment Details',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.bookingDetails,
                arguments: {
                  'bookingId': booking.id,
                  'booking': booking,
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> cat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceListingScreen(category: cat['title']),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      imageUrl: cat['image'],
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                    Center(
                      child: Icon(
                        cat['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cat['title'],
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferBanner(Map<String, String> offer) {
    final startColor = Color(int.parse(offer['gradientStart']!));
    final endColor = Color(int.parse(offer['gradientEnd']!));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: startColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  offer['tag']!,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  offer['code']!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer['title']!,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                offer['subtitle']!,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularServiceCard(Map<String, dynamic> service) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, 2),
            blurRadius: 8,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Stack(
                  children: [
                    AppNetworkImage(
                      imageUrl: service['image'],
                      height: 115,
                      width: 170,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: AppColors.warning),
                            const SizedBox(width: 2),
                            Text(
                              service['rating'].toString(),
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'],
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service['duration'],
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppFormatters.formatCurrency(service['price']),
                          style: AppTypography.priceMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Book',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
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

  Widget _buildBranchHomeCard(BranchModel branch) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BranchDetailsScreen(branch: branch),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppNetworkImage(
                    imageUrl: branch.imageUrl,
                    width: 74,
                    height: 74,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        branch.address,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            branch.rating.toStringAsFixed(1),
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.schedule_rounded,
                              size: 12, color: AppColors.textTertiary),
                          const SizedBox(width: 3),
                          Text(
                            '${branch.openingTime} - ${branch.closingTime}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}