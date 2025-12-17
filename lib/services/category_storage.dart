import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryStorage {
  static const String _categoriesKey = 'categories';
  final String? userId;

  CategoryStorage({this.userId});

  String get _storageKey => userId != null ? 'categories_$userId' : _categoriesKey;

  // Save custom categories to local storage
  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = categories.map((category) => category.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(categoriesJson));
  }

  // Load custom categories from local storage
  Future<List<Category>> loadCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesString = prefs.getString(_storageKey);
      
      if (categoriesString == null) {
        return [];
      }

      final List<dynamic> categoriesJson = jsonDecode(categoriesString);
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      // Return empty list if data is corrupted
      return [];
    }
  }

  // Get all categories (predefined + custom)
  Future<List<Category>> loadAllCategories() async {
    final customCategories = await loadCustomCategories();
    return [...Category.predefined, ...customCategories];
  }

  // Add a new custom category
  Future<void> addCategory(Category category) async {
    final categories = await loadCustomCategories();
    categories.add(category);
    await saveCategories(categories);
  }

  // Update an existing custom category
  Future<void> updateCategory(Category updatedCategory) async {
    final categories = await loadCustomCategories();
    final index = categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      categories[index] = updatedCategory;
      await saveCategories(categories);
    }
  }

  // Delete a custom category
  Future<void> deleteCategory(String categoryId) async {
    final categories = await loadCustomCategories();
    categories.removeWhere((c) => c.id == categoryId);
    await saveCategories(categories);
  }
}
