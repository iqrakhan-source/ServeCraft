import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository repository;

  ViewState<List<PaymentMethodModel>> _methodsState = ViewState.initial();
  PaymentMethodModel? _selectedMethod;
  BookingSummaryModel? _bookingSummary;
  bool _isProcessing = false;

  PaymentProvider({required this.repository});

  ViewState<List<PaymentMethodModel>> get methodsState => _methodsState;
  List<PaymentMethodModel> get paymentMethods => _methodsState.data ?? [];
  PaymentMethodModel? get selectedMethod => _selectedMethod;
  BookingSummaryModel? get bookingSummary => _bookingSummary;

  bool get isLoading => _methodsState.isLoading;
  bool get hasError => _methodsState.isError;
  String? get errorMessage => _methodsState.errorMessage;
  bool get isProcessing => _isProcessing;

  /// Payable amount strictly derived from the Booking Summary source of truth
  double get payableAmount => _bookingSummary?.pricing.totalAmount ?? 0.0;

  /// Selection is valid only when an available payment method is selected
  bool get isSelectionValid =>
      _selectedMethod != null && _selectedMethod!.isAvailable;

  /// Updates or syncs the active booking summary context
  void setBookingSummary(BookingSummaryModel? summary) {
    _bookingSummary = summary;
    notifyListeners();
  }

  /// Loads available payment options without auto-selecting any method
  Future<void> loadPaymentMethods({bool forceRefresh = false}) async {
    if (!forceRefresh && _methodsState.isSuccess && paymentMethods.isNotEmpty) {
      return;
    }

    _methodsState = ViewState.loading();
    notifyListeners();

    try {
      final methods = await repository.getPaymentMethods();
      if (methods.isEmpty) {
        _methodsState = ViewState.empty();
        _selectedMethod = null;
      } else {
        _methodsState = ViewState.success(methods);
        // Preserve selected method if still present and valid, otherwise keep unselected
        if (_selectedMethod != null) {
          final exists = methods.any((m) => m.id == _selectedMethod!.id);
          if (!exists) {
            _selectedMethod = null;
          }
        }
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _methodsState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  /// Selects a payment method if available
  void selectPaymentMethod(PaymentMethodModel method) {
    if (!method.isAvailable) {
      return;
    }
    _selectedMethod = method;
    notifyListeners();
  }

  /// Clears the active selection
  void clearSelection() {
    _selectedMethod = null;
    notifyListeners();
  }

  /// Sets processing state
  void setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }
}
