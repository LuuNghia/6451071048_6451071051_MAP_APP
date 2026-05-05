import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import 'pizza_products.dart';

class PizzaOrders {
  static List<OrderModel> defaults({String userId = 'local-user'}) {
    final products = PizzaProducts.defaults();
    final now = DateTime.now();

    final order1Items = [
      CartItemModel(
        productId: products[0].id,
        quantity: 1,
        image: products[0].thumbnail,
        price: products[0].price,
        title: products[0].title,
        brandName: products[0].brandName,
        selectedVariation: const {'Size': 'M'},
      ),
      CartItemModel(
        productId: products[2].id,
        quantity: 2,
        image: products[2].thumbnail,
        price: products[2].price,
        title: products[2].title,
        brandName: products[2].brandName,
        selectedVariation: const {'Size': 'L'},
      ),
    ];

    final order2Items = [
      CartItemModel(
        productId: products[6].id,
        quantity: 1,
        image: products[6].thumbnail,
        price: products[6].price,
        title: products[6].title,
        brandName: products[6].brandName,
        selectedVariation: const {'Size': 'S'},
      ),
    ];

    double subTotal(List<CartItemModel> items) {
      return items.fold(0, (sum, item) => sum + item.price * item.quantity);
    }

    OrderModel buildOrder({
      required String id,
      required List<CartItemModel> items,
      required String status,
      required DateTime orderDate,
    }) {
      final subtotal = subTotal(items);
      final tax = subtotal * 0.1;
      final shipping = 30000.0;
      return OrderModel(
        docId: id,
        id: id,
        userId: userId,
        userDeviceToken: '',
        products: items,
        subTotal: subtotal,
        shippingAmount: shipping.toInt(),
        taxRate: 0.1,
        taxAmount: tax,
        couponDiscountAmount: 0,
        pointsUsed: 0,
        pointsDiscountAmount: 0,
        totalDiscountAmount: 0,
        totalAmount: subtotal + tax + shipping,
        paymentStatus: 'pending',
        orderStatus: status,
        orderDate: orderDate,
        shippingDate: status == 'delivered'
            ? orderDate.add(const Duration(days: 2))
            : null,
        shippingAddress: const {
          'number': '66',
          'street': 'Long Le',
          'ward': 'Xa Sa Phin',
          'city': 'Tuyen Quang',
        },
        activities: const [],
        itemCount: items.length,
        createdAt: orderDate,
        updatedAt: orderDate,
        paymentMethod: 'cash',
        paymentMethodType: PaymentMethods.cash,
      );
    }

    return [
      buildOrder(
        id: '172625372751',
        items: order1Items,
        status: 'created',
        orderDate: now.subtract(const Duration(days: 1)),
      ),
      buildOrder(
        id: '172625218800',
        items: order2Items,
        status: 'delivered',
        orderDate: now.subtract(const Duration(days: 4)),
      ),
      buildOrder(
        id: '1772459760970',
        items: order2Items,
        status: 'cancelled',
        orderDate: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
