import 'dart:math'; 
import 'package:flutter/material.dart';
 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:btl/controller/cart_controller.dart'; 
import 'package:btl/controller/category_controller.dart';
import 'package:btl/controller/login_controller.dart'; 
import 'package:btl/controller/product_controller.dart';
import 'package:btl/data/models/address_model.dart'; 
import 'package:btl/data/models/cart_item_model.dart'; 
import 'package:btl/data/models/coupon_model.dart'; 
import 'package:btl/data/models/order_model.dart'; 
import 'package:btl/data/services/order_service.dart'; 
import 'package:btl/data/services/product_service.dart'; 
import 'package:btl/screens/order/order_success_screen.dart'; 
import 'package:get/get.dart';
class OrderController extends GetxController { 
  /// ================= CONTROLLER ================= 
  final cart = Get.find<CartController>(); 
  final auth = Get.find<AuthController>(); 
 
  /// ================= STATE ================= 
  RxList<CartItemModel> items = <CartItemModel>[].obs; 
 
  RxDouble subTotal = 0.0.obs; 
  RxDouble tax = 0.0.obs; 
  RxDouble shippingFee = 0.0.obs; 
  RxDouble discountAmount = 0.0.obs; 
 
  Rxn<CouponModel> coupon = Rxn<CouponModel>(); 
 
  Rxn<AddressModel> selectedAddress = Rxn<AddressModel>(); 
 
  RxList<AddressModel> addresses = <AddressModel>[].obs; 
 
  RxString phone = "".obs; 
 
  RxString paymentMethod = "cash".obs; // cash | bank 
 
  /// ================= INIT ================= 
  void loadFromCart() { 
    items.assignAll(cart.cartItems); 
 
    subTotal.value = items.fold(0, (sum, e) => sum + (e.price * e.quantity)); 
 
    _calculateTax(); 
    if (shippingFee.value == 0 && items.isNotEmpty) {
      shippingFee.value = 30000;
    }
  } 
 
  void _calculateTax() { 
    tax.value = subTotal.value * 0.025; 
  } 
 
  /// ================= SHIPPING ================= 
  Future<void> calculateShipping(double distanceKm) async { 
    shippingFee.value = distanceKm * 5000; // 5k/km 
  } 
 
  /// ================= COUPON ================= 
  Future<void> applyCoupon(String code) async { 
    try { 
      final snapshot = await FirebaseFirestore.instance 
          .collection('coupons') 
          .where('code', isEqualTo: code.trim()) 
          .get();
           if (snapshot.docs.isEmpty) { 
        Get.snackbar("Error", "Coupon không tồn tại"); 
        return; 
      } 
 
      final doc = snapshot.docs.first; 
      final data = doc.data(); 
 
      final c = CouponModel.fromJson({ 
        ...data, 
        'id': doc.id, // 🔥 FIX 
      }); 
      final now = DateTime.now(); 
 
      /// ===== VALIDATE ===== 
      if (!c.isActive) { 
        Get.snackbar("Error", "Coupon chưa active"); 
        return; 
      } 
 
      if (c.startDate != null && now.isBefore(c.startDate!)) { 
        Get.snackbar("Error", "Chưa tới ngày sử dụng"); 
        return; 
      } 
 
      if (c.endDate != null && now.isAfter(c.endDate!)) { 
        Get.snackbar("Error", "Coupon đã hết hạn"); 
        return; 
      } 
 
      if (c.usageLimit != -1 && c.usageCount >= c.usageLimit) { 
        Get.snackbar("Error", "Coupon đã hết lượt"); 
        return; 
      } 
 
      /// ===== CALCULATE DISCOUNT ===== 
      double discount = 0; 
 
      if (c.discountType == DiscountType.percentage) { 
        discount = subTotal.value * c.discountValue / 100; 
      } else { 
        discount = c.discountValue; 
      } 
 
      /// 🔥 QUAN TRỌNG: set coupon 
      coupon.value = c; 
      discountAmount.value = discount; 
 
      Get.snackbar("Success", "Áp dụng coupon thành công"); 
    } catch (e) {
        Get.snackbar("Error", "Lỗi coupon: $e"); 
    } 
  } 
 
  /// ================= TOTAL ================= 
  double get total { 
    return subTotal.value + 
        tax.value + 
        shippingFee.value - 
        discountAmount.value; 
  } 
 
  /// ================= ADDRESS ================= 
  Future<void> fetchAddresses() async { 
    phone.value = auth.currentUser?.phone ?? ""; 
 
    final snapshot = await FirebaseFirestore.instance 
        .collection('users') 
        .doc(auth.currentUser!.id) 
        .collection('addresses') 
        .get(); 
 
    addresses.value = snapshot.docs 
        .map((e) => AddressModel.fromMap(e.id, e.data())) 
        .toList(); 
  } 
 
  void selectAddress(AddressModel address) { 
    selectedAddress.value = address; 
  } 
 
