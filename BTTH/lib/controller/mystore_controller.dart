import 'package:get/get.dart';
import '../data/models/category_model.dart';
import '../data/models/product_model.dart';
import '../data/services/mystore_service.dart';
import '../data/services/product_service.dart';

class MyStoreController extends GetxController {
  final MyStoreService _service = MyStoreService();
  final ProductService _productService = ProductService();
  
  var isLoading = false.obs;
  var categories = <CategoryModel>[].obs;
  var products = <ProductModel>[].obs;
  var selectedCategoryIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    isLoading.value = true;
    categories.value = await _service.getCategories();
    if (categories.isNotEmpty) {
      await selectCategory(0);
    }
    isLoading.value = false;
  }

  Future<void> selectCategory(int index) async {
    selectedCategoryIndex.value = index;
    final categoryId = categories[index].id;
    products.value = await _productService.getProductsByCategory(categoryId: categoryId);
  }
}
