
import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/models/service_date_model.dart';
import '../../data/models/time_slot_model.dart';
import '../../domain/repositories/date_time_repository.dart';

class DateTimeProvider extends ChangeNotifier {
  final DateTimeRepository repository;
  final StorageService? storageService;

  ViewState<List<ServiceDateModel>> _datesState = ViewState.initial();
  ViewState<List<TimeSlotModel>> _slotsState = ViewState.initial();

  ServiceDateModel? _selectedDate;
  TimeSlotModel? _selectedTimeSlot;

  String? _serviceId;
  String? _serviceName;
  String? _packageId;
  String? _packageName;
  String? _branchId;
  int? _duration;
  String? _stylistId;

  DateTimeProvider({
    required this.repository,
    this.storageService,
  });

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
  String? get branchId => _branchId;

  bool get isLoading => _datesState.isLoading || _slotsState.isLoading;
  bool get hasError => _datesState.isError || _slotsState.isError;

  String? get errorMessage =>
      _datesState.errorMessage ?? _slotsState.errorMessage;

  // Both a valid date and an available time slot must be selected.
  bool get isSelectionComplete =>
      _selectedDate != null &&
          _selectedDate!.isAvailable &&
          _selectedTimeSlot != null &&
          _selectedTimeSlot!.isAvailable;

  int? get duration => _duration;
  String? get stylistId => _stylistId;

  // Initialize booking context.
  void initContext({
    String? serviceId,
    String? serviceName,
    String? packageId,
    String? packageName,
    String? branchId,
    int? duration,
    String? stylistId,
  }) {
    final newServiceId = serviceId ?? _serviceId;
    final newBranchId = branchId ?? _branchId;

    // Clear previous selections when service or branch changes.
    if (_serviceId != newServiceId || _branchId != newBranchId) {
      _selectedDate = null;
      _selectedTimeSlot = null;
      _datesState = ViewState.initial();
      _slotsState = ViewState.initial();
    }

    _serviceId = newServiceId;
    _serviceName = serviceName ?? _serviceName;

    // Null is valid: a service may have no selected package.
    _packageId = packageId;
    _packageName = packageName;

    _branchId = newBranchId;
    _duration = duration ?? _duration;
    _stylistId = stylistId ?? _stylistId;

    debugPrint('========== DATE TIME CONTEXT ==========');
    debugPrint('Service ID: $_serviceId');
    debugPrint('Package ID: $_packageId');
    debugPrint('Branch ID: $_branchId');
    debugPrint('=======================================');

    notifyListeners();
  }

  // Load available dates.
  Future<void> loadAvailableDates({
    String? serviceId,
    String? packageId,
    bool forceRefresh = false,

  }) async {

    final sId = serviceId ?? _serviceId;
    final pId = packageId ?? _packageId;
    final bId = _branchId;
    debugPrint('[DATE TIME] Calling available dates API');
    debugPrint('[DATE TIME] Branch ID: $bId');

    if (sId == null || sId.trim().isEmpty) {
      _datesState = ViewState.error('Please select a valid service.');
      notifyListeners();
      return;
    }

    if (bId == null || bId.trim().isEmpty) {
      _datesState = ViewState.error('Please select a valid salon branch.');
      notifyListeners();
      return;
    }

    if (!forceRefresh &&
        _datesState.isSuccess &&
        availableDates.isNotEmpty) {
      debugPrint(
          '[DATE TIME] Returning cached dates: ${availableDates.length}',);
      return;
    }

    _datesState = ViewState.loading();
    notifyListeners();

    try {
      debugPrint('[DATE TIME] Calling repository.getAvailableDates()');
      debugPrint('[DATE TIME] Service ID: $sId');
      debugPrint('[DATE TIME] Branch ID: $bId');

      final dates = await repository.getAvailableDates(
        serviceId: sId,
        branchId: bId,
        packageId: pId,
      );

      if (dates.isEmpty) {
        _datesState = ViewState.empty();
        _selectedDate = null;
        _selectedTimeSlot = null;
        _slotsState = ViewState.empty();
      } else {
        _datesState = ViewState.success(dates);

        ServiceDateModel? targetDate;

        if (_selectedDate != null) {
          for (final date in dates) {
            if (date.dateKey == _selectedDate!.dateKey) {
              targetDate = date;
              break;
            }
          }
        }

        targetDate ??= dates.firstWhere(
              (date) => date.isAvailable,
          orElse: () => dates.first,
        );

        _selectedDate = targetDate;

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

  // Select a date and load its slots.
  Future<void> selectDate(ServiceDateModel date) async {
    if (!date.isAvailable) return;

    if (_selectedDate?.dateKey == date.dateKey) return;

    _selectedDate = date;
    _selectedTimeSlot = null;

    notifyListeners();

    if (date.slots.isNotEmpty) {
      _slotsState = ViewState.success(date.slots);
      notifyListeners();
    } else {
      await loadTimeSlots(date.date);
    }
  }

  // Load time slots for a specific date.
  Future<void> loadTimeSlots(DateTime date) async {
    final sId = _serviceId;

    debugPrint('========== LOAD TIME SLOTS ==========');
    debugPrint('Service ID: $sId');
    debugPrint('Branch ID: $_branchId');
    debugPrint('Package ID: $_packageId');
    debugPrint('Date: $date');
    debugPrint('=====================================');

    if (sId == null || sId.trim().isEmpty) {
      _slotsState = ViewState.error('Please select a valid service.');
      notifyListeners();
      return;
    }

    if (_branchId == null || _branchId!.trim().isEmpty) {
      debugPrint('ERROR: Branch ID is missing.');

      _slotsState = ViewState.error(
        'Please select a valid salon branch.',
      );
      notifyListeners();
      return;
    }

    _slotsState = ViewState.loading();
    notifyListeners();

    try {
      final slots = await repository.getTimeSlots(
        serviceId: sId,
        date: date,
        packageId: _packageId,
        branchId: _branchId!,
        duration: _duration,
        stylistId: _stylistId,
      );

      debugPrint('Slots returned: ${slots.length}');

      if (slots.isEmpty) {
        _slotsState = ViewState.empty();
        _selectedTimeSlot = null;
      } else {
        _slotsState = ViewState.success(slots);
      }
    } catch (e, stackTrace) {
      debugPrint('LOAD TIME SLOTS ERROR: $e');
      debugPrint('$stackTrace');

      final appError = ErrorHandler.handleError(e);

      _slotsState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  // Select an available time slot.
  void selectTimeSlot(TimeSlotModel slot) {
    if (!slot.isAvailable) return;

    _selectedTimeSlot = slot;
    notifyListeners();
  }

  // Clear current date and time selection.
  void clearSelection() {
    _selectedDate = null;
    _selectedTimeSlot = null;
    notifyListeners();
  }
}
