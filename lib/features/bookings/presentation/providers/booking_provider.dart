import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/cancel_booking_request_model.dart';
import '../../data/models/create_booking_request_model.dart';
import '../../domain/repositories/booking_repository.dart';

enum BookingFilter {
  all('All'),
  upcoming('Upcoming'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const BookingFilter(this.label);
}

class BookingProvider extends ChangeNotifier {
  final BookingRepository repository;

  // Booking creation state
  ViewState<BookingModel> _bookingState = ViewState.initial();
  BookingModel? _createdBooking;

  // Bookings list state
  ViewState<List<BookingModel>> _bookingsState = ViewState.initial();
  BookingFilter _activeFilter = BookingFilter.all;

  // Booking details state
  ViewState<BookingModel> _detailsState = ViewState.initial();
  BookingModel? _selectedBooking;

  // Booking cancellation state
  ViewState<BookingModel> _cancellationState = ViewState.initial();

  // Booking rescheduling state
  ViewState<BookingModel> _rescheduleState = ViewState.initial();

  BookingProvider({required this.repository});

  // Cancellation getters
  ViewState<BookingModel> get cancellationState => _cancellationState;
  bool get isCancelling => _cancellationState.isLoading;
  String? get cancellationError => _cancellationState.errorMessage;

  // Rescheduling getters
  ViewState<BookingModel> get rescheduleState => _rescheduleState;
  bool get isRescheduling => _rescheduleState.isLoading;
  String? get rescheduleError => _rescheduleState.errorMessage;

  // Creation getters
  ViewState<BookingModel> get bookingState => _bookingState;
  BookingModel? get createdBooking => _createdBooking;
  bool get isCreating => _bookingState.isLoading;
  bool get isSuccess => _bookingState.isSuccess;
  bool get hasError => _bookingState.isError;
  String? get errorMessage => _bookingState.errorMessage;

  // Bookings list getters
  ViewState<List<BookingModel>> get bookingsState => _bookingsState;
  List<BookingModel> get bookings => _bookingsState.data ?? const [];
  BookingFilter get activeFilter => _activeFilter;
  bool get isLoadingBookings => _bookingsState.isLoading;
  String? get bookingsErrorMessage => _bookingsState.errorMessage;
  List<BookingModel> get upcomingBookings => bookings
      .where((b) =>
          b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.pending ||
          b.status == BookingStatus.rescheduled)
      .toList();

  // Booking details getters
  ViewState<BookingModel> get detailsState => _detailsState;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoadingDetails => _detailsState.isLoading;
  String? get detailsErrorMessage => _detailsState.errorMessage;

  /// Filtered list of bookings based on active tab
  List<BookingModel> get filteredBookings {
    final list = bookings;
    switch (_activeFilter) {
      case BookingFilter.all:
        return list;
      case BookingFilter.upcoming:
        return list
            .where((b) =>
                b.status == BookingStatus.confirmed ||
                b.status == BookingStatus.pending ||
                b.status == BookingStatus.rescheduled)
            .toList();
      case BookingFilter.completed:
        return list
            .where((b) => b.status == BookingStatus.completed)
            .toList();
      case BookingFilter.cancelled:
        return list
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
    }
  }

  /// Changes the active booking filter tab
  void setFilter(BookingFilter filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    notifyListeners();
  }

  /// Loads all bookings for the authenticated user session
  Future<void> loadBookings({bool forceRefresh = false}) async {
    if (isLoadingBookings) return;
    if (!forceRefresh && _bookingsState.isSuccess && _bookingsState.data != null) {
      return;
    }

    _bookingsState = ViewState.loading();
    notifyListeners();

    try {
      final list = await repository.getBookings();
      _bookingsState = ViewState.success(list);
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _bookingsState = ViewState.error(appError.message);
    }

    notifyListeners();
  }

  /// Loads full details for a single booking by ID
  Future<BookingModel?> loadBookingDetails(String bookingId) async {
    if (isLoadingDetails) return null;

    _detailsState = ViewState.loading();
    notifyListeners();

    try {
      final booking = await repository.getBookingById(bookingId);
      _selectedBooking = booking;
      _detailsState = ViewState.success(booking);
      notifyListeners();
      return booking;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _detailsState = ViewState.error(appError.message);
      notifyListeners();
      return null;
    }
  }

  /// Directly set the currently focused booking model
  void setSelectedBooking(BookingModel? booking) {
    _selectedBooking = booking;
    if (booking != null) {
      _detailsState = ViewState.success(booking);
    }
    notifyListeners();
  }

