import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/widgets/app_badge.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_empty_state.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';

void main() {
  group('Core Reusable Widgets Tests', () {
    testWidgets('AppButton renders text and triggers callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Click Me',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.text('Click Me'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AppButton shows loader when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit',
              isLoading: true,
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('AppBadge formats booking and payment statuses correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppBadge.bookingStatus('CONFIRMED'),
                AppBadge.bookingStatus('COMPLETED'),
                AppBadge.paymentStatus('SUCCESS'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
    });

    testWidgets('AppEmptyState renders title, subtitle, and action', (tester) async {
      bool actionClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Empty List',
              subtitle: 'No items available right now',
              actionText: 'Add Item',
              onActionPressed: () => actionClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Empty List'), findsOneWidget);
      expect(find.text('No items available right now'), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);

      await tester.tap(find.text('Add Item'));
      await tester.pump();
      expect(actionClicked, isTrue);
    });

    testWidgets('AppErrorView renders error message and retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              message: 'Failed to fetch network data',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Failed to fetch network data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);
    });
  });
}
