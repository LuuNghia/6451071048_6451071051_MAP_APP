import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/notification_model.dart'; 
 
class NotificationService { 
  final _db = FirebaseFirestore.instance; 
 
  Stream<List<NotificationModel>> getUserNotifications(String userId) { 
    return _db 
        .collection('notifications') 
        .where('userId', isEqualTo: userId) 
        .snapshots() 
        .map((snapshot) { 
          final list = snapshot.docs 
              .map((doc) => NotificationModel.fromFirestore(doc)) 
              .toList(); 
          // Sắp xếp thủ công theo thời gian mới nhất lên đầu
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        }); 
  } 
 
  Future<void> markAsRead(String docId) async { 
    await FirebaseFirestore.instance 
        .collection('notifications') 
        .doc(docId) 
        .update({"isRead": true}); 
  } 

  Future<void> sendNotification({
    required String userId,
    required String orderId,
    required String orderStatus,
    required String message,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'orderId': orderId,
      'orderStatus': orderStatus,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}