  /// ================= CREATE ORDER ================= 
  Future<void> createOrder() async { 
    if (items.isEmpty) {
      Get.snackbar("Error", "Giỏ hàng đang trống");
      return;
    }

    final int shipping = shippingFee.value.toInt(); 
    if (selectedAddress.value == null) { 
      Get.snackbar("Error", "Vui lòng chọn địa chỉ"); 
      return; 
    } 
 
    try { 
      final totalAmount = total; 
 
      final order = OrderModel( 
        docId: '', 
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        userId: auth.currentUser!.id, 
        userDeviceToken: '', 
 
        products: items,
         subTotal: subTotal.value, 
        shippingAmount: shipping, 
 
        taxRate: 0.025, 
        taxAmount: tax.value, 
 
        /// 🔥 FIX COUPON 
        coupon: coupon.value, 
        couponDiscountAmount: discountAmount.value, 
 
        pointsUsed: 0, 
        pointsDiscountAmount: 0, 
        totalDiscountAmount: discountAmount.value, 
 
        totalAmount: totalAmount, 
 
        paymentStatus: "pending", 
        orderStatus: "created", 
        orderDate: DateTime.now(), 
 
        shippingAddress: selectedAddress.value!.toMap(), 
 
        activities: [], 
        itemCount: items.length, 
 
        createdAt: DateTime.now(), 
        updatedAt: DateTime.now(), 
 
        /// 🔥 FIX PAYMENT 
        paymentMethod: paymentMethod.value, 
        paymentMethodType: paymentMethod.value == "bank" 
            ? PaymentMethods.bank 
            : PaymentMethods.cash, 
      ); 
 
      await 
FirebaseFirestore.instance.collection('orders').add(order.toJson()); 
 
      /// 🔥 UPDATE SOLD QUANTITY 
      await updateSoldQuantityAfterOrder(); 
 
      /// 🔥 TĂNG usage coupon 
      await increaseCouponUsage(); 
 
      /// CLEAR CART 
      cart.cartItems.clear(); 
 
      Get.offAll(() => const OrderSuccessScreen()); 
    } catch (e) { 
      Get.snackbar("Error", "Tạo đơn thất bại: $e");
      } 
  } 
 
  /// ================= COUPON USAGE ================= 
  Future<void> increaseCouponUsage() async { 
    if (coupon.value == null) return; 
 
    final snapshot = await FirebaseFirestore.instance 
        .collection('coupons') 
        .where('code', isEqualTo: coupon.value!.code) 
        .get(); 
 
    if (snapshot.docs.isEmpty) return; 
 
    final docId = snapshot.docs.first.id; 
 
    await 
FirebaseFirestore.instance.collection('coupons').doc(docId).update({ 
      'usageCount': FieldValue.increment(1), 
    }); 
  } 
 
  /// ================= DISTANCE ================= 
  double calculateDistanceKm( 
    double lat1, 
    double lon1, 
    double lat2, 
    double lon2, 
  ) { 
    const R = 6371; 
 
    final dLat = _deg2rad(lat2 - lat1); 
    final dLon = _deg2rad(lon2 - lon1); 
 
    final a = 
        sin(dLat / 2) * sin(dLat / 2) + 
        cos(_deg2rad(lat1)) * 
            cos(_deg2rad(lat2)) * 
            sin(dLon / 2) * 
            sin(dLon / 2); 
 
    final c = 2 * atan2(sqrt(a), sqrt(1 - a)); 
 
    return R * c; 
  } 
 
  double _deg2rad(double deg) => deg * (pi / 180); 
  ///////================== 
 
