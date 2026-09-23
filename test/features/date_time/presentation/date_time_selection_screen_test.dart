import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/date_time/data/datasources/date_time_remote_data_source.dart';
import 'package:prop_crm/features/date_time/data/repositories/date_time_repository_impl.dart';
import 'package:prop_crm/features/date_time/presentation/providers/date_time_provider.dart';
import 'package:prop_crm/features/date_time/presentation/screens/date_time_selection_screen.dart';
import 'package:provider/provider.dart';
import '../../../mocks/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  late MockDateTimeRemoteDataSource dataSource;
  late DateTimeRepositoryImpl repository;
  late DateTimeProvider provider;

  setUp(() {
    dataSource = MockDateTimeRemoteDataSource();
    repository = DateTimeRepositoryImpl(remoteDataSource: dataSource);
    provider = DateTimeProvider(repository: repository);
  });

  Widget buildTestApp(Widget screen) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DateTimeProvider>.value(value: provider),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: screen,
      ),
    );
  }

  group('DateTimeSelectionScreen Widget Tests', () {
    testWidgets('Renders service summary, date selector, and time slot grid',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          const DateTimeSelectionScreen(
            serviceId: 'srv_deep_clean',
            serviceName: 'Full Home Deep Clean',
            packageId: 'pkg_standard',
            packageName: 'Standard 2BHK',
          ),
        ),
      );

      // Advance async loading & frame callback
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // 1. Verify app bar title
      expect(find.text('Select Date & Time'), findsOneWidget);

      // 2. Verify service context summary
      expect(find.text('Full Home Deep Clean'), findsOneWidget);
      expect(find.text('Standard 2BHK'), findsOneWidget);

      // 3. Verify section headings
      expect(find.text('Select a date'), findsOneWidget);
      expect(find.text('Available time slots'), findsOneWidget);

      // 4. Verify Continue CTA button is rendered but disabled because slot is not selected yet
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);
      final elevatedButton = tester.widget<ElevatedButton>(continueButton);
      expect(elevatedButton.onPressed, isNull);

      // 5. Verify helper text
      expect(find.text('Please select an available time slot'), findsOneWidget);
    });

    testWidgets('Selecting an available time slot enables Continue CTA and tapping pops result',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Map<String, dynamic>? returnedResult;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<DateTimeProvider>.value(value: provider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    final res = await Navigator.of(context).push<Map<String, dynamic>>(
                      MaterialPageRoute(
                        builder: (_) => const DateTimeSelectionScreen(
                          serviceId: 'srv_deep_clean',
                          serviceName: 'Full Home Deep Clean',
                          packageId: 'pkg_standard',
                          packageName: 'Standard 2BHK',
                        ),
                      ),
                    );
                    returnedResult = res;
                  },
                  child: const Text('Open Picker'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap to open picker
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Find an available slot from the provider
      final availableSlots = provider.timeSlots.where((s) => s.isAvailable).toList();
      expect(availableSlots.isNotEmpty, isTrue);

      final slotToTap = availableSlots.first;
      final slotFinder = find.text(slotToTap.formattedLabel);
      expect(slotFinder, findsWidgets);

      // Tap the slot card
      await tester.tap(slotFinder.first);
      await tester.pumpAndSettle();

      // Verify provider now has the slot selected
      expect(provider.selectedTimeSlot?.id, slotToTap.id);
      expect(provider.isSelectionComplete, isTrue);

      // Continue button must now be enabled
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      final elevatedButton = tester.widget<ElevatedButton>(continueButton);
      expect(elevatedButton.onPressed, isNotNull);

      // Tap Continue
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verify returned result contains selectedDate and selectedTimeSlot
      expect(returnedResult, isNotNull);
      expect(returnedResult!['selectedDate'], equals(provider.selectedDate));
      expect(returnedResult!['selectedTimeSlot'], equals(provider.selectedTimeSlot));
    });

    testWidgets('Tapping a different date changes selection and re-renders slots',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          const DateTimeSelectionScreen(
            serviceId: 'srv_deep_clean',
            serviceName: 'Full Home Deep Clean',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      final initialDate = provider.selectedDate;
      expect(initialDate, isNotNull);

      // Tomorrow's date
      final secondDate = provider.availableDates[1];
      final dayNumberFinder = find.text(secondDate.dayNumber);
      expect(dayNumberFinder, findsWidgets);

      // Tap on tomorrow's card
      await tester.tap(dayNumberFinder.first);
      await tester.pumpAndSettle();

      expect(provider.selectedDate?.dateKey, secondDate.dateKey);
      expect(provider.selectedTimeSlot, isNull);
    });
  });
}
