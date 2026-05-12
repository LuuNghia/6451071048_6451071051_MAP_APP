import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/order_model.dart';
import '../data/services/order_service.dart';

class OrderController {
  final OrderService _service = OrderService();
  List<OrderModel> orders = [];
  List<OrderModel> filteredOrders = [];
  Future<void> fetchOrders() async {
    orders = await _service.getAllOrders();
    for (var order in orders) {
      final user = await _service.getUserById(order.userId);
      if (user != null) {
        order.customerName =
            "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}";
      }
    }
    filteredOrders = orders;
  }

  void searchOrder(String keyword) {
    if (keyword.isEmpty) {
      filteredOrders = orders;
    } else {
      filteredOrders = orders
          .where(
            (o) =>
                o.id.toLowerCase().contains(keyword.toLowerCase()) ||
                o.customerName.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    }
  }

  Future<void> deleteOrder(String docId) async {
    await _service.deleteOrder(docId);
    orders.removeWhere((e) => e.docId == docId);
    filteredOrders = orders;
  }

  Future<void> updateOrderStatus(OrderModel order, String newStatus) async {
    final oldStatus = order.orderStatus.toLowerCase();
    final lowerNewStatus = newStatus.toLowerCase();
    const revertStatuses = ["canceled", "returned", "refunded"];
    if (revertStatuses.contains(lowerNewStatus) &&
        !revertStatuses.contains(oldStatus)) {
      await _service.handleOrderRevertStock(order);
    }

    /// UPDATE ORDER
    await _service.updateOrderStatus(order.docId, newStatus);

    /// CREATE NOTIFICATION
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': order.userId,
      'orderId': order.id,
      'orderStatus': newStatus,
      'message':
          'Đơn hàng ${order.id} của bạn đã được cập nhật trạng thái $newStatus',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTransaction({
    required OrderModel order,
    required double amountReceived,
    required DateTime? shippingDate,
    required String paymentStatus,
  }) async {
    String finalStatus = paymentStatus;
    if (amountReceived >= order.totalAmount) {
      finalStatus = "paid";
    }
    await _service.updateTransaction(
      docId: order.docId,
      paymentStatus: finalStatus,
      shippingDate: shippingDate,
      amountCaptured: amountReceived,
    );
  }
}
