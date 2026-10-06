import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../providers/branch_provider.dart';
import '../widgets/branch_card.dart';
import 'branch_details_screen.dart';

class BranchSelectionScreen extends StatefulWidget {
  final bool isSelectionMode;

  const BranchSelectionScreen({
    super.key,
    this.isSelectionMode = true,
  });

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branchProvider = context.watch<BranchProvider>();
    final selectedBranch = branchProvider.selectedBranch;

    final allBranches = branchProvider.branches.where((b) => b.isActive).toList();
    final filteredBranches = allBranches.where((b) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return b.name.toLowerCase().contains(q) ||
          b.address.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.isSelectionMode ? 'Select Salon Branch' : 'Our Branches',
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by branch name or area...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
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

          // Informational Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primaryLight,
            child: Row(
              children: [
                const Icon(
                  Icons.store_mall_directory_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All appointments and service slots are tailored to your chosen salon branch.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main List
          Expanded(
            child: Builder(
              builder: (context) {
                if (branchProvider.isLoading) {
                  return const Center(child: AppLoadingIndicator());
                }

                if (branchProvider.branchesState.isError) {
                  return AppErrorView(
                    message: branchProvider.errorMessage ??
                        'Failed to load salon branches',
                    onRetry: () => branchProvider.loadBranches(),
                  );
                }

                if (filteredBranches.isEmpty) {
                  return const AppEmptyState(
                    title: 'No Active Salon Branches Found',
                    subtitle: 'Try adjusting your search query.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBranches.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final branch = filteredBranches[index];
                    final isSelected = selectedBranch?.id == branch.id;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BranchCard(
                          branch: branch,
                          isSelected: isSelected,
                          onTap: () {
                            final success = branchProvider.selectBranch(branch);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Selected ${branch.name}'),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                              if (widget.isSelectionMode) {
                                Navigator.of(context).pop(branch);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BranchDetailsScreen(branch: branch),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.info_outline_rounded,
                                  size: 15, color: AppColors.primary),
                              label: Text(
                                'View Branch Details',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
