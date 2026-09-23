import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:prop_crm/features/payment/domain/repositories/payment_repository.dart';
import 'package:prop_crm/features/payment/presentation/providers/payment_provider.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

class FailingPaymentRepository implements PaymentRepository {
  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    throw Exception('Failed to load payment methods');
  }
}

void main() {
  late MockPaymentRemoteDataSource dataSource;
  late PaymentRepositoryImpl repository;
  late PaymentProvider provider;

  final sampleSummary = BookingSummaryModel(
    service: const ServiceModel(
      id: 'srv_1',
      categoryId: 'cat_1',
      name: 'Full Home Deep Clean',
      description: 'Cleaning',
      startingPrice: 999.0,
    ),
    package: const ServicePackageModel(
      id: 'pkg_1',
      serviceId: 'srv_1',
      name: 'Premium 3BHK',
      description: '3BHK',
      price: 999.0,
      duration: '2 hrs',
      features: ['Deep wash'],
    ),
    address: const AddressModel(
      id: 'addr_1',
      userId: 'user_1',
      label: 'Home',
      houseNumber: 'Flat 302',
      addressLine: 'Royal Palms',
      city: 'Jaipur',
      state: 'Rajasthan',
      pincode: '302021',
    ),
    scheduledDate: ServiceDateModel(
      date: DateTime(2026, 9, 26),
      isAvailable: true,
    ),
    timeSlot: const TimeSlotModel(
      id: 'slot_1',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      isAvailable: true,
    ),
    pricing: PricingBreakdown.calculate(
      packagePrice: 999.0,
      discount: 100.0,
    ),
  );

  setUp(() {
    dataSource = MockPaymentRemoteDataSource();
    repository = PaymentRepositoryImpl(remoteDataSource: dataSource);
    provider = PaymentProvider(repository: repository);
  });

  group('PaymentProvider State Management Tests', () {
    test('Initial state is clean and unselected', () {
      expect(provider.methodsState.isInitial, isTrue);
      expect(provider.selectedMethod, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.isSelectionValid, isFalse);
      expect(provider.payableAmount, 0.0);
    });

    test('loadPaymentMethods populates options without auto-selecting', () async {
      await provider.loadPaymentMethods();

      expect(provider.methodsState.isSuccess, isTrue);
      expect(provider.paymentMethods.length, 3);
      // Acceptance criterion Case 1: no method auto-selected
      expect(provider.selectedMethod, isNull);
      expect(provider.isSelectionValid, isFalse);
    });

    test('Selecting payment method and switching method updates state correctly',
        () async {
      await provider.loadPaymentMethods();

      final upiMethod = provider.paymentMethods.firstWhere(
        (m) => m.type == PaymentMethodType.upi,
      );
      final cardMethod = provider.paymentMethods.firstWhere(
        (m) => m.type == PaymentMethodType.card,
      );

      // Select UPI
      provider.selectPaymentMethod(upiMethod);
      expect(provider.selectedMethod, equals(upiMethod));
      expect(provider.isSelectionValid, isTrue);

      // Switch to Card
      provider.selectPaymentMethod(cardMethod);
      expect(provider.selectedMethod, equals(cardMethod));
      expect(provider.isSelectionValid, isTrue);
    });

    test('Selecting unavailable payment method is ignored', () async {
      await provider.loadPaymentMethods();

      const unavailableMethod = PaymentMethodModel(
        id: 'pm_unavail',
        title: 'Net Banking',
        subtitle: 'Unavailable',
        type: PaymentMethodType.card,
        isAvailable: false,
      );

      provider.selectPaymentMethod(unavailableMethod);
      expect(provider.selectedMethod, isNull);
      expect(provider.isSelectionValid, isFalse);
    });

    test('clearSelection resets selected payment method', () async {
      await provider.loadPaymentMethods();
      provider.selectPaymentMethod(provider.paymentMethods.first);
      expect(provider.isSelectionValid, isTrue);

      provider.clearSelection();
      expect(provider.selectedMethod, isNull);
      expect(provider.isSelectionValid, isFalse);
    });

    test('setBookingSummary updates payable amount from pricing source of truth',
        () {
      expect(provider.payableAmount, 0.0);

      provider.setBookingSummary(sampleSummary);
      expect(provider.bookingSummary, equals(sampleSummary));
      expect(provider.payableAmount, 1061.0);
    });

    test('Error handling in loadPaymentMethods sets error state', () async {
      final failingRepo = FailingPaymentRepository();
      final failingProvider = PaymentProvider(repository: failingRepo);

      await failingProvider.loadPaymentMethods();

      expect(failingProvider.methodsState.isError, isTrue);
      expect(failingProvider.hasError, isTrue);
      expect(failingProvider.errorMessage, isNotNull);
    });
  });
}
