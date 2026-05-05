import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:draf_project/data/models/order_model.dart'; 
import 'package:draf_project/screens/order/ordered_detail_screen.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import '../../controller/notification_controller.dart'; 
 
class MyNotificationScreen extends StatelessWidget { 
  MyNotificationScreen({super.key}); 
 
  final NotificationController controller = Get.find(); 
  // Hàm hỗ trợ lấy Icon và Màu sắc dựa trên OrderStatus 
  Map<String, dynamic> _getStatusStyle(String message) { 
    String msg = message.toLowerCase(); 
    if (msg.contains('created')) 
      return {'icon': Icons.create, 'color': Colors.blue}; 
    if (msg.contains('pending')) 
      return {'icon': Icons.hourglass_empty, 'color': Colors.orange}; 
    if (msg.contains('processing')) 
      return {'icon': Icons.sync, 'color': Colors.amber}; 
    if (msg.contains('shipped')) 
      return {'icon': Icons.local_shipping, 'color': Colors.purple}; 
    if (msg.contains('delivered')) 
      return {'icon': Icons.check_circle, 'color': Colors.green}; 
    if (msg.contains('cancelled')) 
      return {'icon': Icons.cancel, 'color': Colors.red}; 
    if (msg.contains('returned')) 
      return {'icon': Icons.keyboard_return, 'color': Colors.blueGrey}; 
    if (msg.contains('refunded')) 
      return {'icon': Icons.monetization_on, 'color': Colors.teal}; 
 return {'icon': Icons.notifications, 'color': Colors.grey}; // Mặc 
định 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: Colors.grey[100], // Nền xám nhạt cho chuyên 
nghiệp 
      appBar: AppBar( 
        elevation: 0, 
        centerTitle: true, 
        title: const Text( 
          "Thông báo của tôi", 
          style: TextStyle(fontWeight: FontWeight.bold, color: 
Colors.black), 
        ), 
        backgroundColor: Colors.white, 
        actions: [ 
          IconButton( 
            icon: const Icon(Icons.done_all, color: Colors.blue), 
            onPressed: () { 
              // Logic đánh dấu đọc hết tất cả nếu cần 
            }, 
          ), 
        ], 
      ), 
      body: Obx(() { 
        if (controller.notifications.isEmpty) { 
          return Center( 
            child: Column( 
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [ 
                Icon( 
                  Icons.notifications_none, 
                  size: 100, 
                  color: Colors.grey[300], 
                ), 
                const SizedBox(height: 20), 
                Text( 
                  "Chưa có thông báo nào", 
                  style: TextStyle( 
                    fontSize: 18, 
                    color: Colors.grey[600], 
                    fontWeight: FontWeight.w500, 
                  ), 
                ), 
                const SizedBox(height: 10), 
                const Text( "Các cập nhật về đơn hàng sẽ hiện ở đây", 
                  style: TextStyle(color: Colors.grey), 
                ), 
              ], 
            ), 
          ); 
        } 
 
        return ListView.builder( 
          padding: const EdgeInsets.symmetric(vertical: 10), 
          itemCount: controller.notifications.length, 
          itemBuilder: (context, index) { 
            final noti = controller.notifications[index]; 
            final style = _getStatusStyle(noti.message); 
 
            return Container( 
              margin: const EdgeInsets.symmetric(horizontal: 16, 
vertical: 6), 
              decoration: BoxDecoration( 
                color: noti.isRead 
                    ? Colors.white 
                    : Colors.blue.withOpacity(0.05), 
                borderRadius: BorderRadius.circular(15), 
                boxShadow: [ 
                  BoxShadow( 
                    color: Colors.black.withOpacity(0.03), 
                    blurRadius: 10, 
                    offset: const Offset(0, 5), 
                  ), 
                ], 
              ), 
              child: ClipRRect( 
                borderRadius: BorderRadius.circular(15), 
                child: IntrinsicHeight( 
                  child: Row( 
                    children: [ 
                      // Thanh màu chỉ thị bên trái 
                      Container( 
                        width: 5, 
                        color: noti.isRead 
                            ? Colors.transparent 
                            : style['color'], 
                      ), 
                      Expanded( 
                        child: ListTile( 
                          contentPadding: const EdgeInsets.symmetric( 
                            horizontal: 15, 
                            vertical: 10, 
                          ), 
                          leading: CircleAvatar( backgroundColor: 
style['color'].withOpacity(0.1), 
                            child: Icon(style['icon'], color: 
style['color']), 
                          ), 
                          title: Text( 
                            noti.message, 
                            style: TextStyle( 
                              fontWeight: noti.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.bold, 
                              fontSize: 15, 
                            ), 
                          ), 
                          subtitle: Padding( 
                            padding: const EdgeInsets.only(top: 8.0), 
                            child: Row( 
                              children: [ 
                                const Icon( 
                                  Icons.access_time, 
                                  size: 14, 
                                  color: Colors.grey, 
                                ), 
                                const SizedBox(width: 5), 
                                Text( 
                                  // Hiển thị thời gian (Bạn có thể dùng 
intl để format đẹp hơn) 
                                  "${noti.createdAt.hour}:${noti.created
At.minute} - 
${noti.createdAt.day}/${noti.createdAt.month}/${noti.createdAt.year}", 
                                  style: const TextStyle( 
                                    fontSize: 12, 
                                    color: Colors.grey, 
                                  ), 
                                ), 
                              ], 
                            ), 
                          ), 
                          trailing: !noti.isRead 
                              ? Container( 
                                  width: 10, 
                                  height: 10, 
                                  decoration: const BoxDecoration( 
                                    color: Colors.red, 
                                    shape: BoxShape.circle, 
                                  ), 
                                ) 
                              : null, 
                          onTap: () async { 
                            /// mark read
                            await controller.markAsRead(noti); 
 
                            /// load order 
                            final orderDoc = await 
FirebaseFirestore.instance 
                                .collection('orders') 
                                .where('id', isEqualTo: noti.orderId) 
                                .limit(1) 
                                .get(); 
 
                            if (orderDoc.docs.isNotEmpty) { 
                              final data = orderDoc.docs.first.data(); 
                              data['docId'] = orderDoc.docs.first.id; 
 
                              final order = OrderModel.fromJson(data); 
 
                              Navigator.push( 
                                context, 
                                MaterialPageRoute( 
                                  builder: (_) => 
                                      OrderDetailScreen(order: order), 
                                ), 
                              ); 
                            } 
                          }, 
                        ), 
                      ), 
                    ], 
                  ), 
                ), 
              ), 
            ); 
          }, 
        ); 
      }), 
    ); 
  } 
}