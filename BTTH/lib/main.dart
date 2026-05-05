import 'package:draf_project/controller/cart_controller.dart';
import 'package:draf_project/controller/notification_controller.dart';
import 'package:draf_project/controller/order_controller.dart';
import 'package:draf_project/controller/wishlist_controller.dart';
import 'package:draf_project/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'controller/login_controller.dart';
void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
Get.put(AuthController());
Get.put(NotificationController());
Get.put(CartController());
Get.put(OrderController());
Get.put(WishlistController());
Get.put(SettingsController());
runApp(MyApp());
}