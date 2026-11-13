import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import '../../../services/data/models/service_products_response.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/booking_pricing_response_model.dart';
import '../../data/models/cancel_booking_request_model.dart';
import '../../data/models/create_booking_request_model.dart';
import '../../data/models/create_booking_response_model.dart';
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
  ViewState<CreateBookingResponseModel> _bookingState = ViewState.initial();

  CreateBookingResponseModel? _createdBooking;

  // Booking pricing state
  ViewState<BookingPricingResponseModel> _pricingState = ViewState.initial();

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
  ViewState<CreateBookingResponseModel> get bookingState => _bookingState;
  CreateBookingResponseModel? get createdBooking => _createdBooking;
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
      .where(
        (b) =>
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.rescheduled,
      )
      .toList();

  // Booking details getters
  ViewState<BookingModel> get detailsState => _detailsState;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoadingDetails => _detailsState.isLoading;
  String? get detailsErrorMessage => _detailsState.errorMessage;

  // Pricing getters
  ViewState<BookingPricingResponseModel> get pricingState => _pricingState;

  BookingPricingResponseModel? get calculatedPricing => _pricingState.data;

  bool get isCalculatingPricing => _pricingState.isLoading;

  String? get pricingErrorMessage => _pricingState.errorMessage;

  /// Filtered list of bookings based on active tab
  List<BookingModel> get filteredBookings {
    final list = bookings;
    switch (_activeFilter) {
      case BookingFilter.all:
        return list;
      case BookingFilter.upcoming:
        return list
            .where(
              (b) =>
                  b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.pending ||
                  b.status == BookingStatus.rescheduled,
            )
            .toList();
      case BookingFilter.completed:
        return list.where((b) => b.status == BookingStatus.completed).toList();
      case BookingFilter.cancelled:
        return list.where((b) => b.status == BookingStatus.cancelled).toList();
    }
  }

  /// Changes the active booking filter tab
  void setFilter(BookingFilter filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    notifyListeners();
  }

  /// Loads all bookings for the authenticated user session
  Future<void> loadBookings({bool forceRefresh = false, String? status}) async {
    if (isLoadingBookings) return;
    if (!forceRefresh &&
        _bookingsState.isSuccess &&
        _bookingsState.data != null &&
        status == null) {
      return;
    }

    _bookingsState = ViewState.loading();
    notifyListeners();

    try {
      final list = await repository.getBookings(status: status);
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

  /// Calculates booking subtotal, discount, tax, and final amount.
  Future<BookingPricingResponseModel?> calculatePricing({
    required String branchId,
    required List<Map<String, dynamic>> items,
    String? date,
    String? timeSlot,
    String? couponCode,
    bool? useLoyaltyPoints,
    int? pointsToRedeem,
  }) async {
    if (_pricingState.isLoading) return null;

    if (branchId.trim().isEmpty || items.isEmpty) {
      _pricingState = ViewState.error(
        'Branch and at least one service item are required.',
      );
      notifyListeners();
      return null;
    }

    _pricingState = ViewState.loading();
    notifyListeners();

    try {
      final pricing = await repository.calculatePricing(
        branchId: branchId,
        date: date,
        timeSlot: timeSlot,
        items: items,
        couponCode: couponCode,
        useLoyaltyPoints: useLoyaltyPoints,
        pointsToRedeem: pointsToRedeem,
      );

      _pricingState = ViewState.success(pricing);
      notifyListeners();

      return pricing;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _pricingState = ViewState.error(appError.message);
      notifyListeners();

      return null;
    }
  }

  /// Confirms and creates a booking from review summary
  Future<CreateBookingResponseModel?> createBooking({
    required BookingSummaryModel summary,
    required PaymentMethodModel paymentMethod,
    ConsumableProduct? selectedProduct,
  }) async {
    if (isCreating) return null;

    if (!validateCheckout(summary: summary, paymentMethod: paymentMethod)) {
      return null;
    }

    final branchId = summary.branch?.id;

    if (branchId == null || branchId.isEmpty) {
      _bookingState = ViewState.error('Please select a branch before booking.');
      notifyListeners();
      return null;
    }

    _bookingState = ViewState.loading();
    notifyListeners();

    try {
      final request = CreateBookingRequestModel.fromSummaryAndPayment(
        summary: summary,
        paymentMethod: paymentMethod,
        branchId: branchId,
        productId: selectedProduct?.id ?? '',
      );

      final bookingResponse = await repository.createBooking(
        request: request,
        summary: summary,
        paymentMethod: paymentMethod,
      );

      _createdBooking = bookingResponse;
      _bookingState = ViewState.success(bookingResponse);

      notifyListeners();
      return bookingResponse;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _bookingState = ViewState.error(appError.message);
      notifyListeners();
      return null;
    }
  }

  /// Direct assignment helper for testing / navigation arguments
  void setCreatedBooking(CreateBookingResponseModel booking) {
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

    final effectiveRequest =
        request ??
        CancelBookingRequestModel(
          bookingId: bookingId ?? '',
          reason: reason ?? '',
          reasonNote: reasonNote,
        );

    final targetBooking =
        _selectedBooking ??
        bookings.cast<BookingModel?>().firstWhere(
          (b) =>
              b?.id == effectiveRequest.bookingId ||
              b?.bookingReference == effectiveRequest.bookingId,
          orElse: () => null,
        );

    if (targetBooking != null &&
        targetBooking.status == BookingStatus.cancelled) {
      _cancellationState = ViewState.error(
        'This appointment has already been cancelled.',
      );
      notifyListeners();
      return null;
    }

    if (targetBooking != null &&
        targetBooking.status == BookingStatus.completed) {
      _cancellationState = ViewState.error(
        'Completed appointments cannot be cancelled.',
      );
      notifyListeners();
      return null;
    }

    _cancellationState = ViewState.loading();
    notifyListeners();

    try {
      final cancelledResponse = await repository.cancelBooking(
        request: effectiveRequest,
      );

      final updatedBooking =
          (targetBooking ?? _selectedBooking)?.copyWith(
            status: BookingStatus.cancelled,
            cancellationReason: effectiveRequest.reason,
            cancellationNote: effectiveRequest.reasonNote,
            cancelledAt: DateTime.now(),
          ) ??
          cancelledResponse;

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
    String? reason,
  }) async {
    if (isRescheduling) return null;

    final targetBooking =
        _selectedBooking ??
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
      final dateStr = newDate.date.toIso8601String().split('T').first;
      final timeStr = newSlot.bookingTimeSlot;

      await repository.rescheduleBooking(
        bookingId: bookingId,
        date: dateStr,
        timeSlot: timeStr,
        reason: reason,
      );

      final updatedBooking =
          (targetBooking ?? _selectedBooking)?.copyWith(
            scheduledDate: newDate,
            timeSlot: newSlot,
            status: BookingStatus.rescheduled,
            rescheduledAt: DateTime.now(),
          ) ??
          BookingModel(
            id: bookingId,
            bookingReference: bookingId,
            status: BookingStatus.rescheduled,
            service: const ServiceModel(
              id: '',
              categoryId: '',
              name: 'Salon Service',
              description: '',
              startingPrice: 0,
              duration: '45 mins',
            ),
            package: const ServicePackageModel(
              id: '',
              serviceId: '',
              name: 'Standard',
              description: '',
              price: 0,
              duration: '45 mins',
              features: [],
            ),
            address: const AddressModel(
              id: '',
              userId: '',
              label: '',
              houseNumber: '',
              addressLine: '',
              city: '',
              state: '',
              pincode: '',
            ),
            scheduledDate: newDate,
            timeSlot: newSlot,
            paymentMethod: const PaymentMethodModel(
              id: '',
              title: '',
              subtitle: '',
              type: PaymentMethodType.upi,
            ),
            pricing: const PricingBreakdown(
              packagePrice: 0,
              discount: 0,
              taxRate: 0,
              taxAmount: 0,
              totalAmount: 0,
            ),
            createdAt: DateTime.now(),
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

  /// Submits customer review and rating for an appointment
  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      return await repository.submitReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
    } catch (_) {
      return false;
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
    _pricingState = ViewState.initial();
    notifyListeners();
  }
}