  RxList<OrderModel> myOrders = <OrderModel>[].obs;
   RxBool isLoadingOrders = false.obs; 
  final orderService = OrderService(); 
  Future<void> fetchMyOrders() async { 
    try { 
      isLoadingOrders.value = true; 
      if (auth.currentUser == null) {
        myOrders.clear();
        return;
      }

      final userId = auth.currentUser!.id; 
      print("=== DEBUG: ĐANG TÌM ĐƠN HÀNG CHO USER ID: $userId ===");

      final orders = await orderService.getOrdersByUser(userId); 
 
      // ÉP BUỘC ĐỒNG BỘ THỰC ĐƠN MỚI NHẤT LÊN FIREBASE (ĐỂ KHỚP ID SEAFOOD, BEEF...)
      // final productService = Get.put(ProductService());
      // await productService.uploadSampleData();
 
      if (orders.isEmpty) {
        print("=== DEBUG: CHƯA CÓ ĐƠN HÀNG, ĐANG TẠO ĐƠN HÀNG MẪU VÀ DỮ LIỆU... ===");
        
        // 1. Tạo đơn hàng mẫu trạng thái "delivered" để có nút Đánh giá
        final sampleOrderId = "sample_order_${DateTime.now().millisecondsSinceEpoch}";
        final orderData = {
          "id": sampleOrderId,
          "userId": userId,
          "orderStatus": "delivered", 
          "paymentStatus": "paid",
          "totalAmount": 245000.0,
          "subTotal": 245000.0,
          "shippingAmount": 0,
          "taxRate": 0.0,
          "taxAmount": 0.0,
          "totalDiscountAmount": 0.0,
          "couponDiscountAmount": 0.0,
          "itemCount": 1,
          "orderDate": Timestamp.now(),
          "products": [
            {
              "productId": "pizza_hải_sản_cocktail_m", 
              "title": "Pizza Hải Sản Cocktail (M)",
              "price": 245000.0,
              "quantity": 1,
              "image": "https://img.dominos.vn/Seafood+cocktail+PC-MB1000X667px+(NEW).jpg",
              "brandName": "Dominos",
              "selectedVariation": {"Size": "M"}
            }
          ],
          "shippingAddress": {
            "name": "Lưu Đình Nghĩa", 
            "phoneNumber": "0337681077", 
            "number": "99",
            "street": "Đường Pizza",
            "ward": "Phường 10",
            "city": "TP. Hồ Chí Minh"
          },
          "paymentMethod": "cash",
          "paymentMethodType": "cash",
          "isApproved": true,
          "createdAt": Timestamp.now(),
          "updatedAt": Timestamp.now(),
        };
        await FirebaseFirestore.instance.collection('orders').doc(sampleOrderId).set(orderData);

        // 2. Kích hoạt đổ bộ dữ liệu thực đơn (Categories & Products)
        // final productService = Get.put(ProductService());
        // await productService.uploadSampleData();
 
        // ÉP BUỘC LÀM MỚI DANH MỤC VÀ SẢN PHẨM Ở TRANG CHỦ
        try {
          if (Get.isRegistered<CategoryController>()) {
            await Get.find<CategoryController>().fetchCategories();
          }
          if (Get.isRegistered<ProductController>()) {
            await Get.find<ProductController>().fetchPopularProducts();
          }
        } catch (e) {
          print("Error refreshing controllers: $e");
        }
        
        // 3. Tải lại danh sách đơn hàng
        final newOrders = await orderService.getOrdersByUser(userId);
        myOrders.assignAll(newOrders);
      } else {
        myOrders.assignAll(orders);
      }
    } catch (e) { 
      Get.snackbar("Error", "Không load được orders: $e"); 
    } finally { 
      isLoadingOrders.value = false; 
    } 
  } 
 
  Future<void> cancelOrder(OrderModel order) async { 
    try {
      if (order.docId.isEmpty) {
        Get.snackbar("Lỗi", "Không tìm thấy ID đơn hàng để hủy",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      await FirebaseFirestore.instance.collection("orders").doc(order.docId).update({ 
        "orderStatus": "cancelled", 
        "updatedAt": DateTime.now(), 
      }); 

      // Revert sold quantity (try-catch riêng để không làm treo tiến trình chính)
      try {
        await revertSoldQuantity(order);
      } catch (e) {
        print("Lỗi khi hoàn tác số lượng: $e");
      }

      // Update local list
      int index = myOrders.indexWhere((o) => o.docId == order.docId);
      if (index != -1) {
        myOrders[index].orderStatus = "cancelled";
        myOrders.refresh();
      }

    } catch (e) {
      rethrow;
    }
  } 
 
  Future<bool> canReviewProduct(String productId) async { 
    final userId = auth.currentUser!.id; 
 
    // 1. đã mua + delivered 
    final purchased = await orderService.hasUserPurchasedProduct( 
      userId: userId, 
      productId: productId, 
    ); 
 
    if (!purchased) return false; 
 
    // 2. đã review chưa 
    final alreadyReviewed = await hasUserReviewedProduct( 
      userId: userId, 
      productId: productId, 
    ); 
 
    return !alreadyReviewed; 
  } 
 
  Future<bool> hasUserReviewedProduct({ 
    required String userId, 
    required String productId, 
  }) async {
       final snapshot = await FirebaseFirestore.instance 
        .collection('reviews') 
        .where('userId', isEqualTo: userId) 
        .where('productId', isEqualTo: productId) 
        .where('isDeleted', isEqualTo: false) 
        .get(); 
 
    return snapshot.docs.isNotEmpty; 
  } 
 
  Future<void> updateSoldQuantityAfterOrder() async { 
    final firestore = FirebaseFirestore.instance; 
 
    for (var item in items) { 
      final docRef = firestore.collection('products').doc(item.productId); 
 
      await firestore.runTransaction((transaction) async { 
        final snapshot = await transaction.get(docRef); 
 
        if (!snapshot.exists) return; 
 
        final data = snapshot.data()!; 
 
        final int currentSold = data['soldQuantity'] ?? 0; 
        final int stock = data['stock'] ?? 0; 
 
        final int newSold = currentSold + item.quantity; 
 
        final bool isOutOfStock = newSold >= stock; 
 
        transaction.update(docRef, { 
          'soldQuantity': newSold, 
          'isOutOfStock': isOutOfStock, 
        }); 
      }); 
    } 
  } 
 
  Future<void> revertSoldQuantity(OrderModel order) async { 
    for (var item in order.products) { 
      await FirebaseFirestore.instance 
          .collection('products') 
          .doc(item.productId) 
          .update({'soldQuantity': FieldValue.increment(-item.quantity)}); 
    }}}