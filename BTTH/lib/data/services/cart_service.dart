import 'package:get_storage/get_storage.dart';
import '../models/cart_model.dart'; 
import '../models/cart_item_model.dart'; 
 
class CartService { 
  final CartModel _cart = CartModel.empty(); 
  final _storage = GetStorage();
  static const _cartKey = 'cart_items';
 
  CartService() {
    _loadCart();
  }

  void _loadCart() {
    try {
      final List? storedItems = _storage.read(_cartKey);
      if (storedItems != null) {
        _cart.items = storedItems.map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  void saveCart() {
    try {
      _storage.write(_cartKey, _cart.items.map((e) => e.toJson()).toList());
    } catch (e) {
      print("Error saving cart: $e");
    }
  }

  CartModel get cart => _cart; 
 
  /// Add to cart 
  void addToCart(CartItemModel item) { 
    final index = _cart.items.indexWhere( 
      (e) => 
          e.productId == item.productId && 
          _isSameVariation(e.selectedVariation, item.selectedVariation), 
    ); 
 
    if (index >= 0) { 
      _cart.items[index].quantity += item.quantity; 
    } else { 
      _cart.items.add(item); 
    } 
    saveCart();
  } 
 
  /// Remove item 
  void removeItem(CartItemModel item) { 
    _cart.items.remove(item); 
    saveCart();
  } 
 
  ///  Increase 
  void increaseQty(CartItemModel item) { 
    item.quantity++; 
    saveCart();
  } 
 
  /// Decrease 
  void decreaseQty(CartItemModel item) { 
    if (item.quantity > 1) { 
      item.quantity--; 
    } else { 
      _cart.items.remove(item); 
    } 
    saveCart();
  } 
 
  ///Compare variation 
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

  /// Clear Cart
  void clearCart() {
    _cart.items.clear();
    saveCart();
  }
}