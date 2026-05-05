import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../local/pizza_products.dart';
import '../models/product_model.dart'; 
 
class ProductService { 
  final FirebaseFirestore _db = FirebaseFirestore.instance; 
 
  Future<List<ProductModel>> getPopularProducts() async { 
    try {
      final snapshot = await _db
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .limit(6)
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<ProductModel> products = [];

        for (var doc in snapshot.docs) {
          final data = doc.data();
          String? brandName;

          if (data['brandId'] != null) {
            final brandDoc = await _db
                .collection('brands')
                .doc(data['brandId'])
                .get();

            brandName = brandDoc.data()?['name'];
          }

          products.add(ProductModel.fromSnapshot(doc, brandName));
        }

        return products;
      }
    } catch (_) {
      // Fall back to local pizza products when Firestore is unavailable.
    }

    return PizzaProducts.defaults().where((p) => p.isFeatured).take(6).toList();
  } 
 
  Future<List<ProductModel>> getAllPopularProducts({ 
    String sortBy = "name", 
  }) async { 
    List<ProductModel> products = [];

    try {
      // CHỈ FILTER – KHÔNG orderBy ở Firestore 
      final snapshot = await _db 
          .collection('products') 
          .where('isActive', isEqualTo: true) 
          .where('isFeatured', isEqualTo: true) 
          .get(); 

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) { 
          final data = doc.data() as Map<String, dynamic>;
          String? brandName; 

          if (data['brandId'] != null) { 
            final brandDoc = await _db 
                .collection('brands') 
                .doc(data['brandId']) 
                .get(); 
            brandName = brandDoc.data()?['name']; 
          } 

          products.add(ProductModel.fromSnapshot(doc, brandName)); 
        }
      }
    } catch (_) {
      // Fall back to local pizza products when Firestore is unavailable.
    }

    if (products.isEmpty) {
      products = PizzaProducts.defaults().where((p) => p.isFeatured).toList();
    }
 
    // SORT LOCAL – AN TOÀN 100% 
    if (sortBy == "low_price") { 
      products.sort((a, b) => a.price.compareTo(b.price)); 
    } else if (sortBy == "high_price") { 
      products.sort((a, b) => b.price.compareTo(a.price)); 
    } else if (sortBy == "newest") { 
      // nếu có createdAt thì mới sort 
    } else { 
      products.sort( 
        (a, b) => 
a.title.toLowerCase().compareTo(b.title.toLowerCase()), 
      ); 
    } 
 
    return products; 
  } 
 
  Future<List<ProductModel>> getProductsByCategory({ 
    required String categoryId, 
  }) async { 
    List<ProductModel> products = [];

    try {
      Query<Map<String, dynamic>> query = _db
          .collection('products')
          .where('isActive', isEqualTo: true);

      if (categoryId != 'all') {
        query = query.where('categoryIds', arrayContains: categoryId);
      }

      final snapshot = await query.get(); 

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) { 
          final data = doc.data() as Map<String, dynamic>; 
          String? brandName; 

          if (data['brandId'] != null) { 
            final brandDoc = await _db 
                .collection('brands') 
                .doc(data['brandId']) 
                .get();
            brandName = brandDoc.data()?['name']; 
          } 

          products.add(ProductModel.fromSnapshot(doc, brandName)); 
        }
      }
    } catch (_) {
      // Fall back to local pizza products when Firestore is unavailable.
    }

    if (products.isNotEmpty) return products;

    final fallback = PizzaProducts.defaults();
    if (categoryId == 'all') return fallback;
    return fallback.where((p) => p.categoryIds.contains(categoryId)).toList();
  } 
 
  Future<List<ProductModel>> getProductsByBrand({ 
    required String brandId, 
  }) async { 
    List<ProductModel> products = [];

    try {
      final snapshot = await _db 
          .collection('products') 
          .where('isActive', isEqualTo: true) 
          .where('brandId', isEqualTo: brandId) 
          .get(); 

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) { 
          final data = doc.data() as Map<String, dynamic>; 
          String? brandName; 

          if (data['brandId'] != null) { 
            final brandDoc = await _db 
                .collection('brands') 
                .doc(data['brandId']) 
                .get(); 
            brandName = brandDoc.data()?['name']; 
          } 

          products.add(ProductModel.fromSnapshot(doc, brandName)); 
        }
      }
    } catch (_) {
      // Fall back to local pizza products when Firestore is unavailable.
    }

    return products;
  } 
 
  Future<ProductModel?> getProductById(String productId) async { 
    try {
      final doc = await _db.collection('products').doc(productId).get(); 

      if (!doc.exists) return null; 

      final data = doc.data() as Map<String, dynamic>; 
      String? brandName; 

      if (data['brandId'] != null) { 
        final brandDoc = await _db 
            .collection('brands') 
            .doc(data['brandId'])
            .get(); 
        brandName = brandDoc.data()?['name']; 
      } 

      return ProductModel.fromSnapshot(doc, brandName); 
    } catch (_) {
      // Fall back to local pizza products when Firestore is unavailable.
    }

    for (final product in PizzaProducts.defaults()) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  } 
} 