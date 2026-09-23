import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_card_skeleton.dart';

class MyBookingsScreen extends StatefulWidget {
  final bool isTab;

  const MyBookingsScreen({
    super.key,
    this.isTab = false,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookingProvider>().loadBookings();
      }
    });
  }

  void _navigateToBookingDetails(BuildContext context, BookingModel booking) {
    context.read<BookingProvider>().setSelectedBooking(booking);
    Navigator.of(context).pushNamed(
      AppRoutes.bookingDetails,
      arguments: {
        'bookingId': booking.id,
        'booking': booking,
      },
    );
  }

  void _navigateToExplore(BuildContext context) {
    if (widget.isTab) {
      // If we are in the main nav tab, switch back to home or push
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.mainNav,
        (route) => false,
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.mainNav,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Bookings',
        showBackButton: !widget.isTab,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // 1. Status Filter Tabs
              _buildFilterTabs(provider),

              // 2. Main Content Area
              Expanded(
                child: _buildContent(context, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BookingProvider provider) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: BookingFilter.values.map((filter) {
            final isSelected = provider.activeFilter == filter;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => provider.setFilter(filter),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    filter.label,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected
                          ? AppColors.textInverse
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BookingProvider provider) {
    if (provider.isLoadingBookings) {
      return _buildLoadingSkeleton();
    }

    if (provider.bookingsState.isError) {
      return _buildErrorState(context, provider);
    }

    final bookings = provider.filteredBookings;

    if (bookings.isEmpty) {
      if (provider.bookings.isEmpty) {
        return _buildOverallEmptyState(context);
      } else {
        return _buildFilterEmptyState(provider.activeFilter);
      }
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.loadBookings(forceRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        itemCount: bookings.length,
        separatorBuilder: (_, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            onTap: () => _navigateToBookingDetails(context, booking),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: 3,
      separatorBuilder: (_, index) => const SizedBox(height: 14),
      itemBuilder: (_, index) => const BookingCardSkeleton(),
    );
  }

  Widget _buildErrorState(BuildContext context, BookingProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Couldn't load your bookings",
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.bookingsErrorMessage ?? 'Please check your connection and try again.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Retry',
              isFullWidth: false,
              onPressed: () => provider.loadBookings(forceRefresh: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallEmptyState(BuildContext context) {
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
                Icons.calendar_month_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No bookings yet',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your booked services will appear here.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            AppButton(
              text: 'Explore Services',
              isFullWidth: false,
              onPressed: () => _navigateToExplore(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterEmptyState(BookingFilter filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.filter_list_off_rounded,
                size: 42,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No ${filter.label.toLowerCase()} bookings yet',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${filter.label.toLowerCase()} services will appear here.',
              style: AppTypography.bodyMedium.copyWith(
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
