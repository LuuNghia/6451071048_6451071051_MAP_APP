import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ProductModel>> getPopularProducts() async {
    List<ProductModel> products = [];
    try {
      final snapshot = await _db.collection('products')
          .where('isFeatured', isEqualTo: true)
          .limit(20)
          .get();

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
    } catch (e) {
      print("Error loading products: $e");
    }

    return products;
  }

  Future<List<ProductModel>> getAllPopularProducts() async {
    List<ProductModel> products = [];
    try {
      final snapshot = await _db.collection('products')
          .where('isFeatured', isEqualTo: true)
          .get();

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
    } catch (e) {
      print("Error loading products: $e");
    }

    return products;
  }

  Future<List<ProductModel>> getProductsByCategory({
    required String categoryId,
  }) async {
    List<ProductModel> products = [];

    try {
      final snapshot = await _db
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        final p = ProductModel.fromSnapshot(doc, null);
        if (categoryId == 'all' || p.categoryIds.contains(categoryId)) {
          products.add(p);
        }
      }
    } catch (e) {
      print("Error loading products by category: $e");
    }

    return products;
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _db.collection('products').doc(productId).get();

      if (doc.exists) {
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
      }
    } catch (_) { }

    return null;
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
      }
    } catch (_) { }

    return products;
  }

  Future<void> uploadSampleData() async {
    final List<Map<String, dynamic>> categories = [
      {"id": "all", "name": "Tất Cả", "imageURL": "", "isActive": true, "isFeatured": true, "priority": 0, "numberOfProducts": 10, "viewCount": 0, "createdBy": "admin", "updatedBy": "admin"},
      {"id": "seafood", "name": "Hải sản", "imageURL": "https://img.dominos.vn/fried-shrimp_1f364.png", "isActive": true, "isFeatured": true, "priority": 1, "numberOfProducts": 2, "viewCount": 0, "createdBy": "admin", "updatedBy": "admin"},
      {"id": "beef", "name": "Bò", "imageURL": "https://img.dominos.vn/cut-of-meat_1f969.png", "isActive": true, "isFeatured": true, "priority": 2, "numberOfProducts": 2, "viewCount": 0, "createdBy": "admin", "updatedBy": "admin"},
      {"id": "chicken", "name": "Gà", "imageURL": "https://img.dominos.vn/poultry-leg_1f357.png", "isActive": true, "isFeatured": true, "priority": 3, "numberOfProducts": 1, "viewCount": 0, "createdBy": "admin", "updatedBy": "admin"},
      {"id": "pork", "name": "Heo", "imageURL": "https://img.dominos.vn/bacon_1f953.png", "isActive": true, "isFeatured": true, "priority": 4, "numberOfProducts": 2, "viewCount": 0, "createdBy": "admin", "updatedBy": "admin"},
      {"id": "veggie", "name": "Ăn chay", "imageURL": "https://img.dominos.vn/leafy-green_1f96c.png", "isActive": true, "isFeatured": true, "priority": 5, "numberOfProducts": 2, "viewCount": 0, "createdBy": "admin", "updatedBy": "admin"},
    ];

    final List<Map<String, dynamic>> products = [
      {
        "name": "Pizza Hải Sản Cocktail",
        "img": "https://img.dominos.vn/Seafood+cocktail+PC-MB1000X667px+(NEW).jpg",
        "cat": "seafood",
        "basePrice": 165000,
        "desc": "Xốt Mayonnaise, Xốt Phô Mai Cay, Xốt Kem Chanh, Hành Tây, Dứa (Thơm), Ớt Chuông Xanh, Tôm, Thịt Dăm Bông, Phô Mai Mozzarella, Lá Mùi Tây"
      },
      {
        "name": "Pizza Hải Sản Cocktail Mayo",
        "img": "https://img.dominos.vn/Seafood+cocktail+mayo+PC-MB1000X667px+(NEW).jpg",
        "cat": "seafood",
        "basePrice": 165000,
        "desc": "Xốt Mayonnaise, Xốt Kem Chanh, Hành Tây, Dứa (Thơm), Bắp, Tôm, Thịt Dăm Bông, Phô Mai Mozzarella, Lá Mùi Tây"
      },
      {
        "name": "Pizza Siêu Topping Bơ Gơ Bò Mỹ",
        "img": "https://img.dominos.vn/Extra.jpg",
        "cat": "beef",
        "basePrice": 185000,
        "desc": "Tăng 50% lượng topping protein: Thịt Bò Bơ Gơ Nhập Khẩu, Thịt Heo Xông Khói; Thêm Xốt Phô Mai, Xốt Mayonnaise, Phô Mai Mozzarella, Phô Mai Cheddar, Cà Chua, Hành Tây, Nấm"
      },
      {
        "name": "Pizza Siêu Topping Bò Và Tôm",
        "img": "https://img.dominos.vn/Pizza+Extra+Topping+(4).jpg",
        "cat": "beef",
        "basePrice": 205000,
        "desc": "Tăng 50% lượng topping protein: Tôm, Thịt Bò Mexico; Thêm Phô Mai Mozzarella, Cà Chua, Hành, Xốt Cà Chua, Xốt Mayonnaise Xốt Phô Mai"
      },
      {
        "name": "Pizza Gà Phô Mai Thịt Heo Xông Khói",
        "img": "https://img.dominos.vn/thay+nut+new-best-must+(20).jpg",
        "cat": "chicken",
        "basePrice": 155000,
        "desc": "Xốt Phô Mai, Gà Viên, Thịt Heo Xông Khói, Phô Mai Mozzarella, Cà Chua"
      },
      {
        "name": "Pizza Siêu Topping Dăm Bông Dứa",
        "img": "https://img.dominos.vn/Pizza+Extra+Topping+(1).jpg",
        "cat": "pork",
        "basePrice": 145000,
        "desc": "Tăng 50% lượng topping protein: Thịt Dăm Bông; Thêm Phô Mai Mozzarella, Dứa, Xốt Mayonnaise, Xốt Cà Chua"
      },
      {
        "name": "Pizza Siêu Topping Xúc Xích Ý",
        "img": "https://img.dominos.vn/Pizza+Extra+Topping+(5).jpg",
        "cat": "pork",
        "basePrice": 145000,
        "desc": "Tăng 50% lượng topping protein: Xúc Xích Pepperoni; Thêm Phô Mai Mozzarella, Xốt Cà Chua"
      },
      {
        "name": "Pizza Rau Củ Thập Cẩm",
        "img": "https://img.dominos.vn/Veggie-mania-Pizza-Rau-Cu-Thap-Cam.jpg",
        "cat": "veggie",
        "basePrice": 125000,
        "desc": "Xốt Cà Chua, Phô Mai Mozzarella, Hành Tây, Ớt Chuông Xanh, Ô-liu, Nấm Mỡ, Cà Chua, Thơm (dứa)"
      },
      {
        "name": "Pizza Phô Mai Truyền Thống",
        "img": "https://img.dominos.vn/Pizza-Pho-Mai-Hao-Hang-Cheese-Mania.jpg",
        "cat": "veggie",
        "basePrice": 125000,
        "desc": "Xốt Cà Chua, Phô Mai Mozzarella"
      },
    ];

    WriteBatch batch = _db.batch();

    // 1. Xóa sạch dữ liệu sản phẩm cũ để tránh trùng lặp hoặc sót các sản phẩm không gộp
    try {
      final oldProducts = await _db.collection('products').get();
      for (var doc in oldProducts.docs) {
        batch.delete(doc.reference);
      }
      print("=== ĐANG LÀM SẠCH DỮ LIỆU CŨ... ===");
    } catch (e) {
      print("Lỗi khi xóa dữ liệu cũ: $e");
    }

    for (var cat in categories) {
      batch.set(_db.collection('categories').doc(cat['id']), cat, SetOptions(merge: true));
    }

    for (var raw in products) {
      final id = raw['name'].toString().replaceAll(' ', '_').toLowerCase();
      final basePrice = (raw['basePrice'] as int).toDouble();
      
      final productData = {
        "id": id,
        "title": raw['name'],
        "lowerTitle": raw['name'].toString().toLowerCase(),
        "price": basePrice,
        "description": raw['desc'] ?? "Thưởng thức hương vị tuyệt vời của ${raw['name']} với nguyên liệu tươi ngon nhất, chuẩn vị Domino's Pizza.",
        "thumbnail": raw['img'],
        "images": [raw['img']],
        "categoryIds": [raw['cat']],
        "attributes": [
          {
            "name": "Size",
            "values": ["S", "M", "L"]
          },
          {
            "name": "Đế bánh",
            "values": ["Đế dày", "Đế mỏng", "Đế vừa"]
          }
        ],
        "stock": 100,
        "isActive": true,
        "isFeatured": true,
        "productType": "variable",
        "createdAt": Timestamp.now(),
      };
      batch.set(_db.collection('products').doc(id), productData, SetOptions(merge: true));
    }

    try {
      await batch.commit();
      print("=== ĐÃ KHỞI TẠO TOÀN BỘ THỰC ĐƠN LÊN FIREBASE THÀNH CÔNG ===");
    } catch (e) {
      print("=== LỖI KHỞI TẠO: $e ===");
    }
  }

  Future<void> updateAllProductsDescription() async {
    print("=== [DEBUG] BẮT ĐẦU QUÉT VÀ CẬP NHẬT MÔ TẢ TRỰC TIẾP... ===");
    try {
      final snapshot = await _db.collection('products').get();
      
      final Map<String, String> nameToDesc = {
        "Hải Sản Cocktail": "Xốt Mayonnaise, Xốt Phô Mai Cay, Xốt Kem Chanh, Hành Tây, Dứa (Thơm), Ớt Chuông Xanh, Tôm, Thịt Dăm Bông, Phô Mai Mozzarella, Lá Mùi Tây",
        "Cocktail Mayo": "Xốt Mayonnaise, Xốt Kem Chanh, Hành Tây, Dứa (Thơm), Bắp, Tôm, Thịt Dăm Bông, Phô Mai Mozzarella, Lá Mùi Tây",
        "Bơ Gơ Bò Mỹ": "Tăng 50% lượng topping protein: Thịt Bò Bơ Gơ Nhập Khẩu, Thịt Heo Xông Khói; Thêm Xốt Phô Mai, Xốt Mayonnaise, Phô Mai Mozzarella, Phô Mai Cheddar, Cà Chua, Hành Tây, Nấm",
        "Bò Extra": "Tăng 50% lượng topping protein: Thịt Bò Bơ Gơ Nhập Khẩu, Thịt Heo Xông Khói; Thêm Xốt Phô Mai, Xốt Mayonnaise, Phô Mai Mozzarella, Phô Mai Cheddar, Cà Chua, Hành Tây, Nấm",
        "Bò Và Tôm": "Tăng 50% lượng topping protein: Tôm, Thịt Bò Mexico; Thêm Phô Mai Mozzarella, Cà Chua, Hành, Xốt Cà Chua, Xốt Mayonnaise Xốt Phô Mai",
        "Gà Phô Mai": "Xốt Phô Mai, Gà Viên, Thịt Heo Xông Khói, Phô Mai Mozzarella, Cà Chua",
        "Dăm Bông Dứa": "Tăng 50% lượng topping protein: Thịt Dăm Bông; Thêm Phô Mai Mozzarella, Dứa, Xốt Mayonnaise, Xốt Cà Chua",
        "Hawaiian": "Tăng 50% lượng topping protein: Thịt Dăm Bông; Thêm Phô Mai Mozzarella, Dứa, Xốt Mayonnaise, Xốt Cà Chua",
        "Xúc Xích Ý": "Tăng 50% lượng topping protein: Xúc Xích Pepperoni; Thêm Phô Mai Mozzarella, Xốt Cà Chua",
        "Pepperoni": "Tăng 50% lượng topping protein: Xúc Xích Pepperoni; Thêm Phô Mai Mozzarella, Xốt Cà Chua",
        "Rau Củ": "Xốt Cà Chua, Phô Mai Mozzarella, Hành Tây, Ớt Chuông Xanh, Ô-liu, Nấm Mỡ, Cà Chua, Thơm (dứa)",
        "Veggie Mania": "Xốt Cà Chua, Phô Mai Mozzarella, Hành Tây, Ớt Chuông Xanh, Ô-liu, Nấm Mỡ, Cà Chua, Thơm (dứa)",
        "Phô Mai Truyền Thống": "Xốt Cà Chua, Phô Mai Mozzarella",
        "Cheese Mania": "Xốt Cà Chua, Phô Mai Mozzarella",
        "Phô Mai Hảo Hạng": "Xốt Cà Chua, Phô Mai Mozzarella",
      };

      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String title = data['title'] ?? "";
        
        String? newDesc;
        for (var entry in nameToDesc.entries) {
          if (title.contains(entry.key)) {
            newDesc = entry.value;
            break;
          }
        }

        if (newDesc != null) {
          print("--- [SYNC] ĐANG CẬP NHẬT: $title");
          
          // Revert title if it contains the suffix
          String finalTitle = title.replaceAll(" (Đã cập nhật)", "");
          
          await doc.reference.set({
            'description': newDesc,
            'title': finalTitle,
            'stock': 100, // Reset stock to normal
          }, SetOptions(merge: true));
          count++;
        }
      }
      
      print("=== [DEBUG] ĐÃ CẬP NHẬT XONG $count SẢN PHẨM ===");
    } catch (e) {
      print("=== [DEBUG] LỖI CẬP NHẬT MÔ TẢ: $e ===");
    }
  }
}