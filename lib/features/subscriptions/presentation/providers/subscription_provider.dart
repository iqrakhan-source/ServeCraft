import 'package:flutter/foundation.dart';
import '../../data/models/subscription_invoice_model.dart';
import '../../data/models/subscription_plan_model.dart';
import '../../data/models/subscription_purchase_response_model.dart';
import '../../data/repositories/subscription_repository.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository repository;

  SubscriptionProvider({required this.repository});

  List<SubscriptionPlanModel> _plans = [];
  List<SubscriptionInvoiceModel> _invoices = [];

  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _error;
  String? _purchaseSuccessMessage;

  List<SubscriptionPlanModel> get plans => _plans;
  List<SubscriptionInvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get error => _error;
  String? get purchaseSuccessMessage => _purchaseSuccessMessage;

  Future<void> loadSubscriptionPlans({String? branchId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await repository.getSubscriptionPlans(branchId: branchId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInvoices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _invoices = await repository.getSubscriptionInvoices();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SubscriptionPurchaseResponseModel?> purchaseSubscription({
    required String planId,
    required String branchId,
    required String paymentMethod,
  }) async {
    _isPurchasing = true;
    _error = null;
    _purchaseSuccessMessage = null;
    notifyListeners();

    try {
      final result = await repository.purchaseSubscription(
        planId: planId,
        branchId: branchId,
        paymentMethod: paymentMethod,
      );
      _purchaseSuccessMessage = result.message;
      await loadInvoices();
      return result;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isPurchasing = false;
      notifyListeners();
    }
  }

  Future<void> retry({String? branchId}) {
    return loadSubscriptionPlans(branchId: branchId);
  }
}
