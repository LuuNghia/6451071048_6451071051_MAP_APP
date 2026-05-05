import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import '../../common/widgets/product_card.dart'; 
import '../../controller/product_controller.dart'; 
 
class PopularProductScreen extends StatefulWidget { 
  const PopularProductScreen({super.key}); 
 
  @override 
  State<PopularProductScreen> createState() => 
_PopularProductScreenState(); 
} 
 
class _PopularProductScreenState extends State<PopularProductScreen> { 
  final ProductController productController = 
Get.find<ProductController>(); 
 
  // Biến lưu trữ filter đang chọn 
  String _selectedFilterKey = 'Name'; 
 
  // Map cấu hình filter: Hiển thị -> Giá trị gửi vào Controller 
  final Map<String, String> _filterMap = { 
    'Name': 'name', 
    'Price: Low to High': 'low_price', 
    'Price: High to Low': 'high_price', 
    'Newest': 'newest', 
  }; 
 
  @override 
  void initState() { 
    super.initState(); 
    // Gọi API lấy sản phẩm sau khi khung hình đầu tiên được dựng 
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      productController.fetchAllPopularProducts(); 
    }); 
  }
   @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: Colors.grey[50], // Nền xám nhạt đồng bộ HomeScreen 
      appBar: AppBar( 
        title: const Text( 
          'Sản phẩm phổ biến', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), 
        ), 
        centerTitle: true, 
        elevation: 0, 
        foregroundColor: Colors.white, 
        flexibleSpace: Container( 
          decoration: BoxDecoration( 
            gradient: LinearGradient( 
              begin: Alignment.topLeft, 
              end: Alignment.bottomRight, 
              colors: [Colors.blue.shade700, Colors.blue.shade400], 
            ), 
          ), 
        ), 
      ), 
      body: Column( 
        children: [ 
          /// 1. DẢI FILTER SINH ĐỘNG (SCROLLABLE CHIPS) 
          Container( 
            width: double.infinity, 
            padding: const EdgeInsets.symmetric(vertical: 16), 
            decoration: BoxDecoration( 
              color: Colors.white, 
              boxShadow: [ 
                BoxShadow( 
                  color: Colors.black.withOpacity(0.03), 
                  blurRadius: 10, 
                  offset: const Offset(0, 5), 
                ), 
              ], 
            ), 
            child: SingleChildScrollView( 
              scrollDirection: Axis.horizontal, 
              padding: const EdgeInsets.symmetric(horizontal: 16), 
              physics: const BouncingScrollPhysics(), 
              child: Row( 
                children: _filterMap.keys.map((filterName) { 
                  final isSelected = _selectedFilterKey == filterName; 
                  return Padding( 
                    padding: const EdgeInsets.only(right: 10), 
                    child: ChoiceChip( 
                      label: Text(filterName),
                       selected: isSelected, 
                      selectedColor: Colors.blue.shade600, 
                      backgroundColor: Colors.grey.shade100, 
                      labelStyle: TextStyle( 
                        color: isSelected ? Colors.white : Colors.black87, 
                        fontWeight: isSelected 
                            ? FontWeight.bold 
                            : FontWeight.normal, 
                        fontSize: 13, 
                      ), 
                      elevation: isSelected ? 4 : 0, 
                      pressElevation: 2, 
                      padding: const EdgeInsets.symmetric( 
                        horizontal: 12, 
                        vertical: 8, 
                      ), 
                      shape: RoundedRectangleBorder( 
                        borderRadius: BorderRadius.circular(20), 
                        side: BorderSide( 
                          color: isSelected 
                              ? Colors.blue.shade600 
                              : Colors.transparent, 
                        ), 
                      ), 
                      onSelected: (bool selected) { 
                        if (selected) { 
                          setState(() { 
                            _selectedFilterKey = filterName; 
                          }); 
                          // Gọi hàm sắp xếp trong controller 
                          productController.sortPopularProducts( 
                            _filterMap[filterName]!, 
                          ); 
                        } 
                      }, 
                    ), 
                  ); 
                }).toList(), 
              ), 
            ), 
          ), 
 
          /// 2. DANH SÁCH SẢN PHẨM 
          Expanded( 
            child: Obx(() { 
              // Trạng thái đang tải dữ liệu 
              if (productController.isLoading.value) { 
                return const Center( 
                  child: CircularProgressIndicator(
                     valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), 
                  ), 
                ); 
              } 
 
              // Trạng thái không có dữ liệu 
              if (productController.popularProducts.isEmpty) { 
                return Center( 
                  child: Column( 
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [ 
                      Icon( 
                        Icons.inventory_2_outlined, 
                        size: 80, 
                        color: Colors.grey.shade300, 
                      ), 
                      const SizedBox(height: 16), 
                      Text( 
                        "Không tìm thấy sản phẩm nào", 
                        style: TextStyle( 
                          color: Colors.grey.shade600, 
                          fontSize: 16, 
                        ), 
                      ), 
                    ], 
                  ), 
                ); 
              } 
 
              // Hiển thị Grid sản phẩm 
              return GridView.builder( 
                padding: const EdgeInsets.all(16), 
                itemCount: productController.popularProducts.length, 
                physics: const BouncingScrollPhysics(), 
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( 
                  crossAxisCount: 2, 
                  crossAxisSpacing: 16, // Tăng khoảng cách cho thoáng 
                  mainAxisSpacing: 16, 
                  childAspectRatio: 
                      0.65, // Điều chỉnh tỉ lệ khớp với HomeScreen mới 
                ), 
                itemBuilder: (context, index) { 
                  final product = productController.popularProducts[index]; 
                  // Có thể bọc thêm Animation ở đây nếu muốn 
                  return ProductCard(product: product); 
                }, 
              );
               }), 
          ), 
        ], 
      ), 
    ); 
  } 
} 