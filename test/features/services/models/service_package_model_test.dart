import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

void main() {
  group('ServicePackageModel Serialization Tests', () {
    test('fromJson parses complete package JSON map correctly', () {
      final json = {
        'id': 'pkg_deep_clean',
        'serviceId': 'srv_kitchen_clean',
        'name': 'Deep Kitchen Disinfection',
        'description': 'Degreasing of chimneys, counters, tile scrub, and appliance clean',
        'price': 1499.0,
        'duration': '120 mins',
        'features': [
          'Chimney exterior & filters deep cleaned',
          'Countertop stain removal',
          'Tile scrubbing and grout whitening',
        ],
        'isActive': true,
      };

      final pkg = ServicePackageModel.fromJson(json);

      expect(pkg.id, equals('pkg_deep_clean'));
      expect(pkg.serviceId, equals('srv_kitchen_clean'));
      expect(pkg.name, equals('Deep Kitchen Disinfection'));
      expect(pkg.price, equals(1499.0));
      expect(pkg.duration, equals('120 mins'));
      expect(pkg.features.length, equals(3));
      expect(pkg.features[0], contains('Chimney exterior'));
      expect(pkg.isActive, isTrue);
    });

    test('fromJson handles empty or omitted optional fields', () {
      final json = {
        'id': 'pkg_basic',
        'serviceId': 'srv_1',
        'name': 'Basic Inspection',
      };

      final pkg = ServicePackageModel.fromJson(json);

      expect(pkg.id, equals('pkg_basic'));
      expect(pkg.serviceId, equals('srv_1'));
      expect(pkg.name, equals('Basic Inspection'));
      expect(pkg.description, equals(''));
      expect(pkg.price, equals(0.0));
      expect(pkg.duration, equals('60 mins'));
      expect(pkg.features, isEmpty);
      expect(pkg.isActive, isTrue);
    });

    test('toJson produces correct JSON map', () {
      const pkg = ServicePackageModel(
        id: 'pkg_express',
        serviceId: 'srv_tap_repair',
        name: 'Quick Leak Fix',
        description: 'Fix minor tap drips',
        price: 249.0,
        duration: '30 mins',
        features: ['Washer replacement', 'Pressure check'],
        isActive: true,
      );

      final json = pkg.toJson();

      expect(json['id'], equals('pkg_express'));
      expect(json['serviceId'], equals('srv_tap_repair'));
      expect(json['name'], equals('Quick Leak Fix'));
      expect(json['price'], equals(249.0));
      expect(json['duration'], equals('30 mins'));
      expect(json['features'], equals(['Washer replacement', 'Pressure check']));
      expect(json['isActive'], isTrue);
    });
  });
}
