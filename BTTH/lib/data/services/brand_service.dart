import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/brand_model.dart';

class BrandService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<BrandModel>> getAllBrands() async {
    final snapshot = await _db.collection('brands').get();
    return snapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
  }

  Future<List<BrandModel>> getAllFeaturedBrands() async {
    final snapshot = await _db
        .collection('brands')
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .get();

    final brands = snapshot.docs
        .map((doc) => BrandModel.fromSnapshot(doc))
        .toList();

    brands.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return brands;
  }

  Future<BrandModel?> getBrandById(String brandId) async {
    final doc = await _db.collection('brands').doc(brandId).get();

    if (!doc.exists) return null;
    return BrandModel.fromSnapshot(doc);
  }
}
