
import 'package:flutter/foundation.dart';

import '../../data/models/subscription_plan_model.dart';
import '../../data/repositories/subscription_repository.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository repository;

  SubscriptionProvider({
    required this.repository,
  });

  List<SubscriptionPlanModel> _plans = [];

  bool _isLoading = false;
  String? _error;

  List<SubscriptionPlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSubscriptionPlans({String? branchId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await repository.getSubscriptionPlans(
        branchId: branchId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry({String? branchId}) {
    return loadSubscriptionPlans(branchId: branchId);
  }
}
