import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/app_network_image.dart';
import 'package:provider/provider.dart';

import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import '../providers/service_details_provider.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ServiceDetailsScreen> createState() =>
      _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ServiceDetailsProvider>()
          .fetchServiceDetails(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceDetailsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,

      // ============================================================
      // STICKY BOTTOM ACTION
      // ============================================================

      bottomNavigationBar: provider.service == null
          ? null
          : _buildBottomActionBar(provider),

      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(
              child: AppLoadingIndicator(
                message: 'Loading service...',
              ),
            );
          }

          if (provider.hasError) {
            return AppErrorView(
              message: provider.errorMessage ??
                  'Could not load service details',
              onRetry: () {
                provider.fetchServiceDetails(widget.serviceId);
              },
            );
          }

          final service = provider.service;

          if (service == null) {
            return const AppErrorView(
              message: 'Service not found',
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ======================================================
              // HERO IMAGE
              // ======================================================

              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,

                leading: _buildCircleAction(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),

                actions: [
                  _buildCircleAction(
                    icon: _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: _isFavorite
                        ? AppColors.error
                        : AppColors.textPrimary,
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(
                        imageUrl: service.image,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        borderRadius: 0,
                      ),

                      // Bottom gradient
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.15),
                                Colors.transparent,
                                Colors.black.withOpacity(0.45),
                              ],
                              stops: const [
                                0.0,
                                0.45,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Image badge
                      Positioned(
                        left: 16,
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ServeCraft Verified',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ======================================================
              // SERVICE INFORMATION
              // ======================================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    20,
                    18,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // TITLE
                      // ------------------------------------------------

                      Text(
                        service.name,
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ------------------------------------------------
                      // RATING + REVIEWS + TIME
                      // ------------------------------------------------

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  service.rating.toStringAsFixed(1),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            '${service.reviewCount} reviews',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 9,
                            ),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            service.duration,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ------------------------------------------------
                      // PRICE
                      // ------------------------------------------------

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Starting at ',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(
                              service.startingPrice,
                            ),
                            style: AppTypography.priceLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _buildDivider(),

                      const SizedBox(height: 24),

                      // =================================================
                      // WHAT YOU'LL GET
                      // =================================================

                      Text(
                        "What you'll get",
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildIncludedGrid(),

                      const SizedBox(height: 24),

                      // =================================================
                      // ABOUT SERVICE
                      // =================================================

                      Text(
                        'About this service',
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Text(
                        service.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                      ),

                      const SizedBox(height: 26),

                      _buildDivider(),

                      const SizedBox(height: 24),

                      // =================================================
                      // PACKAGES
                      // =================================================

                      if (service.packages.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Choose a package',
                              style: AppTypography.titleLarge.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${service.packages.length} options',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        ...service.packages.map(
                              (package) {
                            final isSelected =
                                provider.selectedPackage?.id ==
                                    package.id;

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: _buildPackageCard(
                                package: package,
                                isSelected: isSelected,
                                onTap: () {
                                  provider.selectPackage(package);
                                },
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 14),

                      // =================================================
                      // WHY SERVECRAFT
                      // =================================================

                      _buildWhyServeCraftCard(),

                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================================================================
  // CIRCLE HEADER ACTION
  // ================================================================

  Widget _buildCircleAction({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withOpacity(0.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // DIVIDER
  // ================================================================

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
    );
  }

  // ================================================================
  // WHAT YOU'LL GET
  // ================================================================

  Widget _buildIncludedGrid() {
    final items = [
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Verified professional',
      },
      {
        'icon': Icons.cleaning_services_outlined,
        'title': 'Professional equipment',
      },
      {
        'icon': Icons.schedule_outlined,
        'title': 'On-time service',
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': 'Service support',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.7,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  item['title'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================================================================
  // PACKAGE CARD
  // ================================================================

  Widget _buildPackageCard({
    required ServicePackageModel package,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLight
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.shadowMedium
                    : AppColors.shadow,
                blurRadius: isSelected ? 10 : 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------------
              // HEADER
              // --------------------------------------------------------

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    size: 22,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style:
                          AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              package.duration,
                              style:
                              AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    AppFormatters.formatCurrency(
                      package.price,
                    ),
                    style:
                    AppTypography.priceMedium.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              // --------------------------------------------------------
              // DESCRIPTION
              // --------------------------------------------------------

              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  package.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),

              // --------------------------------------------------------
              // FEATURES
              // --------------------------------------------------------

              if (package.features.isNotEmpty) ...[
                const SizedBox(height: 12),

                const Divider(
                  height: 1,
                  color: AppColors.border,
                ),

                const SizedBox(height: 10),

                ...package.features.map(
                      (feature) => Padding(
                    padding: const EdgeInsets.only(
                      left: 32,
                      bottom: 6,
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            feature,
                            style:
                            AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // WHY SERVECRAFT
  // ================================================================

  Widget _buildWhyServeCraftCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  'Why choose ServeCraft?',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildTrustItem(
            icon: Icons.person_search_outlined,
            title: 'Verified professionals',
            subtitle:
            'Trusted service professionals for your home.',
          ),

          const SizedBox(height: 12),

          _buildTrustItem(
            icon: Icons.receipt_long_outlined,
            title: 'Transparent pricing',
            subtitle:
            'See package pricing before you book.',
          ),

          const SizedBox(height: 12),

          _buildTrustItem(
            icon: Icons.support_agent_outlined,
            title: 'Reliable support',
            subtitle:
            'We are here if you need help with your booking.',
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // BOTTOM ACTION BAR
  // ================================================================

  Widget _buildBottomActionBar(
      ServiceDetailsProvider provider,
      ) {
    final service = provider.service!;

    final selectedPackage = provider.selectedPackage;

    final price =
        selectedPackage?.price ?? service.startingPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // --------------------------------------------------------
            // PRICE
            // --------------------------------------------------------

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  selectedPackage == null
                      ? 'Starting from'
                      : 'Selected package',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  AppFormatters.formatCurrency(price),
                  style: AppTypography.priceLarge.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 18),

            // --------------------------------------------------------
            // CONTINUE
            // --------------------------------------------------------

            Expanded(
              child: AppButton(
                text: selectedPackage == null
                    ? 'Choose Package'
                    : 'Continue',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.packageSelection,
                    arguments: {
                      'serviceId': service.id,
                      'serviceName': service.name,
                      'packageId': selectedPackage?.id,
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}