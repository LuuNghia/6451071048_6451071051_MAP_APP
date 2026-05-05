import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class PizzaProducts {
  static List<ProductModel> defaults() {
    final now = Timestamp.now();

    return [
      ProductModel(
        id: 'p_seafood_01',
        title: 'Pizza Hải sản sốt Mayonnaise',
        lowerTitle: 'pizza hai san sot mayonnaise',
        description: 'Pizza hải sản với sốt mayonnaise béo thơm.',
        price: 120000,
        thumbnail:
            'assets/images/foods/Hai_San/Sieu_Topping_Xot_Mayonnaise.jpg',
        images: [
          'assets/images/foods/Hai_San/Sieu_Topping_Xot_Mayonnaise.jpg',
          'assets/images/foods/Hai_San/Xot_Doi_Pho_Mai_Cay.jpg',
        ],
        categoryIds: ['seafood'],
        tags: ['hải sản', 'pizza', 'sốt mayonnaise'],
        attributes: [
          ProductAttribute(
            attributeId: 'size',
            name: 'Size',
            values: ['S', 'M', 'L'],
          ),
        ],
        stock: 50,
        productType: ProductType.simple,
        isFeatured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'p_seafood_02',
        title: 'Pizza Hải sản phô mai cay',
        lowerTitle: 'pizza hai san pho mai cay',
        description: 'Phô mai cay kết hợp hải sản tươi ngon.',
        price: 125000,
        thumbnail: 'assets/images/foods/Hai_San/Xot_Doi_Pho_Mai_Cay.jpg',
        images: [
          'assets/images/foods/Hai_San/Xot_Doi_Pho_Mai_Cay.jpg',
          'assets/images/foods/Hai_San/Sieu_Topping_Xot_Mayonnaise.jpg',
        ],
        categoryIds: ['seafood'],
        tags: ['hải sản', 'phô mai', 'cay'],
        attributes: [
          ProductAttribute(
            attributeId: 'size',
            name: 'Size',
            values: ['S', 'M', 'L'],
          ),
        ],
        stock: 40,
        productType: ProductType.simple,
        isFeatured: false,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'p_beef_01',
        title: 'Pizza bò Mỹ sốt phô mai',
        lowerTitle: 'pizza bo my sot pho mai',
        description: 'Bò Mỹ mềm ngọt, sốt phô mai đậm vị.',
        price: 130000,
        thumbnail: 'assets/images/foods/Bo/Bo_My_Xot_Pho_Mai.jpg',
        images: [
          'assets/images/foods/Bo/Bo_My_Xot_Pho_Mai.jpg',
          'assets/images/foods/Bo/bo_tom_nuong_kieu_my.jpg',
        ],
        categoryIds: ['beef'],
        tags: ['bò', 'phô mai', 'pizza'],
        attributes: [
          ProductAttribute(
            attributeId: 'size',
            name: 'Size',
            values: ['S', 'M', 'L'],
          ),
        ],
        stock: 45,
        productType: ProductType.simple,
        isFeatured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'p_beef_02',
        title: 'Pizza bò tôm nướng kiểu Mỹ',
        lowerTitle: 'pizza bo tom nuong kieu my',
        description: 'Bò tôm nướng kiểu Mỹ, hương vị đậm đà.',
        price: 135000,
        thumbnail: 'assets/images/foods/Bo/bo_tom_nuong_kieu_my.jpg',
        images: [
          'assets/images/foods/Bo/bo_tom_nuong_kieu_my.jpg',
          'assets/images/foods/Bo/Bo_My_Xot_Pho_Mai.jpg',
        ],
        categoryIds: ['beef'],
        tags: ['bò', 'tôm', 'pizza'],
        attributes: [
          ProductAttribute(
            attributeId: 'size',
            name: 'Size',
            values: ['S', 'M', 'L'],
          ),
        ],
        stock: 35,
        productType: ProductType.simple,
        isFeatured: false,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'p_chicken_01',
        title: 'Pizza gà phô mai',
        lowerTitle: 'pizza ga pho mai',
        description: 'Gà mềm, phô mai béo, thơm ngon.',
        price: 110000,
        thumbnail: 'assets/images/foods/Ga/Ga_Pho_Mai.png',
        images: [
          'assets/images/foods/Ga/Ga_Pho_Mai.png',
        ],
        categoryIds: ['chicken'],
        tags: ['gà', 'phô mai', 'pizza'],
        attributes: [
          ProductAttribute(
            attributeId: 'size',
            name: 'Size',
            values: ['S', 'M', 'L'],
          ),
        ],
        stock: 60,
        productType: ProductType.simple,
        isFeatured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'p_pork_01',
        title: 'Pizza heo xúc xích',
        lowerTitle: 'pizza heo xuc xich',
        description: 'Xúc xích đậm vị, đầy đủ topping.',
        price: 115000,
        thumbnail: 'assets/images/foods/Heo/Sieu_Topping_Xuc_Xich.jpg',
        images: [
          'assets/images/foods/Heo/Sieu_Topping_Xuc_Xich.jpg',
          'assets/images/foods/Heo/Sieu_Topping_Dam_Bong.jpg',
        ],
        categoryIds: ['pork'],
        tags: ['heo', 'xúc xích', 'pizza'],
        attributes: [
          ProductAttribute(
            attributeId: 'size',
            name: 'Size',
            values: ['S', 'M', 'L'],
          ),
        ],
        stock: 55,
        productType: ProductType.simple,
        isFeatured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'p_pork_02',
        title: 'Pizza heo dăm bông',
        lowerTitle: 'pizza heo dam bong',
        description: 'Dăm bông mềm, vị ngọt nhẹ.',
        price: 118000,
        thumbnail: 'assets/images/foods/Heo/Sieu_Topping_Dam_Bong.jpg',
        images: [
          'assets/images/foods/Heo/Sieu_Topping_Dam_Bong.jpg',
          'assets/images/foods/Heo/Sieu_Topping_Xuc_Xich.jpg',
        ],
        categoryIds: ['pork'],
        tags: ['heo', 'dăm bông', 'pizza'],
        attributes: [
          ProductAttribute(
            attributeId: 'size',
            name: 'Size',
            values: ['S', 'M', 'L'],
          ),
        ],
        stock: 48,
        productType: ProductType.simple,
        isFeatured: false,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'p_veggie_01',
        title: 'Pizza phô mai truyền thống',
        lowerTitle: 'pizza pho mai truyen thong',
        description: 'Phô mai truyền thống, đơn giản dễ ăn.',
        price: 105000,
        thumbnail: 'assets/images/foods/Rau_Cu/Pho_Mai_Truyen_Thong.jpg',
        images: [
          'assets/images/foods/Rau_Cu/Pho_Mai_Truyen_Thong.jpg',
        ],
        categoryIds: ['veggie'],
        tags: ['ăn chay', 'phô mai', 'pizza'],
        attributes: [
          ProductAttribute(
            attributeId: 'size',
            name: 'Size',
            values: ['S', 'M', 'L'],
          ),
        ],
        stock: 70,
        productType: ProductType.simple,
        isFeatured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'p_veggie_02',
        title: 'Pizza rau củ thập cẩm',
        lowerTitle: 'pizza rau cu thap cam',
        description: 'Rau củ thập cẩm, tự nhiên và tươi ngon.',
        price: 108000,
        thumbnail: 'assets/images/foods/Rau_Cu/Rau_Cu_Thap_Cam.jpg',
        images: [
          'assets/images/foods/Rau_Cu/Rau_Cu_Thap_Cam.jpg',
          'assets/images/foods/Rau_Cu/Pho_Mai_Truyen_Thong.jpg',
        ],
        categoryIds: ['veggie'],
        tags: ['ăn chay', 'rau củ', 'pizza'],
        attributes: [
          ProductAttribute(
            attributeId: 'size',
            name: 'Size',
            values: ['S', 'M', 'L'],
          ),
        ],
        stock: 65,
        productType: ProductType.simple,
        isFeatured: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
