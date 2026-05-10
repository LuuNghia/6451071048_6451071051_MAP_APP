import 'package:btl/controller/cart_controller.dart'; 
import 'package:btl/controller/login_controller.dart'; 
import 'package:btl/controller/wishlist_controller.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart'; 
import '../../screens/product/product_detail_screen.dart'; 
import '../../utils/price_formatter.dart';
 
class ProductCard extends StatefulWidget { 
  final ProductModel product; 
 
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String selectedSize = "S";

  @override
  void initState() {
    super.initState();
    // Khởi tạo size mặc định từ attribute đầu tiên nếu có
    final sizes = _getAvailableSizes();
    if (sizes.isNotEmpty) {
      selectedSize = sizes.first;
    }
  }

  List<String> _getAvailableSizes() {
    for (final attribute in widget.product.attributes) {
      if (attribute.name.toLowerCase() == 'size') {
        return attribute.values;
      }
    }
    return [];
  }

  double _calculateCurrentPrice() {
    double basePrice = widget.product.price;
    if (selectedSize == "M") return basePrice * 1.3;
    if (selectedSize == "L") return basePrice * 1.5;
    return basePrice;
  }

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

    for (final categoryId in widget.product.categoryIds) {
      if (fallbackMap.containsKey(categoryId)) {
        return fallbackMap[categoryId]!;
      }
    }

    return fallbackMap['all']!;
  }

  String _resolveThumbnail() {
    final value = widget.product.thumbnail.trim();
    if (value.isEmpty || value.contains('/foods/icon/')) {
      return _fallbackProductImage();
    }
    return value;
  }

  @override 
  Widget build(BuildContext context) { 
    final cartController = Get.find<CartController>(); 
    final wishlistController = Get.find<WishlistController>(); 
 
    /// ================= LOGIC TÍNH TOÁN ================= 
    final bool isOutOfStock = 
        widget.product.isOutOfStock == true || 
        widget.product.stock <= 0 || 
        widget.product.soldQuantity >= widget.product.stock; 
 
    final bool hasDiscount = 
        widget.product.salePrice != null && widget.product.salePrice! > 0; 
    final double discountPercent = hasDiscount ? widget.product.salePrice! : 0; 
    
    final double currentPrice = _calculateCurrentPrice();
    final double originalPrice = hasDiscount 
        ? currentPrice / (1 - discountPercent / 100) 
        : currentPrice; 
 
    final availableSizes = _getAvailableSizes();

    return InkWell( 
      borderRadius: BorderRadius.circular(16), 
      onTap: () { 
        Get.to(() => ProductDetailScreen(productId: widget.product.id)); 
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
            /// ================= PHẦN HÌNH ẢNH ================= 
            Stack( 
              children: [ 
                ClipRRect( 
                  borderRadius: const BorderRadius.vertical( 
                    top: Radius.circular(16), 
                  ), 
                  child: AspectRatio( 
                    aspectRatio: 1.1, 
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
 
                /// NÚT YÊU THÍCH 
                Positioned( 
                  top: 4, 
                  right: 4, 
                  child: Obx(() { 
                    final isFav = 
                        wishlistController.isInWishlist(widget.product.id); 
                    return IconButton( 
                      constraints: const BoxConstraints(), 
                      padding: const EdgeInsets.all(4), 
                      icon: Icon( 
                        isFav ? Icons.favorite : Icons.favorite_border, 
                        size: 20, 
                        color: isFav ? Colors.red : Colors.grey[400], 
                      ), 
                      onPressed: () async { 
                        final authController = Get.find<AuthController>(); 
                        if (authController.currentUser == null) { 
                          _showLoginDialog(); 
                          return; 
                        } 
                        await wishlistController.toggleWishlist(widget.product); 
                      }, 
                    ); 
                  }), 
                ), 
              ], 
            ), 
 
            /// ================= PHẦN NỘI DUNG ================= 
            Expanded( 
              child: Padding( 
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [ 
                    Text( 
                      widget.product.title, 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: const TextStyle( 
                        fontWeight: FontWeight.w500, 
                        fontSize: 12, 
                        height: 1.2, 
                      ), 
                    ), 
                    const SizedBox(height: 6),
                    
                    /// SIZE SELECTION BUTTONS
                    if (availableSizes.isNotEmpty)
                      Row(
                        children: availableSizes.map((size) {
                          final isSelected = selectedSize == size;
                          return GestureDetector(
                            onTap: () => setState(() => selectedSize = size),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
 
                    const Spacer(), 
                    
                    /// Giá sản phẩm 
                    Wrap( 
                      crossAxisAlignment: WrapCrossAlignment.center, 
                      children: [ 
                        Text( 
                          PriceFormatter.format(currentPrice), 
                          style: const TextStyle( 
                            color: Colors.redAccent, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 14, 
                          ), 
                        ), 
                        if (hasDiscount) ...[ 
                          const SizedBox(width: 4), 
                          Text( 
                            PriceFormatter.format(originalPrice), 
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
                            const Icon(Icons.star, size: 12, color: Colors.orange), 
                            const SizedBox(width: 2), 
                            Text( 
                              widget.product.rating.toStringAsFixed(1), 
                              style: TextStyle( 
                                fontSize: 10, 
                                color: Colors.grey[600], 
                              ), 
                            ), 
                          ], 
                        ), 
 
                        /// Nút cộng để thêm vào giỏ hàng
                        Obx(() {
                          // Lấy đầy đủ các thuộc tính (Size đã chọn + các thuộc tính khác mặc định)
                          final variation = <String, String>{};
                          for (var attr in widget.product.attributes) {
                            if (attr.name.toLowerCase() == 'size') {
                              variation[attr.name] = selectedSize;
                            } else if (attr.values.isNotEmpty) {
                              variation[attr.name] = attr.values.first;
                            }
                          }
                          
                          final isAdded = cartController.isInCart(
                            widget.product.id,
                            variation,
                          );
 
                          return IconButton(
                                onPressed: isOutOfStock
                                ? null
                                : () {
                                    final authController = Get.find<AuthController>();
                                    if (authController.currentUser == null) {
                                      _showLoginDialog();
                                      return;
                                    }
                                    cartController.addToCart(
                                      CartItemModel(
                                        productId: widget.product.id,
                                        quantity: 1,
                                        image: _resolveThumbnail(),
                                        price: currentPrice,
                                        title: widget.product.title,
                                        brandName: widget.product.brandName,
                                        selectedVariation: variation,
                                      ),
                                    );
                                  },
                            icon: Icon(
                              Icons.add_circle,
                              size: 24,
                              color: isAdded ? Colors.green : Colors.blue.shade600,
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