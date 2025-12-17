import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('Category toJson and fromJson should work correctly', () {
      final category = Category(
        id: 'test',
        name: 'Test Category',
        icon: '📝',
        isCustom: true,
      );

      final json = category.toJson();
      final categoryFromJson = Category.fromJson(json);

      expect(categoryFromJson.id, category.id);
      expect(categoryFromJson.name, category.name);
      expect(categoryFromJson.icon, category.icon);
      expect(categoryFromJson.isCustom, category.isCustom);
    });

    test('Category fromJson should use default icon when icon is missing', () {
      final json = {
        'id': 'test',
        'name': 'Test Category',
        'isCustom': true,
      };

      final categoryFromJson = Category.fromJson(json);
      expect(categoryFromJson.icon, '📁');
    });

    test('Category fromJson should default isCustom to true when missing', () {
      final json = {
        'id': 'test',
        'name': 'Test Category',
        'icon': '📝',
      };

      final categoryFromJson = Category.fromJson(json);
      expect(categoryFromJson.isCustom, true);
    });

    test('Category copyWith should create a new category with updated fields',
        () {
      final category = Category(
        id: 'test',
        name: 'Test Category',
        icon: '📝',
        isCustom: true,
      );

      final updatedCategory = category.copyWith(name: 'Updated Category');

      expect(updatedCategory.name, 'Updated Category');
      expect(updatedCategory.id, category.id);
      expect(updatedCategory.icon, category.icon);
      expect(updatedCategory.isCustom, category.isCustom);
    });

    test('Category equality should be based on id', () {
      final category1 = Category(
        id: 'test',
        name: 'Test Category',
        icon: '📝',
        isCustom: true,
      );

      final category2 = Category(
        id: 'test',
        name: 'Different Name',
        icon: '🎯',
        isCustom: false,
      );

      expect(category1, equals(category2));
      expect(category1.hashCode, equals(category2.hashCode));
    });

    test('Category predefined list should contain 8 categories', () {
      expect(Category.predefined.length, 8);
    });

    test('Category predefined list should contain expected categories', () {
      final categoryIds = Category.predefined.map((c) => c.id).toList();
      
      expect(categoryIds, contains('health'));
      expect(categoryIds, contains('mindfulness'));
      expect(categoryIds, contains('productivity'));
      expect(categoryIds, contains('learning'));
      expect(categoryIds, contains('creativity'));
      expect(categoryIds, contains('social'));
      expect(categoryIds, contains('finance'));
      expect(categoryIds, contains('home'));
    });

    test('All predefined categories should have isCustom as false', () {
      for (final category in Category.predefined) {
        expect(category.isCustom, false);
      }
    });

    test('Category toJson should include all fields', () {
      final category = Category(
        id: 'test',
        name: 'Test Category',
        icon: '📝',
        isCustom: true,
      );

      final json = category.toJson();

      expect(json.containsKey('id'), true);
      expect(json.containsKey('name'), true);
      expect(json.containsKey('icon'), true);
      expect(json.containsKey('isCustom'), true);
    });

    test('Category copyWith with null values should preserve original values',
        () {
      final category = Category(
        id: 'test',
        name: 'Test Category',
        icon: '📝',
        isCustom: true,
      );

      final updatedCategory = category.copyWith();

      expect(updatedCategory.id, category.id);
      expect(updatedCategory.name, category.name);
      expect(updatedCategory.icon, category.icon);
      expect(updatedCategory.isCustom, category.isCustom);
    });
  });
}
