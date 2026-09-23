import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

void main() {
  group('ServiceModel Serialization Tests', () {
    test('fromJson parses complete service JSON with nested packages', () {
      final json = {
        'id': 'srv_ac_jet',
        'categoryId': 'cat_ac',
        'name': 'AC Power Jet Servicing',
        'description': '2x deeper cooling service with high-pressure water jet technology',
        'image': 'https://example.com/ac_jet.jpg',
        'rating': 4.88,
        'reviewCount': 342,
        'startingPrice': 599.0,
        'duration': '45 mins',
        'isActive': true,
        'packages': [
          {
            'id': 'pkg_1_split',
            'serviceId': 'srv_ac_jet',
            'name': '1x Split AC Jet Service',
            'description': 'Deep indoor coil and outdoor fan jet wash',
            'price': 599.0,
            'duration': '45 mins',
            'features': ['Indoor filter clean', 'Outdoor condenser jet clean'],
          }
        ],
      };

      final service = ServiceModel.fromJson(json);

      expect(service.id, equals('srv_ac_jet'));
      expect(service.categoryId, equals('cat_ac'));
      expect(service.name, equals('AC Power Jet Servicing'));
      expect(service.description, contains('2x deeper cooling'));
      expect(service.image, equals('https://example.com/ac_jet.jpg'));
      expect(service.rating, equals(4.88));
      expect(service.reviewCount, equals(342));
      expect(service.startingPrice, equals(599.0));
      expect(service.duration, equals('45 mins'));
      expect(service.isActive, isTrue);
      expect(service.packages.length, equals(1));
      expect(service.packages.first.id, equals('pkg_1_split'));
      expect(service.packages.first.price, equals(599.0));
    });

    test('fromJson handles minimal JSON with default values', () {
      final json = {
        'id': 'srv_fan',
        'categoryId': 'cat_elec',
        'name': 'Ceiling Fan Repair',
        'startingPrice': 199.0,
      };

      final service = ServiceModel.fromJson(json);

      expect(service.id, equals('srv_fan'));
      expect(service.categoryId, equals('cat_elec'));
      expect(service.name, equals('Ceiling Fan Repair'));
      expect(service.description, equals(''));
      expect(service.image, isNull);
      expect(service.rating, equals(4.8));
      expect(service.reviewCount, equals(0));
      expect(service.startingPrice, equals(199.0));
      expect(service.duration, equals('60 mins'));
      expect(service.isActive, isTrue);
      expect(service.packages, isEmpty);
    });

    test('toJson serializes nested packages correctly', () {
      const pkg = ServicePackageModel(
        id: 'pkg_standard',
        serviceId: 'srv_tap',
        name: 'Standard Tap Repair',
        description: 'Single tap fixture repair',
        price: 199.0,
        duration: '30 mins',
        features: ['Leak fix'],
      );

      const service = ServiceModel(
        id: 'srv_tap',
        categoryId: 'cat_plumb',
        name: 'Tap Repair',
        description: 'Fix leaking or broken taps',
        startingPrice: 199.0,
        packages: [pkg],
      );

      final json = service.toJson();

      expect(json['id'], equals('srv_tap'));
      expect(json['categoryId'], equals('cat_plumb'));
      expect(json['packages'], isA<List>());
      expect((json['packages'] as List).length, equals(1));
      expect((json['packages'] as List).first['id'], equals('pkg_standard'));
    });
  });
}
