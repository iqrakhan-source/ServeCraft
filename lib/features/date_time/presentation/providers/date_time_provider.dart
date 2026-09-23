import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/service_date_model.dart';
import '../../data/models/time_slot_model.dart';
import '../../domain/repositories/date_time_repository.dart';

class DateTimeProvider extends ChangeNotifier {
  final DateTimeRepository repository;

  ViewState<List<ServiceDateModel>> _datesState = ViewState.initial();
  ViewState<List<TimeSlotModel>> _slotsState = ViewState.initial();

  ServiceDateModel? _selectedDate;
  TimeSlotModel? _selectedTimeSlot;

  String? _serviceId;
  String? _serviceName;
  String? _packageId;
  String? _packageName;

  DateTimeProvider({required this.repository});

  ViewState<List<ServiceDateModel>> get datesState => _datesState;
  ViewState<List<TimeSlotModel>> get slotsState => _slotsState;

  List<ServiceDateModel> get availableDates => _datesState.data ?? [];
  List<TimeSlotModel> get timeSlots => _slotsState.data ?? [];

  ServiceDateModel? get selectedDate => _selectedDate;
  TimeSlotModel? get selectedTimeSlot => _selectedTimeSlot;

  String? get serviceId => _serviceId;
  String? get serviceName => _serviceName;
  String? get packageId => _packageId;
  String? get packageName => _packageName;

  bool get isLoading => _datesState.isLoading || _slotsState.isLoading;
  bool get hasError => _datesState.isError || _slotsState.isError;
  String? get errorMessage => _datesState.errorMessage ?? _slotsState.errorMessage;

  /// Both a valid date and an available time slot must be selected
  bool get isSelectionComplete =>
      _selectedDate != null &&
      _selectedDate!.isAvailable &&
      _selectedTimeSlot != null &&
      _selectedTimeSlot!.isAvailable;

  /// Initialize service & package context passed from previous flow
  void initContext({
    String? serviceId,
    String? serviceName,
    String? packageId,
    String? packageName,
  }) {
    _serviceId = serviceId ?? _serviceId;
    _serviceName = serviceName ?? _serviceName;
    _packageId = packageId ?? _packageId;
    _packageName = packageName ?? _packageName;
    notifyListeners();
  }

  /// Load available dates for the specified service
  Future<void> loadAvailableDates({
    String? serviceId,
    String? packageId,
    bool forceRefresh = false,
  }) async {
    final sId = serviceId ?? _serviceId ?? 'srv_default';
    final pId = packageId ?? _packageId;

    if (!forceRefresh && _datesState.isSuccess && availableDates.isNotEmpty) {
      return;
    }

    _datesState = ViewState.loading();
    notifyListeners();

    try {
      final dates = await repository.getAvailableDates(
        serviceId: sId,
        packageId: pId,
      );

      if (dates.isEmpty) {
        _datesState = ViewState.empty();
        _selectedDate = null;
        _slotsState = ViewState.empty();
      } else {
        _datesState = ViewState.success(dates);

        // Auto-select the first available date if nothing is selected or current selection is invalid
        ServiceDateModel? targetDate;
        if (_selectedDate != null) {
          try {
            targetDate = dates.firstWhere((d) => d.dateKey == _selectedDate!.dateKey);
          } catch (_) {
            targetDate = null;
          }
        }

        targetDate ??= dates.firstWhere(
          (d) => d.isAvailable,
          orElse: () => dates.first,
        );

        _selectedDate = targetDate;

        // Populate slots for the selected date
        if (targetDate.slots.isNotEmpty) {
          _slotsState = ViewState.success(targetDate.slots);
        } else {
          await loadTimeSlots(targetDate.date);
        }
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _datesState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  /// Select a date and update the available time slots
  Future<void> selectDate(ServiceDateModel date) async {
    if (!date.isAvailable) {
      // Disallowed: date is unavailable
      return;
    }

    if (_selectedDate?.dateKey == date.dateKey) {
      return;
    }

    _selectedDate = date;
    _selectedTimeSlot = null; // Clear previously selected time slot
    notifyListeners();

    if (date.slots.isNotEmpty) {
      _slotsState = ViewState.success(date.slots);
      notifyListeners();
    } else {
      await loadTimeSlots(date.date);
    }
  }

  /// Load time slots for a specific date
  Future<void> loadTimeSlots(DateTime date) async {
    final sId = _serviceId ?? 'srv_default';

    _slotsState = ViewState.loading();
    notifyListeners();

    try {
      final slots = await repository.getTimeSlots(
        serviceId: sId,
        date: date,
        packageId: _packageId,
      );

      if (slots.isEmpty) {
        _slotsState = ViewState.empty();
      } else {
        _slotsState = ViewState.success(slots);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _slotsState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  /// Select a time slot
  void selectTimeSlot(TimeSlotModel slot) {
    if (!slot.isAvailable) {
      // Slot is fully booked or past
      return;
    }
    _selectedTimeSlot = slot;
    notifyListeners();
  }

  /// Clear the current date & slot selection
  void clearSelection() {
    _selectedDate = null;
    _selectedTimeSlot = null;
    notifyListeners();
  }
}
