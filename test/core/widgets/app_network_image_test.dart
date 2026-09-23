import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/widgets/app_network_image.dart';

void main() {
  group('AppNetworkImage Tests', () {
    testWidgets('renders fallback icon when imageUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage(
              imageUrl: null,
              fallbackIcon: Icons.home_repair_service_rounded,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home_repair_service_rounded), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders fallback icon when imageUrl is empty or whitespace', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage(
              imageUrl: '   ',
              fallbackIcon: Icons.broken_image_rounded,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.broken_image_rounded), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders Image widget when valid imageUrl is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage(
              imageUrl: 'https://example.com/clean.jpg',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });
}
