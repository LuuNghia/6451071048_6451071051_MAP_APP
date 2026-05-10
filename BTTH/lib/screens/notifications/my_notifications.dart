import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:btl/data/models/order_model.dart'; 
import 'package:btl/screens/order/ordered_detail_screen.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import '../../controller/notification_controller.dart'; 
 
class MyNotificationScreen extends StatelessWidget { 
  MyNotificationScreen({super.key}); 
 
  final NotificationController controller = Get.find(); 
  
  // Hàm hỗ trợ lấy Icon và Màu sắc dựa trên nội dung tin nhắn 
  Map<String, dynamic> _getStatusStyle(String message) { 
    String msg = message.toLowerCase(); 
    if (msg.contains('thành công') || msg.contains('created')) 
      return {'icon': Icons.shopping_bag_outlined, 'color': Colors.blue}; 
    if (msg.contains('hủy') || msg.contains('cancelled')) 
      return {'icon': Icons.cancel_outlined, 'color': Colors.red}; 
    if (msg.contains('đang giao') || msg.contains('shipped')) 
      return {'icon': Icons.local_shipping_outlined, 'color': Colors.purple}; 
    if (msg.contains('đã nhận') || msg.contains('delivered')) 
      return {'icon': Icons.check_circle_outline, 'color': Colors.green}; 
    if (msg.contains('đang chuẩn bị') || msg.contains('processing')) 
      return {'icon': Icons.restaurant_menu, 'color': Colors.orange}; 
      
    return {'icon': Icons.notifications_none_rounded, 'color': Colors.blueGrey}; 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: Colors.grey[50], 
      appBar: AppBar( 
        elevation: 0, 
        centerTitle: true, 
        title: const Text( 
          "Thông báo của tôi", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18), 
        ), 
        backgroundColor: Colors.white, 
        iconTheme: const IconThemeData(color: Colors.black),
      ), 
      body: Obx(() { 
        if (controller.notifications.isEmpty) { 
          return Center( 
            child: Column( 
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [ 
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.notifications_off_outlined, size: 80, color: Colors.blue.shade200),
                ),
                const SizedBox(height: 24), 
                const Text( 
                  "Chưa có thông báo nào", 
                  style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold), 
                ), 
                const SizedBox(height: 8), 
                Text( "Các cập nhật về đơn hàng sẽ hiện ở đây", 
                  style: TextStyle(color: Colors.grey.shade500), 
                ), 
              ], 
            ), 
          ); 
        } 
 
        return ListView.builder( 
          padding: const EdgeInsets.symmetric(vertical: 12), 
          itemCount: controller.notifications.length, 
          itemBuilder: (context, index) { 
            final noti = controller.notifications[index]; 
            final style = _getStatusStyle(noti.message); 
 
            return GestureDetector(
              onTap: () async { 
                await controller.markAsRead(noti); 
                final orderDoc = await FirebaseFirestore.instance 
                    .collection('orders') 
                    .where('id', isEqualTo: noti.orderId) 
                    .limit(1) 
                    .get(); 
 
                if (orderDoc.docs.isNotEmpty) { 
                  final data = orderDoc.docs.first.data(); 
                  data['docId'] = orderDoc.docs.first.id; 
                  final order = OrderModel.fromJson(data); 
                  Get.to(() => OrderDetailScreen(order: order));
                } 
              },
              child: Container( 
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration( 
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), 
                  border: Border.all(
                    color: noti.isRead ? Colors.transparent : Colors.blue.shade100,
                    width: 1,
                  ),
                  boxShadow: [ 
                    BoxShadow( 
                      color: Colors.black.withOpacity(0.04), 
                      blurRadius: 15, 
                      offset: const Offset(0, 4), 
                    ), 
                  ], 
                ), 
                child: Row( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ 
                    // Icon trạng thái
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: style['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(style['icon'], color: style['color'], size: 24),
                    ),
                    const SizedBox(width: 16),
                    
                    // Nội dung
                    Expanded( 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text( 
                                  noti.message, 
                                  style: TextStyle( 
                                    fontWeight: noti.isRead ? FontWeight.w500 : FontWeight.bold, 
                                    fontSize: 15,
                                    height: 1.4,
                                    color: Colors.black87,
                                  ), 
                                ),
                              ),
                              if (!noti.isRead)
                                Container( 
                                  width: 8, height: 8, 
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle), 
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row( 
                            children: [ 
                              Icon(Icons.access_time, size: 14, color: Colors.grey.shade400), 
                              const SizedBox(width: 6), 
                              Text( 
                                "${noti.createdAt.hour.toString().padLeft(2, '0')}:${noti.createdAt.minute.toString().padLeft(2, '0')} - ${noti.createdAt.day}/${noti.createdAt.month}/${noti.createdAt.year}", 
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w400), 
                              ), 
                            ], 
                          ),
                        ],
                      ),
                    ), 
                  ], 
                ), 
              ),
            ); 
          }, 
        ); 
      }), 
    ); 
  } 
}