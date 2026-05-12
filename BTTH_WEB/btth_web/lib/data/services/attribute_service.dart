import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/attribute_model.dart'; 
 
class AttributeService { 
  final _db = FirebaseFirestore.instance; 
  final String collection = "attributes"; 
 
  Future<void> create(AttributeModel model) async { 
    await _db.collection(collection).add(model.toMap()); 
  } 
 
  Future<void> update(AttributeModel model) async { 
    await _db.collection(collection).doc(model.id).update(model.toMap()); 
  } 
 
  Future<void> delete(String id) async { 
    await _db.collection(collection).doc(id).delete(); 
  } 
 
  Stream<List<AttributeModel>> getAll() { 
    return _db 
        .collection(collection) 
        .orderBy('updatedAt', descending: true) 
        .snapshots() 
        .map( 
          (snapshot) => snapshot.docs 
              .map((doc) => AttributeModel.fromMap(doc.data(), doc.id)) 
              .toList(), 
        ); 
  }

  Future<void> syncFromProducts() async {
    final productSnapshot = await _db.collection("products").get();
    final Map<String, Set<String>> extractedAttributes = {};

    for (var doc in productSnapshot.docs) {
      final data = doc.data();
      if (data['attributes'] != null) {
        final List attributesList = data['attributes'];
        for (var attr in attributesList) {
          final String name = attr['name'] ?? '';
          final List values = attr['values'] ?? [];
          if (name.isNotEmpty) {
            extractedAttributes.putIfAbsent(name, () => {});
            for (var v in values) {
              extractedAttributes[name]!.add(v.toString());
            }
          }
        }
      }
    }

    // Lấy danh sách thuộc tính hiện có để tránh trùng lặp
    final existingSnapshot = await _db.collection(collection).get();
    final existingNames = existingSnapshot.docs.map((doc) => doc.data()['name'] as String).toSet();

    for (var entry in extractedAttributes.entries) {
      if (!existingNames.contains(entry.key)) {
        final newAttr = AttributeModel(
          id: "",
          name: entry.key,
          attributeValues: entry.value.toList(),
          isActive: true,
          isSearchable: true,
          isFilterable: true,
          isColorAttribute: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await create(newAttr);
      }
    }
  }
}