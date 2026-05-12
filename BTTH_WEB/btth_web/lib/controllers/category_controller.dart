import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService _service = CategoryService();
  List<CategoryModel> categories = [];
  List<CategoryModel> filtered = [];
  bool isLoading = true;

  CategoryController() {
    _service.getCategoriesStream().listen((data) {
      // Loại bỏ danh mục "all" (Tất Cả) khỏi danh sách quản lý
      final filteredData = data.where((c) => c.id != "all").toList();
      categories = filteredData;
      filtered = filteredData;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchCategories() async {
    // Stream-based updates, no manual fetch needed
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      filtered = categories;
    } else {
      filtered = categories
          .where((c) => c.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> add(CategoryModel category) async {
    await _service.addCategory(category);
  }

  Future<void> update(CategoryModel category) async {
    await _service.updateCategory(category);
  }

  Future<void> delete(String id) async {
    await _service.deleteCategory(id);
  }

  int currentPage = 1;
  int rowsPerPage = 5;
  List<CategoryModel> get paginatedData {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    if (start >= filtered.length) return [];
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  int get totalPages => (filtered.length / rowsPerPage).ceil();
  void changePage(int page) {
    currentPage = page;
    notifyListeners();
  }
}