  /// Verifies all required checkout information exists and is sound
  bool validateCheckout({
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  }) {
    if (summary == null || !summary.isValid) {
      _bookingState = ViewState.error(
        'Some required booking information is missing. Please complete all previous steps.',
      );
      notifyListeners();
      return false;
    }

    if (paymentMethod == null || !paymentMethod.isAvailable) {
      _bookingState = ViewState.error(
        'Please select a valid payment method before confirming your booking.',
      );
      notifyListeners();
      return false;
    }

    if (summary.pricing.totalAmount <= 0) {
      _bookingState = ViewState.error(
        'Invalid payable amount. Please review your booking summary.',
      );
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Confirms and creates a booking from review summary
  Future<BookingModel?> createBooking({
    required BookingSummaryModel summary,
    required PaymentMethodModel paymentMethod,
  }) async {
    if (isCreating) return null;

    if (!validateCheckout(summary: summary, paymentMethod: paymentMethod)) {
      return null;
    }

    _bookingState = ViewState.loading();
    notifyListeners();

    try {
      final request = CreateBookingRequestModel.fromSummaryAndPayment(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      final booking = await repository.createBooking(
        request: request,
        summary: summary,
        paymentMethod: paymentMethod,
      );

      _createdBooking = booking;
      _bookingState = ViewState.success(booking);

      // Prepend to current bookings collection if already loaded
      if (_bookingsState.isSuccess && _bookingsState.data != null) {
        final currentList = List<BookingModel>.from(_bookingsState.data!);
        currentList.insert(0, booking);
        _bookingsState = ViewState.success(currentList);
      }

      notifyListeners();
      return booking;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _bookingState = ViewState.error(appError.message);
      notifyListeners();
      return null;
    }
  }

  /// Direct assignment helper for testing / navigation arguments
  void setCreatedBooking(BookingModel booking) {
    _createdBooking = booking;
    _bookingState = ViewState.success(booking);
    notifyListeners();
  }

  /// Cancels an active/eligible booking (Enforces strict 2-hour salon policy)
  Future<BookingModel?> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  }) async {
    if (isCancelling) return null;

    final effectiveRequest = request ??
        CancelBookingRequestModel(
          bookingId: bookingId ?? '',
          reason: reason ?? '',
          reasonNote: reasonNote,
        );

    final targetBooking = _selectedBooking ??
        bookings.cast<BookingModel?>().firstWhere(
              (b) => b?.id == effectiveRequest.bookingId,
              orElse: () => null,
            );

    // Business rule: Check 2-hour cancellation lockout
    if (targetBooking != null && !targetBooking.isCancellable) {
      _cancellationState = ViewState.error(
        'Appointments cannot be cancelled within 2 hours of the scheduled time.',
      );
      notifyListeners();
      return null;
    }

    _cancellationState = ViewState.loading();
    notifyListeners();

    try {
      final updatedBooking =
          await repository.cancelBooking(request: effectiveRequest);

      if (_selectedBooking != null &&
          (_selectedBooking!.id == updatedBooking.id ||
              _selectedBooking!.bookingReference ==
                  updatedBooking.bookingReference)) {
        _selectedBooking = updatedBooking;
        _detailsState = ViewState.success(updatedBooking);
      }

      if (_bookingsState.isSuccess && _bookingsState.data != null) {
        final currentList = List<BookingModel>.from(_bookingsState.data!);
        final index = currentList.indexWhere(
          (b) =>
              b.id == updatedBooking.id ||
              b.bookingReference == updatedBooking.bookingReference,
        );
        if (index != -1) {
          currentList[index] = updatedBooking;
          _bookingsState = ViewState.success(currentList);
        }
      }

      _cancellationState = ViewState.success(updatedBooking);
      notifyListeners();
      return updatedBooking;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _cancellationState = ViewState.error(appError.message);
      notifyListeners();
      return null;
    }
  }

  /// Reschedules an active booking to a new slot (Enforces strict 2-hour salon policy)
  Future<BookingModel?> rescheduleBooking({
    required String bookingId,
    required ServiceDateModel newDate,
    required TimeSlotModel newSlot,
  }) async {
    if (isRescheduling) return null;

    final targetBooking = _selectedBooking ??
        bookings.cast<BookingModel?>().firstWhere(
              (b) => b?.id == bookingId,
              orElse: () => null,
            );

    // Business rule: Check 2-hour rescheduling lockout
    if (targetBooking != null && !targetBooking.isReschedulable) {
      _rescheduleState = ViewState.error(
        'Appointments cannot be rescheduled within 2 hours of the scheduled time.',
      );
      notifyListeners();
      return null;
    }

    _rescheduleState = ViewState.loading();
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final updatedBooking = (targetBooking ?? _selectedBooking)!.copyWith(
        scheduledDate: newDate,
        timeSlot: newSlot,
        status: BookingStatus.rescheduled,
        rescheduledAt: DateTime.now(),
      );

      if (_selectedBooking != null && _selectedBooking!.id == bookingId) {
        _selectedBooking = updatedBooking;
        _detailsState = ViewState.success(updatedBooking);
      }

      if (_bookingsState.isSuccess && _bookingsState.data != null) {
        final currentList = List<BookingModel>.from(_bookingsState.data!);
        final index = currentList.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          currentList[index] = updatedBooking;
          _bookingsState = ViewState.success(currentList);
        }
      }

      _rescheduleState = ViewState.success(updatedBooking);
      notifyListeners();
      return updatedBooking;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _rescheduleState = ViewState.error(appError.message);
      notifyListeners();
      return null;
    }
  }

  /// Resets cancellation state
  void resetCancellationState() {
    _cancellationState = ViewState.initial();
    notifyListeners();
  }

  /// Resets rescheduling state
  void resetRescheduleState() {
    _rescheduleState = ViewState.initial();
    notifyListeners();
  }

  /// Resets booking creation state
  void reset() {
    _bookingState = ViewState.initial();
    _createdBooking = null;
    notifyListeners();
  }
}
