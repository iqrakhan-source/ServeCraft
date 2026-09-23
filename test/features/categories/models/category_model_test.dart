import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/categories/data/models/category_model.dart';

void main() {
  group('CategoryModel Serialization Tests', () {
    test('fromJson parses full JSON map correctly', () {
      final json = {
        'id': 'cat_cleaning',
        'name': 'Cleaning & Pest Control',
        'description': 'Professional home deep cleaning and disinfection',
        'image': 'https://example.com/cleaning.jpg',
        'icon': 'cleaning_services',
        'isActive': true,
        'displayOrder': 1,
      };

      final category = CategoryModel.fromJson(json);

      expect(category.id, equals('cat_cleaning'));
      expect(category.name, equals('Cleaning & Pest Control'));
      expect(category.description, equals('Professional home deep cleaning and disinfection'));
      expect(category.image, equals('https://example.com/cleaning.jpg'));
      expect(category.icon, equals('cleaning_services'));
      expect(category.isActive, isTrue);
      expect(category.displayOrder, equals(1));
    });

    test('fromJson handles null and missing optional fields with defaults', () {
      final json = {
        'id': 'cat_plumbing',
        'name': 'Plumbing',
      };

      final category = CategoryModel.fromJson(json);

      expect(category.id, equals('cat_plumbing'));
      expect(category.name, equals('Plumbing'));
      expect(category.description, equals(''));
      expect(category.image, isNull);
      expect(category.icon, isNull);
      expect(category.isActive, isTrue);
      expect(category.displayOrder, equals(0));
    });

    test('toJson produces correct JSON map', () {
      const category = CategoryModel(
        id: 'cat_electrical',
        name: 'Electrician',
        description: 'Wiring and appliance repair',
        image: 'https://example.com/elec.png',
        icon: 'electrical_services',
        isActive: true,
        displayOrder: 3,
      );

      final json = category.toJson();

      expect(json['id'], equals('cat_electrical'));
      expect(json['name'], equals('Electrician'));
      expect(json['description'], equals('Wiring and appliance repair'));
      expect(json['image'], equals('https://example.com/elec.png'));
      expect(json['icon'], equals('electrical_services'));
      expect(json['isActive'], isTrue);
      expect(json['displayOrder'], equals(3));
    });

    test('copyWith updates specified fields', () {
      const original = CategoryModel(
        id: 'cat_1',
        name: 'AC Service',
        description: 'Repair AC',
      );

      final updated = original.copyWith(name: 'AC Repair & Install');

      expect(updated.id, equals('cat_1'));
      expect(updated.name, equals('AC Repair & Install'));
      expect(updated.description, equals('Repair AC'));
    });
  });
}
