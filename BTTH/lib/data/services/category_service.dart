import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/category_model.dart'; 
 
class CategoryService { 
  final FirebaseFirestore _db = FirebaseFirestore.instance; 
 
  Future<List<CategoryModel>> getAllCategories() async { 
    try {
      print("=== DEBUG: ĐANG LẤY DANH MỤC TỪ FIREBASE... ===");
      final snapshot = await _db
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .get();
 
      print("=== DEBUG: TÌM THẤY ${snapshot.docs.length} DANH MỤC ===");
      for (var doc in snapshot.docs) {
        print("  - Category: ${doc.data()['name']} (ID: ${doc.id})");
      }
 
      return snapshot.docs
          .map((doc) => CategoryModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print("Error loading categories from Firestore: $e");
      return [];
    }
  } 
}