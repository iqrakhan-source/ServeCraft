import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import '../providers/loyalty_provider.dart';

class LoyaltyWalletScreen extends StatefulWidget {
  const LoyaltyWalletScreen({super.key});

  @override
  State<LoyaltyWalletScreen> createState() => _LoyaltyWalletScreenState();
}

class _LoyaltyWalletScreenState extends State<LoyaltyWalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Loyalty Rewards',
        showBackButton: true,
      ),
      body: Consumer<LoyaltyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.wallet == null) {
            return const Center(child: AppLoadingIndicator());
          }

          if (provider.walletState.isError && provider.wallet == null) {
            return AppErrorView(
              message:
                  provider.walletState.errorMessage ??
                  'Failed to load loyalty wallet',
              onRetry: () => provider.refresh(),
            );
          }

          final wallet = provider.wallet;

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Wallet Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1E2C), Color(0xFF2D2B52)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'REWARDS BALANCE',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              wallet?.tier.toUpperCase() ?? 'STANDARD',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${wallet?.loyaltyPoints ?? 0}',
                            style: AppTypography.displayLarge.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Points',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppFormatters.formatCurrency(wallet?.rupeeValue ?? 0),
                            style: AppTypography.titleLarge.copyWith(
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            'Cashback Rate',
                            '${wallet?.cashbackRate.toStringAsFixed(0) ?? 5}%',
                          ),
                          _buildStatItem(
                            'Max Redemption',
                            '${wallet?.maxRedemptionPercentage.toStringAsFixed(0) ?? 10}%',
                          ),
                          _buildStatItem(
                            'Lifetime Earned',
                            '${wallet?.lifetimeEarnedPoints ?? 0} pts',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Transaction Ledger Header
                Text(
                  'Transaction History',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (provider.transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text(
                      'No transactions yet. Complete appointments to earn cashback points!',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...provider.transactions.map((tx) {
                    final isPositive = tx.isEarn || tx.isRefund;
                    final formattedDate = DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(tx.createdAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPositive
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          child: Icon(
                            isPositive
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: isPositive
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE53935),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          tx.description.isNotEmpty
                              ? tx.description
                              : (tx.isEarn
                                    ? 'Points Earned'
                                    : 'Points Redeemed'),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isPositive ? '+' : ''}${tx.points}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isPositive
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE53935),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bal: ${tx.balanceAfter}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
