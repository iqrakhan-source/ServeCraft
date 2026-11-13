import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:prop_crm/core/utilities/formatters.dart';
import '../providers/subscription_provider.dart';
import '../../data/models/subscription_plan_model.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SubscriptionProvider>().loadSubscriptionPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership Plans'), centerTitle: true),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.plans.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.plans.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 42),
                    const SizedBox(height: 12),
                    Text(provider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.retry(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.plans.isEmpty) {
            return const Center(
              child: Text('No subscription plans available.'),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadSubscriptionPlans,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.plans.length,
              itemBuilder: (context, index) {
                final plan = provider.plans[index];
                return _SubscriptionPlanCard(plan: plan);
              },
            ),
          );
        },
      ),
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlanModel plan;

  const _SubscriptionPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  plan.tier,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppFormatters.formatCurrency(plan.price),
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Valid for ${plan.validityDays} days'),
            Text('${plan.discountPercentage}% discount'),
            if (plan.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(plan.description),
            ],
            if (plan.benefits.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Benefits',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...plan.benefits.map((benefit) => _BulletText(text: benefit)),
            ],
            if (plan.perks.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Perks',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...plan.perks.map((perk) => _BulletText(text: perk)),
            ],
            if (!plan.isGlobal && plan.branchName != null) ...[
              const SizedBox(height: 12),
              Text('Available at: ${plan.branchName}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
