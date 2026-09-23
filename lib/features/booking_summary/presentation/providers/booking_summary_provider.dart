import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import '../../data/models/booking_summary_model.dart';
import '../../data/models/pricing_breakdown_model.dart';
import '../../domain/repositories/booking_summary_repository.dart';

class BookingSummaryProvider extends ChangeNotifier {
  final BookingSummaryRepository repository;

  ViewState<BookingSummaryModel> _summaryState = ViewState.initial();
  double _discount = 0.0;
  double _taxRate = PricingBreakdown.defaultTaxRate;

  BookingSummaryProvider({required this.repository});

  ViewState<BookingSummaryModel> get summaryState => _summaryState;
  BookingSummaryModel? get summary => _summaryState.data;

  bool get isLoading => _summaryState.isLoading;
  bool get hasError => _summaryState.isError;
  String? get errorMessage => _summaryState.errorMessage;
  bool get isValid => summary?.isValid ?? false;

  ServiceModel? get service => summary?.service;
  ServicePackageModel? get package => summary?.package;
  AddressModel? get address => summary?.address;
  ServiceDateModel? get scheduledDate => summary?.scheduledDate;
  TimeSlotModel? get timeSlot => summary?.timeSlot;
  PricingBreakdown? get pricing => summary?.pricing;

  /// Loads or calculates a full booking summary with all selections
  Future<void> loadSummary({
    required ServiceModel service,
    required ServicePackageModel package,
    required AddressModel address,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double? discount,
    double? taxRate,
  }) async {
    _discount = discount ?? _discount;
    _taxRate = taxRate ?? _taxRate;

    _summaryState = ViewState.loading();
    notifyListeners();

    try {
      final result = await repository.getBookingSummary(
        service: service,
        package: package,
        address: address,
        date: date,
        timeSlot: timeSlot,
        discount: _discount,
        taxRate: _taxRate,
      );

      _summaryState = ViewState.success(result);
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _summaryState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  /// Directly set a pre-calculated or loaded summary model
  void setSummary(BookingSummaryModel summary) {
    _summaryState = ViewState.success(summary);
    _discount = summary.pricing.discount;
    _taxRate = summary.pricing.taxRate;
    notifyListeners();
  }

  /// Updates the delivery address in the summary
  void updateAddress(AddressModel newAddress) {
    final current = summary;
    if (current == null) return;

    final updated = current.copyWith(address: newAddress);
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  /// Updates the scheduled date and time slot in the summary
  void updateSchedule(ServiceDateModel newDate, TimeSlotModel newSlot) {
    final current = summary;
    if (current == null) return;

    final updated = current.copyWith(
      scheduledDate: newDate,
      timeSlot: newSlot,
    );
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  /// Updates package and recalculates pricing breakdown
  Future<void> updatePackage(ServicePackageModel newPackage) async {
    final current = summary;
    if (current == null) return;

    await loadSummary(
      service: current.service,
      package: newPackage,
      address: current.address,
      date: current.scheduledDate,
      timeSlot: current.timeSlot,
      discount: _discount,
      taxRate: _taxRate,
    );
  }

  /// Clears the summary state
  void clear() {
    _summaryState = ViewState.initial();
    _discount = 0.0;
    notifyListeners();
  }
}
