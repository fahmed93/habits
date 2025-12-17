import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/category.dart';
import 'package:habits/services/category_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CategoryStorage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadCustomCategories should return empty list when no data exists',
        () async {
      final storage = CategoryStorage();
      final categories = await storage.loadCustomCategories();
      expect(categories, isEmpty);
    });

    test('addCategory should save and retrieve a custom category', () async {
      final storage = CategoryStorage();
      final category = Category(
        id: 'custom1',
        name: 'Custom Category',
        icon: '🎯',
        isCustom: true,
      );

      await storage.addCategory(category);
      final categories = await storage.loadCustomCategories();

      expect(categories.length, 1);
      expect(categories[0].id, 'custom1');
      expect(categories[0].name, 'Custom Category');
      expect(categories[0].icon, '🎯');
      expect(categories[0].isCustom, true);
    });

    test('updateCategory should update an existing category', () async {
      final storage = CategoryStorage();
      final category = Category(
        id: 'custom1',
        name: 'Original Name',
        icon: '🎯',
        isCustom: true,
      );

      await storage.addCategory(category);
      
      final updatedCategory = category.copyWith(name: 'Updated Name');
      await storage.updateCategory(updatedCategory);
      
      final categories = await storage.loadCustomCategories();
      expect(categories.length, 1);
      expect(categories[0].name, 'Updated Name');
    });

    test('deleteCategory should remove a category', () async {
      final storage = CategoryStorage();
      final category1 = Category(
        id: 'custom1',
        name: 'Category 1',
        icon: '🎯',
        isCustom: true,
      );
      final category2 = Category(
        id: 'custom2',
        name: 'Category 2',
        icon: '📝',
        isCustom: true,
      );

      await storage.addCategory(category1);
      await storage.addCategory(category2);
      await storage.deleteCategory('custom1');

      final categories = await storage.loadCustomCategories();
      expect(categories.length, 1);
      expect(categories[0].id, 'custom2');
    });

    test('loadAllCategories should return predefined and custom categories',
        () async {
      final storage = CategoryStorage();
      final customCategory = Category(
        id: 'custom1',
        name: 'Custom Category',
        icon: '🎯',
        isCustom: true,
      );

      await storage.addCategory(customCategory);
      final allCategories = await storage.loadAllCategories();

      expect(allCategories.length, Category.predefined.length + 1);
      
      // Check that predefined categories are included
      final healthCategory = allCategories.firstWhere((c) => c.id == 'health');
      expect(healthCategory.name, 'Health & Fitness');
      
      // Check that custom category is included
      final custom = allCategories.firstWhere((c) => c.id == 'custom1');
      expect(custom.name, 'Custom Category');
    });

    test('user-scoped storage should isolate categories per user', () async {
      final storage1 = CategoryStorage(userId: 'user1');
      final storage2 = CategoryStorage(userId: 'user2');

      final category1 = Category(
        id: 'custom1',
        name: 'User 1 Category',
        icon: '🎯',
        isCustom: true,
      );
      final category2 = Category(
        id: 'custom2',
        name: 'User 2 Category',
        icon: '📝',
        isCustom: true,
      );

      await storage1.addCategory(category1);
      await storage2.addCategory(category2);

      final user1Categories = await storage1.loadCustomCategories();
      final user2Categories = await storage2.loadCustomCategories();

      expect(user1Categories.length, 1);
      expect(user2Categories.length, 1);
      expect(user1Categories[0].name, 'User 1 Category');
      expect(user2Categories[0].name, 'User 2 Category');
    });

    test('loadCustomCategories should handle corrupted data gracefully',
        () async {
      SharedPreferences.setMockInitialValues({
        'categories': 'invalid json',
      });

      final storage = CategoryStorage();
      final categories = await storage.loadCustomCategories();
      expect(categories, isEmpty);
    });

    test('saveCategories should persist multiple categories', () async {
      final storage = CategoryStorage();
      final categories = [
        Category(
          id: 'custom1',
          name: 'Category 1',
          icon: '🎯',
          isCustom: true,
        ),
        Category(
          id: 'custom2',
          name: 'Category 2',
          icon: '📝',
          isCustom: true,
        ),
      ];

      await storage.saveCategories(categories);
      final loadedCategories = await storage.loadCustomCategories();

      expect(loadedCategories.length, 2);
      expect(loadedCategories[0].id, 'custom1');
      expect(loadedCategories[1].id, 'custom2');
    });
  });
}
