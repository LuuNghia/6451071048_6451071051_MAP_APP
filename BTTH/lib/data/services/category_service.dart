import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../local/pizza_categories.dart';
import '../models/category_model.dart'; 
 
class CategoryService { 
  final FirebaseFirestore _db = FirebaseFirestore.instance; 
 
  Future<List<CategoryModel>> getAllCategories() async { 
    try {
      final snapshot = await _db
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('priority')
          .limit(10)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => CategoryModel.fromSnapshot(doc))
            .toList();
      }
    } catch (_) {
      // Fall back to local pizza categories when Firestore is unavailable.
    }

    return PizzaCategories.defaults();
  } 
}