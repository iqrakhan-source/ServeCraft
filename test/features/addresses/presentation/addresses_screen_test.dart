import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/addresses/data/datasources/address_remote_data_source.dart';
import 'package:prop_crm/features/addresses/data/repositories/address_repository_impl.dart';
import 'package:prop_crm/features/addresses/presentation/providers/address_provider.dart';
import 'package:prop_crm/features/addresses/presentation/screens/add_address_screen.dart';
import 'package:prop_crm/features/addresses/presentation/screens/addresses_screen.dart';
import 'package:provider/provider.dart';
import '../../../mocks/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  late MockAddressRemoteDataSource dataSource;
  late AddressRepositoryImpl repository;
  late AddressProvider addressProvider;

  setUp(() {
    dataSource = MockAddressRemoteDataSource();
    repository = AddressRepositoryImpl(remoteDataSource: dataSource);
    addressProvider = AddressProvider(repository: repository);
  });

  Widget buildTestApp(Widget screen) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AddressProvider>.value(value: addressProvider),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: screen,
      ),
    );
  }

  group('AddressesScreen & AddAddressScreen Widget Tests', () {
    testWidgets('AddressesScreen in selection mode renders addresses and allows selection',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(const AddressesScreen(isSelectionMode: true)),
      );

      // Advance mock timer
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Select Address'), findsOneWidget);

      // Verify mock addresses rendered
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Add New Address'), findsOneWidget);

      // Default address selected initially
      expect(find.text('Deliver to Home'), findsOneWidget);

      // Tap on Work address card
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      // CTA updates with selected address
      expect(find.text('Deliver to Work'), findsOneWidget);
    });

    testWidgets('AddressesScreen in management mode renders Saved Addresses',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(const AddressesScreen(isSelectionMode: false)),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Saved Addresses'), findsOneWidget);
      expect(find.text('Edit'), findsWidgets);
    });

    testWidgets('AddAddressScreen validates required fields and 6-digit PIN code',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const AddAddressScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add New Address'), findsOneWidget);

      // Tap save without filling required fields
      await tester.tap(find.text('Save Address'));
      await tester.pumpAndSettle();

      // Inline validation errors appear
      expect(find.text('House / Flat number is required'), findsOneWidget);
      expect(find.text('Address line is required'), findsOneWidget);
      expect(find.text('Pincode is required'), findsOneWidget);

      // Enter invalid PIN code
      await tester.enterText(
        find.widgetWithText(TextFormField, 'PIN Code *'),
        '123',
      );
      await tester.tap(find.text('Save Address'));
      await tester.pumpAndSettle();

      expect(find.text('Pincode must be 6 digits'), findsOneWidget);

      // Enter valid values
      await tester.enterText(
        find.widgetWithText(TextFormField, 'House / Flat / Block No. *'),
        'Apartment 101',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Apartment / Road / Locality *'),
        'Civil Lines',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'PIN Code *'),
        '302006',
      );

      await tester.tap(find.text('Save Address'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Address should now exist in provider
      expect(addressProvider.addresses.any((a) => a.houseNumber == 'Apartment 101'), isTrue);
    });
  });
}
