import 'package:get/get.dart'; 
import '../data/models/category_model.dart'; 
import '../data/services/category_service.dart'; 
import '../data/services/product_service.dart';
 
class CategoryController extends GetxController { 
  final CategoryService _service = CategoryService(); 
 
  var categories = <CategoryModel>[].obs; 
  var isLoading = false.obs; 
 
  @override 
  void onInit() { 
    _syncDataAndFetch(); 
    super.onInit(); 
  } 
 
  Future<void> _syncDataAndFetch() async {
    try {
      // TỰ ĐỘNG ĐỒNG BỘ DỮ LIỆU DOMINOS NGAY KHI MỞ APP
      final productService = ProductService();
      // await productService.uploadSampleData();
      
      // SAU ĐÓ MỚI LẤY DỮ LIỆU VỀ HIỂN THỊ
      await fetchCategories();
    } catch (e) {
      print("Error syncing data: $e");
      fetchCategories();
    }
  }
 
  Future<void> fetchCategories() async { 
    try { 
      isLoading.value = true; 
      final result = await _service.getAllCategories(); 
      
      // 1. LỌC: Chỉ lấy những ID chuẩn của Dominos để tránh bị dư cái "Bò" cũ
      final validIds = ['all', 'seafood', 'beef', 'chicken', 'pork', 'veggie'];
      var filtered = result.where((c) => validIds.contains(c.id)).toList();

      // 2. SẮP XẾP: Ép app tự sắp xếp theo priority ngay tại đây
      filtered.sort((a, b) => a.priority.compareTo(b.priority));

      categories.assignAll(filtered); 
    } catch (e) { 
      print("Error fetching categories: $e"); 
    } finally { 
      isLoading.value = false; 
    } 
  } 
}