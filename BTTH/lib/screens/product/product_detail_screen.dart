import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:btl/controller/cart_controller.dart'; 
import 'package:btl/controller/login_controller.dart'; 
import 'package:btl/data/models/cart_item_model.dart'; 
import 'package:btl/screens/review/write_review_screen.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import '../../controller/product_controller.dart'; 
import '../review/review_rating_screen.dart'; 
import '../../controller/order_controller.dart'; 
import '../../controller/wishlist_controller.dart'; 
import '../../utils/price_formatter.dart';
 
class ProductDetailScreen extends StatefulWidget { 
  final String productId;
  const ProductDetailScreen({super.key, required this.productId}); 
 
  @override 
  State<ProductDetailScreen> createState() => 
_ProductDetailScreenState(); 
} 
 
class _ProductDetailScreenState extends State<ProductDetailScreen> { 
  final ProductController controller = Get.find<ProductController>(); 
  final cartController = Get.find<CartController>(); 
  final OrderController orderController = Get.put(OrderController()); 
 
  int selectedImageIndex = 0; 
  int quantity = 1; 
  String? selectedImage; 
 
  Map<String, int> selectedAttributes = {}; 
 
  ImageProvider _imageProvider(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    }
    return NetworkImage(imageUrl);
  }
 
  @override 
  void initState() { 
    super.initState(); 
    WidgetsBinding.instance.addPostFrameCallback((_) async { 
      await controller.fetchProductDetail(widget.productId); 
      final product = controller.selectedProduct.value; 
      if (product != null) { 
        setState(() { 
          selectedImage = product.thumbnail; 
        }); 
      } 
    }); 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: Colors.white, 
      body: Obx(() { 
        if (controller.isLoading.value || 
            controller.selectedProduct.value == null) { 
          return const Center(child: CircularProgressIndicator()); 
        } 
 
        final product = controller.selectedProduct.value!; 
        final bool isOutOfStock = 
            product.isOutOfStock == true || 
            product.stock <= 0 || 
            product.soldQuantity >= product.stock; 
 
        return Stack(
           children: [ 
            /// 1. NỘI DUNG CHI TIẾT (CUỘN) 
            RefreshIndicator(
              onRefresh: () => controller.refreshAllData(),
              child: CustomScrollView( 
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ), 
                slivers: [ 
                  /// App Bar với hình ảnh sản phẩm 
                  SliverAppBar( 
                    expandedHeight: 400, 
                    pinned: true, 
                    stretch: true, 
                    backgroundColor: Colors.white, 
                    leading: Padding( 
                      padding: const EdgeInsets.all(8.0), 
                      child: CircleAvatar( 
                        backgroundColor: Colors.white.withOpacity(0.9), 
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.arrow_back, color: Colors.blue.shade800),
                          tooltip: '', 
                        ), 
                      ), 
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: Obx(() {
                            final wishlistController = Get.find<WishlistController>();
                            final isFav = wishlistController.isInWishlist(widget.productId);
                            return IconButton(
                              onPressed: () async {
                                final authController = Get.find<AuthController>();
                                if (authController.currentUser == null) {
                                  _showLoginDialog();
                                  return;
                                }
                                await wishlistController.toggleWishlist(controller.selectedProduct.value!);
                              },
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.grey,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar( 
                      background: Stack( 
                        children: [ 
                          Positioned.fill( 
                            child: Image(
                              image: _imageProvider(
                                selectedImage ?? product.thumbnail,
                              ),
                              fit: BoxFit.cover,
                            ), 
                          ), 
                          if (isOutOfStock) 
                            Container( 
                              color: Colors.black.withOpacity(0.4), 
                              child: const Center( 
                                child: Text( 
                                  "TẠM HẾT HÀNG", 
                                  style: TextStyle( 
                                    color: Colors.white, 
                                    fontSize: 24, 
                                    fontWeight: FontWeight.bold, 
                                  ), 
                                ), 
                              ), 
                            ), 
                        ], 
                      ), 
                    ), 
                  ), 
  
                  SliverToBoxAdapter( 
                    child: Padding( 
                      padding: const EdgeInsets.all(20), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [ 
                          /// THUMBNAILS LIST 
                          _buildThumbnails(product), 
  
                          const SizedBox(height: 24), 
  
                          /// BRAND & RATING ROW 
                          Row( 
                            mainAxisAlignment: 
  MainAxisAlignment.spaceBetween, 
                            children: [ 
                              Row( 
                                children: [ 
                                  Container( 
                                    padding: const EdgeInsets.all(8), 
                                    decoration: BoxDecoration( 
                                      color: Colors.blue.shade50, 
                                      shape: BoxShape.circle, 
                                    ), 
                                    child: Icon( 
                                      Icons.store, 
                                      color: Colors.blue.shade700, 
                                      size: 20, 
                                    ), 
                                  ), 
                                  const SizedBox(width: 8), 
                                  Text( 
                                    product.brandName ?? '', 
                                    style: const TextStyle( 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16, 
                                    ), 
                                  ), 
                                  const SizedBox(width: 4), 
                                  const Icon( 
                                    Icons.verified, 
                                    color: Colors.blue, 
                                    size: 16, 
                                  ), 
                                ], 
                              ), 
                              _buildRatingBadge(product), 
                            ], 
                          ), 
  
                          const SizedBox(height: 16), 
  
                          /// TITLE & PRICE 
                          Text( 
                            product.title, 
                            style: const TextStyle( 
                              fontSize: 22, 
                              fontWeight: FontWeight.bold, 
                            ), 
                          ), 
                          const SizedBox(height: 8), 
                          Text( 
                            PriceFormatter.format(_calculateCurrentPrice(product)), 
                            style: TextStyle( 
                              fontSize: 28, 
                              fontWeight: FontWeight.w900, 
                              color: Colors.blue.shade800, 
                            ), 
                          ), 
  
                          const SizedBox(height: 12), 
  
                          /// STOCK STATUS 
                          _buildStockStatus(isOutOfStock), 
  
                          const Divider(height: 40), 
  
                          /// REVIEW ACTIONS (Đồng bộ nút bấm hiện đại) 
                          _buildReviewActionSection(product), 
  
                          const SizedBox(height: 10), 
  
                          /// ATTRIBUTES SELECTOR 
                          ...product.attributes.map( 
                            (attribute) => 
  _buildAttributeSection(attribute), 
                          ), 
  
                          /// DESCRIPTION 
                          const Text( 
                            'Mô tả sản phẩm', 
                            style: TextStyle( 
                              fontWeight: FontWeight.bold, 
                              fontSize: 18, 
                            ), 
                          ), 
                          const SizedBox(height: 12), 
                          Text( 
                            product.description ?? 
                                'Không có mô tả cho sản phẩm này.', 
                            style: TextStyle( 
                              color: Colors.grey.shade700, 
                              height: 1.5, 
                              fontSize: 15,
                               ), 
                          ), 
  
                          const SizedBox( 
                            height: 120, 
                          ), // Khoảng trống cho Bottom Bar 
                        ], 
                      ), 
                    ), 
                  ), 
                ], 
              ), 
            ),
  
            /// 2. BOTTOM ACTION BAR (Cố định phía dưới) 
            if (!isOutOfStock) _buildBottomAction(product), 
          ], 
        ); 
      }), 
    ); 
  } 
 
  double _calculateCurrentPrice(dynamic product) {
    double basePrice = product.price;
    for (var attr in product.attributes) {
      if (attr.name.toLowerCase() == 'size') {
        int selectedIdx = selectedAttributes[attr.name] ?? 0;
        if (selectedIdx == 1) { // Size M
          return basePrice * 1.3;
        } else if (selectedIdx == 2) { // Size L
          return basePrice * 1.5;
        }
      }
    }
    return basePrice;
  }
 
  /// UI Components con để code sạch hơn 
 
  Widget _buildThumbnails(dynamic product) { 
    return SizedBox( 
      height: 70, 
      child: ListView( 
        scrollDirection: Axis.horizontal, 
        physics: const BouncingScrollPhysics(), 
        children: [product.thumbnail, ...product.images].toSet().map((imageUrl) 
{ 
          final isSelected = selectedImage == imageUrl; 
          return GestureDetector( 
            onTap: () => setState(() => selectedImage = imageUrl), 
            child: Container( 
              margin: const EdgeInsets.only(right: 12), 
              width: 70, 
              decoration: BoxDecoration( 
                borderRadius: BorderRadius.circular(12), 
                border: Border.all( 
                  color: isSelected ? Colors.blue : 
Colors.grey.shade200, 
                  width: 2, 
                ), 
                image: DecorationImage( 
                  image: _imageProvider(imageUrl), 
                  fit: BoxFit.cover, 
                ), 
              ), 
            ),
             ); 
        }).toList(), 
      ), 
    ); 
  } 
 
  Widget _buildRatingBadge(dynamic product) { 
    return GestureDetector( 
      onTap: () => Get.to( 
        () => ReviewRatingScreen( 
          productId: product.id, 
          rating: product.rating, 
          reviewCount: product.ratingCount, 
        ), 
        transition: Transition.rightToLeftWithFade,
      ), 
      child: Container( 
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
        decoration: BoxDecoration( 
          gradient: LinearGradient(
            colors: [Colors.amber.shade50, Colors.orange.shade50],
          ),
          borderRadius: BorderRadius.circular(25), 
          border: Border.all(color: Colors.amber.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ), 
        child: Row( 
          mainAxisSize: MainAxisSize.min,
          children: [ 
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20), 
            const SizedBox(width: 6), 
            Text( 
              product.rating.toStringAsFixed(1), 
              style: const TextStyle( 
                fontWeight: FontWeight.w800, 
                color: Color(0xFFD35400), 
                fontSize: 15,
              ), 
            ), 
            const SizedBox(width: 4),
            Text( 
              "(${product.ratingCount})", 
              style: TextStyle(
                color: Colors.orange.shade300, 
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
 
  Widget _buildStockStatus(bool isOutOfStock) { 
    return Container( 
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
      decoration: BoxDecoration( 
        color: isOutOfStock ? Colors.red.shade50 : Colors.green.shade50, 
        borderRadius: BorderRadius.circular(8),
         ), 
      child: Text( 
        isOutOfStock ? "Tạm hết hàng" : "Đang còn hàng", 
        style: TextStyle( 
          color: isOutOfStock ? Colors.red : Colors.green, 
          fontWeight: FontWeight.w600, 
          fontSize: 12, 
        ), 
      ), 
    ); 
  } 
 
  Widget _buildAttributeSection(dynamic attribute) { 
    final name = attribute.name; 
    final values = attribute.values; 
    selectedAttributes.putIfAbsent(name, () => 0); 
 
    return Column( 
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [ 
        Text( 
          name.toUpperCase(), 
          style: const TextStyle( 
            fontWeight: FontWeight.bold, 
            letterSpacing: 1, 
            fontSize: 13, 
          ), 
        ), 
        const SizedBox(height: 12), 
        Wrap( 
          spacing: 12, 
          runSpacing: 12, 
          children: List.generate(values.length, (index) { 
            final isSelected = selectedAttributes[name] == index; 
            return GestureDetector( 
              onTap: () => setState(() => selectedAttributes[name] = 
index), 
              child: AnimatedContainer( 
                duration: const Duration(milliseconds: 200), 
                padding: const EdgeInsets.symmetric( 
                  horizontal: 20, 
                  vertical: 10, 
                ), 
                decoration: BoxDecoration( 
                  color: isSelected ? Colors.blue.shade700 : 
Colors.white, 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all( 
                    color: isSelected 
                        ? Colors.blue.shade700
                         : Colors.grey.shade300, 
                  ), 
                  boxShadow: isSelected 
                      ? [ 
                          BoxShadow( 
                            color: Colors.blue.withOpacity(0.3), 
                            blurRadius: 8, 
                            offset: const Offset(0, 4), 
                          ), 
                        ] 
                      : [], 
                ), 
                child: Text( 
                  values[index], 
                  style: TextStyle( 
                    color: isSelected ? Colors.white : Colors.black87, 
                    fontWeight: isSelected 
                        ? FontWeight.bold 
                        : FontWeight.normal, 
                  ), 
                ), 
              ), 
            ); 
          }), 
        ), 
        const SizedBox(height: 24), 
      ], 
    ); 
  } 
 
  Widget _buildReviewActionSection(dynamic product) { 
    return FutureBuilder<Map<String, dynamic>>( 
      future: getReviewState(product.id), 
      builder: (context, snapshot) { 
        if (!snapshot.hasData) return const SizedBox(); 
        final data = snapshot.data!; 
        final state = data["state"]; 
 
        if (state == "not_allowed") return const SizedBox.shrink(); 
 
        final bool isEditing = state == "can_edit";

        return Container( 
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () { 
                Get.to( 
                  () => WriteReviewScreen( 
                    product: product, 
                    reviewId: data["reviewId"], 
                  ), 
                  transition: Transition.cupertino,
                ); 
              }, 
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon( 
                        isEditing ? Icons.edit_note_rounded : Icons.rate_review_rounded, 
                        size: 24, 
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? "Cập nhật đánh giá" : "Chia sẻ cảm nhận",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditing 
                                ? "Bạn muốn thay đổi ý kiến về sản phẩm này?" 
                                : "Nhận xét của bạn giúp mọi người mua sắm tốt hơn",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.blue.shade300),
                  ],
                ),
              ),
            ),
          ),
        ); 
      }, 
    ); 
  } 
 
  Widget _buildBottomAction(dynamic product) { 
    return Positioned( 
      bottom: 0, 
      left: 0, 
      right: 0, 
      child: Container( 
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), 
        decoration: BoxDecoration( 
          color: Colors.white, 
          boxShadow: [ 
            BoxShadow( 
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 20, 
              offset: const Offset(0, -5), 
            ), 
          ], 
          borderRadius: const BorderRadius.only( 
            topLeft: Radius.circular(30), 
            topRight: Radius.circular(30), 
          ), 
        ), 
        child: Row( 
          children: [ 
            /// Số lượng 
            Container( 
              decoration: BoxDecoration( 
 color: Colors.grey.shade100, 
                borderRadius: BorderRadius.circular(15), 
              ), 
              child: Row( 
                children: [ 
                  IconButton( 
                    onPressed: () => 
                        setState(() => quantity > 1 ? quantity-- : 
null), 
                    icon: const Icon(Icons.remove), 
                  ), 
                  Text( 
                    quantity.toString(), 
                    style: const TextStyle( 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                    ), 
                  ), 
                  IconButton( 
                    onPressed: () => setState(() => quantity++), 
                    icon: const Icon(Icons.add), 
                  ), 
                ], 
              ),
            ), 
            const SizedBox(width: 16), 
 
            /// Nút Add to Cart 
            Expanded( 
              child: Obx(() { 
                final selectedVariation = <String, String>{}; 
                product.attributes.forEach((attr) { 
                  final index = selectedAttributes[attr.name] ?? 0; 
                  selectedVariation[attr.name] = attr.values[index]; 
                }); 
                final isAdded = cartController.isInCart( 
                  product.id, 
                  selectedVariation, 
                ); 
 
                return ElevatedButton( 
                  onPressed: isAdded 
                      ? null 
                      : () { 
                          final authController = Get.find<AuthController>();
                          if (authController.currentUser == null) {
                            _showLoginDialog();
                            return;
                          }
                          cartController.addToCart( 
                            CartItemModel( 
                              productId: product.id, 
                              quantity: quantity, 
                              image: selectedImage, 
                              price: _calculateCurrentPrice(product),
                                title: product.title, 
                              brandName: product.brandName, 
                              selectedVariation: selectedVariation, 
                            ), 
                          ); 
                        }, 
                  style: ElevatedButton.styleFrom( 
                    backgroundColor: Colors.blue.shade700, 
                    foregroundColor: Colors.white, 
                    disabledBackgroundColor: Colors.grey.shade300, 
                    padding: const EdgeInsets.symmetric(vertical: 18), 
                    shape: RoundedRectangleBorder( 
                      borderRadius: BorderRadius.circular(15), 
                    ), 
                    elevation: 5, 
                    shadowColor: Colors.blue.withOpacity(0.4), 
                  ), 
                  child: Text( 
                    isAdded ? "ĐÃ Ở TRONG GIỎ" : "THÊM VÀO GIỎ HÀNG", 
                    style: const TextStyle( 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1, 
                    ), 
                  ), 
                ); 
              }), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
 
  // Các hàm xử lý dữ liệu Review giữ nguyên logic của bạn 
  Future<Map<String, dynamic>> getReviewState(String productId) async { 
    final orderController = Get.find<OrderController>(); 
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return {"state": "not_allowed"};
    final userId = authController.currentUser!.id; 
    final purchased = await orderController.orderService 
        .hasUserPurchasedProduct(userId: userId, productId: productId); 
    if (!purchased) return {"state": "not_allowed"}; 
    final reviewed = await orderController.hasUserReviewedProduct( 
      userId: userId, 
      productId: productId, 
    ); 
    if (reviewed) { 
      final snapshot = await FirebaseFirestore.instance 
          .collection('reviews') 
          .where('productId', isEqualTo: productId) 
          .where('userId', isEqualTo: userId) 
          .where('isDeleted', isEqualTo: false)
           .limit(1) 
          .get(); 
      return {"state": "can_edit", "reviewId": snapshot.docs.first.id}; 
    } 
    return {"state": "can_write"}; 
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