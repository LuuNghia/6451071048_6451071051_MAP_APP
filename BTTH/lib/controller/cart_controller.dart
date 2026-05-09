import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../data/models/cart_item_model.dart'; 
import '../data/services/cart_service.dart'; 
 
class CartController extends GetxController { 
  final CartService _service = CartService(); 
 
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs; 
 
  /// ADD 
  void addToCart(CartItemModel item) { 
    _service.addToCart(item); 
 
    ///QUAN TRỌNG: phải assign lại list 
    cartItems.assignAll(_service.cart.items); 

  } 
 
  /// REMOVE 
  void removeItem(CartItemModel item) { 
    _service.removeItem(item); 
    cartItems.assignAll(_service.cart.items); 
  } 
 
  /// INCREASE 
  void increaseQty(CartItemModel item) { 
    _service.increaseQty(item); 
    cartItems.assignAll(_service.cart.items); 
  } 
 
  /// DECREASE 
  void decreaseQty(CartItemModel item) { 
    _service.decreaseQty(item); 
    cartItems.assignAll(_service.cart.items); 
  } 
 
  /// TOTAL PRICE 
  double get totalPrice { 
    return cartItems.fold( 
      0, 
      (sum, item) => sum + item.finalPrice * item.quantity, 
    ); 
  } 
 
  /// TOTAL COUNT (cho icon) 
  int get totalItems { 
    return cartItems.fold(0, (sum, item) => sum + item.quantity); 
  } 
 
  bool isInCart(String productId, Map<String, String>? variation) { 
    return cartItems.any( 
      (item) => 
          item.productId == productId && 
          _isSameVariation(item.selectedVariation, variation), 
    ); 
  } 
 
  /// copy lại logic từ service 
  bool _isSameVariation(Map<String, String>? a, Map<String, String>? b) 
{ 
    if (a == null && b == null) return true; 
    if (a == null || b == null) return false; 
    if (a.length != b.length) return false; 
 
    for (final key in a.keys) { 
      if (a[key] != b[key]) return false;
       } 
    return true; 
  } 
 
  bool isProductInCart(String productId, Map<String, String>? variation) 
{ 
    return cartItems.any((item) { 
      /// chỉ cần cùng productId là đủ (bỏ variation) 
      return item.productId == productId; 
    }); 
  } 

  /// Update Item Size
  void updateItemSize(CartItemModel item, String newSize) {
    if (item.selectedVariation == null) return;
    final currentSizeKey = item.selectedVariation!.keys.firstWhere(
      (k) => k.toLowerCase() == 'size',
      orElse: () => '',
    );
    if (currentSizeKey.isEmpty) return;

    final currentSize = item.selectedVariation![currentSizeKey];
    if (currentSize == newSize) return;

    // Calculate base price
    double basePrice = item.price;
    if (currentSize == 'M') basePrice -= 30000;
    if (currentSize == 'L') basePrice -= 60000;

    // Calculate new price
    double newPrice = basePrice;
    if (newSize == 'M') newPrice += 30000;
    if (newSize == 'L') newPrice += 60000;

    item.selectedVariation![currentSizeKey] = newSize;
    item.price = newPrice;

    cartItems.refresh();
  }
}