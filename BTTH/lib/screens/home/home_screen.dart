import 'package:btl/controller/cart_controller.dart'; 
import 'package:btl/controller/notification_controller.dart'; 
import 'package:btl/screens/notifications/my_notifications.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; // Đảm bảo đã thêm GetX 
import '../../common/widgets/home_banner_slider.dart'; 
 
import '../../common/widgets/product_card.dart'; 
 
import '/screens/product/product_by_subcategory_screen.dart'; 
import '../order/cart_overview_screen.dart'; 
import '../product/popular_product_screen.dart'; 
import 'package:btl/controller/login_controller.dart'; 
import 'package:btl/controller/category_controller.dart'; 
import 'package:btl/controller/product_controller.dart'; 
 
class HomeScreen extends StatelessWidget { 
  HomeScreen({super.key}); 
  final CategoryController categoryController = Get.put(CategoryController()); 
  final ProductController productController = Get.put(ProductController()); 
 
  final cartController = Get.find<CartController>(); 
  @override 
  Widget build(BuildContext context) { 
    // Sử dụng GetBuilder để bọc bên ngoài Scaffold 
    return GetBuilder<AuthController>( 
      builder: (authController) { 
        // Logic lấy tên user từ controller 
        final user = authController.currentUser; 
        String fullName = 'Guest User'; 
 
        if (user != null) { 
          fullName = '${user.firstName} ${user.lastName}'; 
        } 
 
        return Scaffold(
             body: Column( 
            children: [ 
              /// TOP BLUE HEADER 
              Container( 
                padding: const EdgeInsets.all(24), 
                decoration: const BoxDecoration( 
                  color: Colors.blue, 
                  borderRadius: BorderRadius.only( 
                    bottomLeft: Radius.circular(24), 
                    bottomRight: Radius.circular(24), 
                  ), 
                ), 
                child: SafeArea( 
                  bottom: false, 
                  child: Column( 
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [ 
                      Row( 
                        children: [ 
                          Column( 
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [ 
                              const Text( 
                                'Good day for shopping', 
                                style: TextStyle(color: Colors.white70), 
                              ), 
                              const SizedBox(height: 4), 
                              Text( 
                                fullName, //Đã thay bằng tên động 
                                style: const TextStyle( 
                                  color: Colors.white, 
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold, 
                                ), 
                              ), 
                            ], 
                          ), 
                          const Spacer(), 
 
                          /// Notification Icon 
                          /// Chỉ hiện chuông khi đã login 
                          if (authController.currentUser != null) 
                            Obx(() { 
                              final notificationController = 
                                  Get.find<NotificationController>(); 
 
                              return Stack( 
                                children: [ 
                                  IconButton(
                                      onPressed: () { 
                                      Navigator.push( 
                                        context, 
                                        MaterialPageRoute( 
                                          builder: (_) => 
                                              MyNotificationScreen(), 
                                        ), 
                                      ); 
                                    }, 
                                    icon: const Icon( 
                                      Icons.notifications, 
                                      color: Colors.white, 
                                    ), 
                                  ), 
 
                                  if (notificationController.unreadCount.value > 
                                      0) 
                                    Positioned( 
                                      right: 6, 
                                      top: 6, 
                                      child: Container( 
                                        padding: const EdgeInsets.all(4), 
                                        decoration: const BoxDecoration( 
                                          color: Colors.red, 
                                          shape: BoxShape.circle, 
                                        ), 
                                        child: Text( 
                                          notificationController 
                                              .unreadCount 
                                              .value 
                                              .toString(), 
                                          style: const TextStyle( 
                                            color: Colors.white, 
                                            fontSize: 10, 
                                          ), 
                                        ), 
                                      ), 
                                    ), 
                                ], 
                              ); 
                            }), 
                          Obx( 
                            () => Stack( 
                              children: [ 
                                IconButton( 
                                  onPressed: () { 
                                    Navigator.push( 
                                      context,
                                          MaterialPageRoute( 
                                        builder: (_) => 
                                            const CartOverviewScreen(), 
                                      ), 
                                    ); 
                                  }, 
                                  icon: const Icon( 
                                    Icons.shopping_cart, 
                                    color: Colors.white, 
                                  ), 
                                ), 
 
                                if (cartController.totalItems > 0) 
                                  Positioned( 
                                    right: 6, 
                                    top: 6, 
                                    child: Container( 
                                      padding: const EdgeInsets.all(4), 
                                      decoration: const BoxDecoration( 
                                        color: Colors.red, 
                                        shape: BoxShape.circle, 
                                      ), 
                                      child: Text( 
                                        cartController.totalItems.toString(), 
                                        style: const TextStyle( 
                                          color: Colors.white, 
                                          fontSize: 10, 
                                        ), 
                                      ), 
                                    ), 
                                  ), 
                              ], 
                            ), 
                          ), 
                        ], 
                      ), 
                      const SizedBox(height: 16), 
                      TextField( 
                        onChanged: (value) { 
                          productController.onSearchChanged(value); 
                        }, 
                        decoration: InputDecoration( 
                          hintText: 'Tìm kiếm trong cửa hàng', 
                          prefixIcon: const Icon(Icons.search), 
                          filled: true, 
                          fillColor: Colors.white, 
                          border: OutlineInputBorder( 
                            borderRadius: BorderRadius.circular(12), 
                            borderSide: BorderSide.none, 
                              ), 
                        ), 
                      ), 
                      const SizedBox(height: 16), 
                      const Text( 
                        'Danh mục phổ biến', 
                        style: TextStyle( 
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                        ), 
                      ), 
                      const SizedBox(height: 12), 
                      SizedBox( 
                        height: 90, 
                        child: Obx(() { 
                          if (categoryController.isLoading.value) { 
                            return const Center( 
                              child: CircularProgressIndicator(), 
                            ); 
                          } 
 
                          return ListView.builder( 
                            scrollDirection: Axis.horizontal, 
                            itemCount: categoryController.categories.length, 
                            itemBuilder: (context, index) { 
                              final category = 
                                  categoryController.categories[index]; 
 
                              return Padding( 
                                padding: const EdgeInsets.only(right: 12), 
                                child: GestureDetector( 
                                  onTap: () { 
                                    Navigator.push( 
                                      context, 
                                      MaterialPageRoute( 
                                        builder: (_) => 
                                            ProductBySubCategoryScreen( 
                                              categoryId: category.id, 
                                              categoryName: 
category.name, 
                                            ), 
                                      ), 
                                    ); 
                                  }, 
                                  child: Column( 
                                    children: [ 
                                      CircleAvatar( 
                                        radius: 30, 

  backgroundImage: NetworkImage( 
                                          category.imageURL, 
                                        ), 
                                      ), 
                                      const SizedBox(height: 6), 
                                      Text( 
                                        category.name, 
                                        style: const TextStyle( 
                                          color: Colors.white, 
                                          fontSize: 12, 
                                        ), 
                                      ), 
                                    ], 
                                  ), 
                                ), 
                              ); 
                            }, 
                          ); 
                        }), 
                      ), 
                    ], 
                  ), 
                ), 
              ), 
 
              /// CONTENT 
              Expanded( 
                child: Obx(() { 
                  /// ================= SEARCH MODE ================= 
                  if (productController.searchQuery.isNotEmpty) { 
                    if (productController.searchResults.isEmpty) { 
                      return const Center( 
                        child: Text("Không tìm thấy sản phẩm"), 
                      ); 
                    } 
 
                    return GridView.builder( 
                      padding: const EdgeInsets.all(16), 
                      itemCount: productController.searchResults.length, 
                      gridDelegate: 
                          const SliverGridDelegateWithFixedCrossAxisCount( 
                            crossAxisCount: 2, 
                            crossAxisSpacing: 12, 
                            mainAxisSpacing: 12, 
                            childAspectRatio: 0.58, 
                          ), 
                      itemBuilder: (context, index) { 
                        final product = productController.searchResults[index]; 
                        return ProductCard(product: product); 
                      }, 
                    ); 
                  } 
 
                  /// ================= NORMAL MODE ================= 
                  return SingleChildScrollView( 
                    padding: const EdgeInsets.all(16), 
                    child: Column( 
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [ 
                        const HomeBannerSlider(), 
                        const SizedBox(height: 24), 
                        Row( 
                          children: [ 
                            const Text( 
                              'Sản phẩm phổ biến', 
                              style: TextStyle( 
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                              ), 
                            ), 
                            const Spacer(), 
                            TextButton( 
                              onPressed: () { 
                                Navigator.push( 
                                  context, 
                                  MaterialPageRoute( 
                                    builder: (_) => 
                                        const PopularProductScreen(), 
                                  ), 
                                ); 
                              }, 
                              child: const Text('Xem tất cả'), 
                            ), 
                          ], 
                        ), 
                        const SizedBox(height: 16), 
 
                        /// PRODUCTS 
                        Obx(() { 
                          if (productController.isLoading.value) { 
                            return const Center( 
                              child: CircularProgressIndicator(), 
                            ); 
                          } 
 
                          return GridView.builder( 
                            itemCount: 
productController.products.length,
   shrinkWrap: true, 
                            physics: const NeverScrollableScrollPhysics(), 
                            gridDelegate: 
                                const SliverGridDelegateWithFixedCrossAxisCount( 
                                  crossAxisCount: 2, 
                                  crossAxisSpacing: 12, 
                                  mainAxisSpacing: 12, 
                                  childAspectRatio: 0.58, 
                                ), 
                            itemBuilder: (context, index) { 
                              final product = productController.products[index]; 
 
                              return ProductCard(product: product); 
                            }, 
                          ); 
                        }), 
                      ], 
                    ), 
                  ); 
                }), 
              ), 
            ], 
          ), 
        ); 
      }, 
    ); 
  } 
} 