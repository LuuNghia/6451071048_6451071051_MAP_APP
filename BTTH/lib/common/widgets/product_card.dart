import 'package:btl/controller/cart_controller.dart'; 
import 'package:btl/controller/login_controller.dart'; 
import 'package:btl/controller/wishlist_controller.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart'; 
import '../../screens/product/product_detail_screen.dart'; 
 
class ProductCard extends StatelessWidget { 
  final ProductModel product; 
 
  const ProductCard({super.key, required this.product}); 

  ImageProvider _productImageProvider(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    }
    return NetworkImage(imageUrl);
  }

  String _fallbackProductImage() {
    const fallbackMap = {
      'seafood': 'assets/images/foods/Hai_San/Sieu_Topping_Xot_Mayonnaise.jpg',
      'beef': 'assets/images/foods/Bo/Bo_My_Xot_Pho_Mai.jpg',
      'chicken': 'assets/images/foods/Ga/Ga_Pho_Mai.png',
      'pork': 'assets/images/foods/Heo/Sieu_Topping_Xuc_Xich.jpg',
      'veggie': 'assets/images/foods/Rau_Cu/Rau_Cu_Thap_Cam.jpg',
      'all': 'assets/images/foods/Rau_Cu/Pho_Mai_Truyen_Thong.jpg',
    };

    for (final categoryId in product.categoryIds) {
      if (fallbackMap.containsKey(categoryId)) {
        return fallbackMap[categoryId]!;
      }
    }

    return fallbackMap['all']!;
  }

  String _resolveThumbnail() {
    final value = product.thumbnail.trim();
    if (value.isEmpty || value.contains('/foods/icon/')) {
      return _fallbackProductImage();
    }
    return value;
  }

  String? _getSizeLabel() {
    for (final attribute in product.attributes) {
      final name = attribute.name.toLowerCase();
      if (name.contains('size') || name.contains('kich')) {
        if (attribute.values.isNotEmpty) {
          return attribute.values.first;
        }
      }
    }
    return null;
  }

  Map<String, String>? _defaultVariation() {
    if (product.attributes.isEmpty) return null;

    final variation = <String, String>{};
    for (final attribute in product.attributes) {
      if (attribute.values.isNotEmpty) {
        variation[attribute.name] = attribute.values.first;
      }
    }
    return variation.isEmpty ? null : variation;
  }
 
  @override 
  Widget build(BuildContext context) { 
    final cartController = Get.find<CartController>(); 
    final wishlistController = Get.find<WishlistController>(); 
 
    /// ================= LOGIC TÍNH TOÁN ================= 
    final bool isOutOfStock = 
        product.isOutOfStock == true || 
        product.stock <= 0 || 
        product.soldQuantity >= product.stock; 
 
    final bool hasDiscount = 
        product.salePrice != null && product.salePrice! > 0; 
    final double discountPercent = hasDiscount ? product.salePrice! : 0; 
    final double originalPrice = hasDiscount 
        ? product.price / (1 - discountPercent / 100) 
        : product.price; 
 
    return InkWell( 
      borderRadius: BorderRadius.circular(16), 
      onTap: () { 
        Get.to(() => ProductDetailScreen(productId: product.id)); 
      }, 
      child: Container( 
        decoration: BoxDecoration( 
          borderRadius: BorderRadius.circular(16),
          color: Colors.white, 
          boxShadow: [ 
            BoxShadow( 
              blurRadius: 10, 
              color: Colors.black.withOpacity(0.05), 
              offset: const Offset(0, 5), 
            ), 
          ], 
        ), 
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [ 
            /// ================= PHẦN HÌNH ẢNH (Sử dụng LayoutBuilder để tránh tràn) ================= 
            Stack( 
              children: [ 
                ClipRRect( 
                  borderRadius: const BorderRadius.vertical( 
                    top: Radius.circular(16), 
                  ), 
                  child: AspectRatio( 
                    aspectRatio: 1.1, // Cố định tỉ lệ ảnh để tránh nhảy layout 
                    child: Image(
                      image: _productImageProvider(_resolveThumbnail()),
                      width: double.infinity, 
                      fit: BoxFit.cover, 
                      errorBuilder: (_, __, ___) => Container( 
                        color: Colors.grey[100], 
                        child: const Icon( 
                          Icons.image_not_supported, 
                          color: Colors.grey, 
                        ), 
                      ), 
                    ), 
                  ), 
                ), 
 
                /// OVERLAY HẾT HÀNG 
                if (isOutOfStock) 
                  Positioned.fill( 
                    child: Container( 
                      decoration: BoxDecoration( 
                        color: Colors.black.withOpacity(0.4), 
                        borderRadius: const BorderRadius.vertical( 
                          top: Radius.circular(16), 
                        ), 
                      ), 
                      child: Center( 
                        child: Container(
                          padding: const EdgeInsets.symmetric( 
                            horizontal: 8, 
                            vertical: 4, 
                          ), 
                          decoration: BoxDecoration( 
                            color: Colors.black.withOpacity(0.7), 
                            borderRadius: BorderRadius.circular(4), 
                          ), 
                          child: const Text( 
                            "HẾT HÀNG", 
                            style: TextStyle( 
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 12, 
                            ), 
                          ), 
                        ), 
                      ), 
                    ), 
                  ), 
 
                /// BADGE GIẢM GIÁ 
                if (hasDiscount && !isOutOfStock) 
                  Positioned( 
                    top: 8, 
                    left: 8, 
                    child: Container( 
                      padding: const EdgeInsets.symmetric( 
                        horizontal: 6, 
                        vertical: 2, 
                      ), 
                      decoration: BoxDecoration( 
                        color: Colors.redAccent, 
                        borderRadius: BorderRadius.circular(6), 
                      ), 
                      child: Text( 
                        "-${discountPercent.toStringAsFixed(0)}%", 
                        style: const TextStyle( 
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 10, 
                        ), 
                      ), 
                    ), 
                  ), 
 
                /// NÚT YÊU THÍCH (Đặt trên ảnh để tiết kiệm diện tích bên dưới) 
                Positioned( 
                  top: 4, 
right: 4, 
                  child: Obx(() { 
                    final isFav = 
wishlistController.isInWishlist(product.id); 
                    return IconButton( 
                      constraints: const BoxConstraints(), 
                      padding: const EdgeInsets.all(4), 
                      icon: Icon( 
                        isFav ? Icons.favorite : Icons.favorite_border, 
                        size: 20, 
                        color: isFav ? Colors.red : Colors.grey[400], 
                      ), 
                      onPressed: () async { 
                        final authController = 
Get.find<AuthController>(); 
                        if (authController.currentUser == null) { 
                          _showLoginDialog(); 
                          return; 
                        } 
                        await 
wishlistController.toggleWishlist(product); 
                      }, 
                    ); 
                  }), 
                ), 
              ], 
            ), 
 
            /// ================= PHẦN NỘI DUNG (Sử dụng padding hợp lý) ================= 
            Expanded( 
              child: Padding( 
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [ 
                    /// Tiêu đề sản phẩm
                     /// Tiêu đề sản phẩm 
                    Text( 
                      product.title, 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: const TextStyle( 
                        fontWeight: FontWeight.w500, 
                        fontSize: 12, 
                        height: 1.2, 
                      ), 
                    ), 
                    const SizedBox(height: 4),
                    if (_getSizeLabel() != null)
                      Text(
                        'Size: ${_getSizeLabel()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
 
                    const Spacer(), // Đẩy phần giá và rating xuống đáy 
                    /// Giá sản phẩm 
                    Wrap( 
                      crossAxisAlignment: WrapCrossAlignment.center, 
                      children: [ 
                        Text( 
                          "\$${product.price.toStringAsFixed(0)}", 
                          style: const TextStyle( 
                            color: Colors.redAccent, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 14, 
                          ), 
                        ), 
                        if (hasDiscount) ...[ 
                          const SizedBox(width: 4), 
                          Text( 
                            "\$${originalPrice.toStringAsFixed(0)}", 
                            style: TextStyle( 
                              decoration: TextDecoration.lineThrough, 
                              color: Colors.grey[400], 
                              fontSize: 10, 
                            ), 
                          ), 
                        ], 
                      ], 
                    ), 
 
                    const SizedBox(height: 4), 
 
                    /// Đánh giá và nút thêm giỏ hàng 
                    Row( 
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [ 
                        Row( 
                          children: [ 
                            const Icon( 
                              Icons.star, 
                              size: 12,
                               color: Colors.orange, 
                            ), 
                            const SizedBox(width: 2), 
                            Text( 
                              "${product.rating}", 
                              style: TextStyle( 
                                fontSize: 10, 
                                color: Colors.grey[600], 
                              ), 
                            ), 
                          ], 
                        ), 
 
                        /// Nút cộng để thêm vào giỏ hàng
                        Obx(() {
                          final variation = _defaultVariation();
                          final isAdded = cartController.isInCart(
                            product.id,
                            variation,
                          );

                          return IconButton(
                            onPressed: isOutOfStock
                                ? null
                                : () {
                                    final authController =
                                        Get.find<AuthController>();
                                    if (authController.currentUser == null) {
                                      _showLoginDialog();
                                      return;
                                    }
                                    cartController.addToCart(
                                      CartItemModel(
                                        productId: product.id,
                                        quantity: 1,
                                        image: _resolveThumbnail(),
                                        price: product.price,
                                        title: product.title,
                                        brandName: product.brandName,
                                        selectedVariation: variation,
                                      ),
                                    );
                                  },
                            icon: Icon(
                              Icons.add_circle,
                              size: 18,
                              color: isAdded
                                  ? Colors.green
                                  : Colors.blue.shade600,
                            ),
                            tooltip: 'Thêm vào giỏ hàng',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          );
                        }), 
                      ], 
                    ), 
                  ], 
                ), 
              ), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
 
  void _showLoginDialog() { 
    Get.defaultDialog( 
      title: "Yêu cầu đăng nhập", 
      middleText: "Vui lòng đăng nhập để thực hiện chức năng này", 
      textConfirm: "Đăng nhập", 
      textCancel: "Hủy", 
      confirmTextColor: Colors.white, 
      buttonColor: Colors.blue, 
      onConfirm: () { 
        Get.back(); 
        Get.toNamed('/login');
         }, 
    ); 
  } 
} 