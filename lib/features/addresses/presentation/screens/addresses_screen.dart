import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_dialog.dart';
import 'package:prop_crm/core/widgets/app_empty_state.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../../data/models/address_model.dart';
import '../providers/address_provider.dart';
import '../widgets/address_card.dart';
import 'add_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  final bool isSelectionMode;

  const AddressesScreen({
    super.key,
    this.isSelectionMode = false,
  });

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  void _navigateToAddAddress(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddAddressScreen(),
      ),
    );
  }

  void _navigateToEditAddress(BuildContext context, AddressModel address) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(existingAddress: address),
      ),
    );
  }

  Future<void> _handleDeleteAddress(
    BuildContext context,
    AddressModel address,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'Delete address?',
      message: 'Are you sure you want to remove this saved address?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final success =
          await context.read<AddressProvider>().deleteAddress(address.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;
    final selectedAddress = addressProvider.selectedAddress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.isSelectionMode ? 'Select Address' : 'Saved Addresses',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined, size: 22),
            tooltip: 'Add New Address',
            onPressed: () => _navigateToAddAddress(context),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (addressProvider.isLoading) {
            return _buildLoadingList();
          }

          if (addressProvider.hasError) {
            return AppErrorView(
              message: addressProvider.errorMessage ??
                  'Failed to load saved addresses',
              onRetry: () =>
                  addressProvider.fetchAddresses(forceRefresh: true),
            );
          }

          if (addressProvider.isEmpty) {
            return AppEmptyState(
              icon: Icons.location_off_outlined,
              title: 'No Saved Addresses',
              subtitle: 'Add an address to easily book home services.',
              actionText: '+ Add New Address',
              onActionPressed: () => _navigateToAddAddress(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                addressProvider.fetchAddresses(forceRefresh: true),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Add New Address action header
                InkWell(
                  onTap: () => _navigateToAddAddress(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add New Address',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Address Cards list
                ...addresses.map(
                  (addr) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AddressCard(
                      address: addr,
                      isSelected: selectedAddress?.id == addr.id,
                      isSelectionMode: widget.isSelectionMode,
                      onTap: widget.isSelectionMode
                          ? () => addressProvider.selectAddress(addr)
                          : null,
                      onEdit: () => _navigateToEditAddress(context, addr),
                      onDelete: () => _handleDeleteAddress(context, addr),
                      onSetDefault: () =>
                          addressProvider.setDefaultAddress(addr.id),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.isSelectionMode
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    offset: Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: AppButton(
                  text: selectedAddress != null
                      ? 'Deliver to ${selectedAddress.label}'
                      : 'Select Address',
                  onPressed: selectedAddress != null
                      ? () {
                          // Return selected address to caller
                          Navigator.of(context).pop(selectedAddress);
                        }
                      : null,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppSkeleton(height: 18, width: 80, borderRadius: 6),
                  AppSkeleton(height: 18, width: 50, borderRadius: 4),
                ],
              ),
              SizedBox(height: 12),
              AppSkeleton(height: 14, width: double.infinity),
              SizedBox(height: 6),
              AppSkeleton(height: 12, width: 160),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSkeleton(height: 16, width: 60, borderRadius: 4),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
