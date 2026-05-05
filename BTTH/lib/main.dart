import 'package:btl/controller/cart_controller.dart'; 
import 'package:btl/controller/notification_controller.dart'; 
import 'package:btl/controller/order_controller.dart'; 
import 'package:btl/controller/wishlist_controller.dart'; 
import 'package:btl/controller/settings_controller.dart'; 
import 'package:flutter/material.dart'; 
import 'app/app.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:get/get.dart'; 
import 'firebase_options.dart';
import 'controller/login_controller.dart'; 
 
void main() async { 
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
 
  Get.put(AuthController()); 
  Get.put(NotificationController()); 
  Get.put(CartController()); 
  Get.put(OrderController()); 
  Get.put(WishlistController()); 
 
  Get.put(SettingsController()); 
 
  runApp(MyApp());
  }