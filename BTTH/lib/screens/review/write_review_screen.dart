import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import '../../data/models/product_model.dart'; 
import '../../controller/login_controller.dart'; 
import '../../controller/product_controller.dart';
import '../../controller/mystore_controller.dart';
 
class WriteReviewScreen extends StatefulWidget { 
  final ProductModel product; 
  final String? reviewId; 
 
  const WriteReviewScreen({super.key, required this.product, this.reviewId}); 
 
  @override 
  State<WriteReviewScreen> createState() => _WriteReviewScreenState(); 
} 
 
class _WriteReviewScreenState extends State<WriteReviewScreen> { 
  double rating = 5; 
  final TextEditingController reviewController = TextEditingController(); 
  final TextEditingController titleController = TextEditingController(); 
  final auth = Get.find<AuthController>(); 
  List<String> mediaUrls = []; 
  bool isLoading = false; 
 
  @override 
  void initState() { 
    super.initState(); 
    if (widget.reviewId != null) { 
      loadExistingReview(); 
    } 
  } 
 
  Future<void> loadExistingReview() async { 
    setState(() => isLoading = true); 
    try { 
      final doc = await FirebaseFirestore.instance 
          .collection('reviews') 
          .doc(widget.reviewId) 
          .get(); 
      if (doc.exists) { 
        final data = doc.data()!; 
        setState(() { 
          rating = (data['rating'] ?? 5).toDouble(); 
          titleController.text = data['title'] ?? ""; 
          reviewController.text = data['reviewText'] ?? ''; 
          mediaUrls = List<String>.from(data['mediaUrls'] ?? []); 
        }); 
      } 
    } catch (e) { 
      Get.snackbar("Lỗi", "Không thể tải dữ liệu đánh giá"); 
    } finally { 
      setState(() => isLoading = false); 
    } 
  } 
 
  Future<void> submitReview() async { 
    final user = auth.currentUser; 
    if (user == null) { 
      Get.snackbar("Lỗi", "Bạn phải đăng nhập để viết đánh giá"); 
      return; 
    } 
 
    if (titleController.text.trim().isEmpty) { 
      Get.snackbar("Yêu cầu", "Vui lòng nhập tiêu đề cho đánh giá của bạn", backgroundColor: Colors.redAccent, colorText: Colors.white); 
      return; 
    } 
 
    if (reviewController.text.trim().isEmpty) { 
      Get.snackbar("Yêu cầu", "Vui lòng viết chi tiết về trải nghiệm của bạn", backgroundColor: Colors.redAccent, colorText: Colors.white); 
      return; 
    } 
 
    setState(() => isLoading = true); 
 
    try { 
      final reviewData = { 
        'productId': widget.product.id, 
        'productName': widget.product.title, 
        'productImage': widget.product.thumbnail, 
        'userId': user.id, 
        'userName': "${user.firstName} ${user.lastName}", 
        'rating': rating, 
        'title': titleController.text.trim(), 
        'reviewText': reviewController.text.trim(), 
        'mediaUrls': mediaUrls, 
        'updatedAt': Timestamp.now(), 
        'isApproved': true, 
        'isDeleted': false, 
      }; 
 
      if (widget.reviewId == null) { 
        await FirebaseFirestore.instance.collection('reviews').add({ 
          ...reviewData, 
          'createdAt': Timestamp.now(), 
        }); 
      } else { 
        await FirebaseFirestore.instance 
            .collection('reviews') 
            .doc(widget.reviewId) 
            .update(reviewData); 
      } 
 
      await updateProductRating(); 
 
      if (Get.isRegistered<ProductController>()) Get.find<ProductController>().refreshAllData();
      if (Get.isRegistered<MyStoreController>()) Get.find<MyStoreController>().initData();
 
      Get.back(); 
      Get.snackbar("Thành công", "Đánh giá của bạn đã được gửi thành công", backgroundColor: Colors.green, colorText: Colors.white); 
    } catch (e) { 
      Get.snackbar("Lỗi", "Không thể gửi đánh giá: $e"); 
    } finally { 
      setState(() => isLoading = false); 
    } 
  } 
 
  Future<void> updateProductRating() async { 
    print("=== [DEBUG] BẮT ĐẦU CẬP NHẬT ĐIỂM SẢN PHẨM: ${widget.product.id} ===");
    try {
      final snapshot = await FirebaseFirestore.instance 
          .collection('reviews') 
          .where('productId', isEqualTo: widget.product.id) 
          .where('isApproved', isEqualTo: true) 
          .where('isDeleted', isEqualTo: false) 
          .get(); 
   
      double total = 0; 
      int count = snapshot.docs.length;
      Map<String, int> starCounts = {
        'oneStarCount': 0,
        'twoStarCount': 0,
        'threeStarCount': 0,
        'fourStarCount': 0,
        'fiveStarCount': 0,
      };

      for (var doc in snapshot.docs) {
        double r = (doc['rating'] ?? 0).toDouble();
        total += r;
        
        int star = r.round();
        if (star == 1) starCounts['oneStarCount'] = (starCounts['oneStarCount'] ?? 0) + 1;
        else if (star == 2) starCounts['twoStarCount'] = (starCounts['twoStarCount'] ?? 0) + 1;
        else if (star == 3) starCounts['threeStarCount'] = (starCounts['threeStarCount'] ?? 0) + 1;
        else if (star == 4) starCounts['fourStarCount'] = (starCounts['fourStarCount'] ?? 0) + 1;
        else if (star == 5) starCounts['fiveStarCount'] = (starCounts['fiveStarCount'] ?? 0) + 1;
      } 
   
      final avg = count == 0 ? 0.0 : total / count; 
      
      print("=== [DEBUG] KẾT QUẢ TÍNH TOÁN: Avg=$avg, Count=$count ===");
   
      await FirebaseFirestore.instance 
          .collection('products') 
          .doc(widget.product.id) 
          .set({
            'rating': avg, 
            'ratingCount': count,
            'reviewsCount': count,
            ...starCounts,
          }, SetOptions(merge: true));
      
      print("=== [DEBUG] ĐÃ CẬP NHẬT FIREBASE THÀNH CÔNG ===");
    } catch (e) {
      print("Error updating rating: $e");
    } 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: const Color(0xFFFBFBFD), 
      appBar: AppBar( 
        title: Text(widget.reviewId == null ? "Viết đánh giá" : "Chỉnh sửa đánh giá", style: const TextStyle(color: Color(0xFF1D1D1F), fontWeight: FontWeight.w800, fontSize: 18)), 
        backgroundColor: Colors.white, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Colors.black), 
      ), 
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView( 
              physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(24), 
              child: Column( 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [ 
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                    child: Row( 
                      children: [ 
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildProductImage(widget.product.thumbnail, 70)),
                        ), 
                        const SizedBox(width: 16), 
                        Expanded( 
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(widget.product.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(widget.product.brandName ?? "Thương hiệu", style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
                          ]), 
                        ), 
                      ], 
                    ),
                  ), 
                  const SizedBox(height: 32), 
                  Center( 
                    child: Column(children: [
                      const Text("Trải nghiệm của bạn thế nào?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                      const SizedBox(height: 8),
                      Text(_getRatingText(), style: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.w600, fontSize: 14)),
                    ]), 
                  ), 
                  const SizedBox(height: 16), 
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: List.generate(5, (index) { 
                      final isSelected = index < rating;
                      return GestureDetector( 
                        onTap: () => setState(() => rating = index + 1.0), 
                        child: AnimatedScale(
                          scale: isSelected ? 1.2 : 1.0, duration: const Duration(milliseconds: 200), curve: Curves.easeOutBack,
                          child: Icon(isSelected ? Icons.star_rounded : Icons.star_outline_rounded, size: 54, color: isSelected ? Colors.amber : Colors.grey.shade300),
                        ), 
                      ); 
                    }), 
                  ), 
                  const SizedBox(height: 40), 
                  _buildSectionHeader("Tiêu đề đánh giá"), 
                  const SizedBox(height: 12), 
                  _buildTextField(controller: titleController, hint: "Tóm tắt trải nghiệm của bạn...", maxLines: 1), 
                  const SizedBox(height: 24), 
                  _buildSectionHeader("Nhận xét chi tiết"), 
                  const SizedBox(height: 12), 
                  _buildTextField(controller: reviewController, hint: "Chia sẻ thêm về sản phẩm, chất lượng phục vụ...", maxLines: 5), 
                  const SizedBox(height: 32), 
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildSectionHeader("Hình ảnh minh họa"), Text("${mediaUrls.length}/5", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))]), 
                  const SizedBox(height: 12), 
                  SizedBox( 
                    height: 100, 
                    child: ListView( 
                      scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
                      children: [ 
                        if (mediaUrls.length < 5)
                          GestureDetector( 
                            onTap: _showAddImageDialog, 
                            child: Container( 
                              width: 100, height: 100, 
                              decoration: BoxDecoration(color: Colors.blue.shade50.withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade100, width: 1.5)), 
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_rounded, color: Colors.blue.shade700, size: 32), const SizedBox(height: 4), Text("Thêm ảnh", style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold))]), 
                            ), 
                          ), 
                        const SizedBox(width: 12), 
                        ...mediaUrls.asMap().entries.map((entry) {
                          final index = entry.key; final url = entry.value;
                          return Padding(padding: const EdgeInsets.only(right: 12), child: Stack(children: [
                            Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))]),
                            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _buildProductImage(url, 100))), 
                            Positioned(right: 6, top: 6, child: GestureDetector(onTap: () => setState(() => mediaUrls.removeAt(index)), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, color: Colors.white, size: 14)))), 
                          ]));
                        }), 
                      ], 
                    ), 
                  ), 
                  const SizedBox(height: 48), 
                  Container(
                    width: double.infinity, height: 58, 
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
                    child: ElevatedButton(onPressed: submitReview, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), 
                    child: Text(widget.reviewId == null ? "Gửi đánh giá" : "Cập nhật đánh giá", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5))), 
                  ), 
                  const SizedBox(height: 32), 
                ], 
              ), 
            ), 
    ); 
  } 
 
  String _getRatingText() {
    switch (rating.toInt()) {
      case 1: return "Rất tệ 😞";
      case 2: return "Tệ ☹️";
      case 3: return "Bình thường 😐";
      case 4: return "Tốt 🙂";
      case 5: return "Rất tốt 😍";
      default: return "";
    }
  }
 
  Widget _buildSectionHeader(String title) => Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1D1D1F)));
 
  Widget _buildTextField({required TextEditingController controller, required String hint, required int maxLines}) {
    return TextField( 
      controller: controller, maxLines: maxLines, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)), 
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)), 
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5)), 
      ), 
    );
  }
 
  void _showAddImageDialog() { 
    final urlController = TextEditingController(); 
    showDialog(context: context, builder: (_) => AlertDialog( 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), title: const Text("Thêm liên kết ảnh", style: TextStyle(fontWeight: FontWeight.bold)), 
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Dán đường dẫn ảnh từ internet để minh họa cho đánh giá của bạn.", style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 16),
        TextField(controller: urlController, autofocus: true, decoration: InputDecoration(hintText: "https://example.com/image.jpg", filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
      ]), 
      actions: [ 
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy", style: TextStyle(color: Colors.grey.shade600))), 
        Container(margin: const EdgeInsets.only(right: 8, bottom: 8), child: ElevatedButton(onPressed: () { if (urlController.text.trim().isNotEmpty) setState(() => mediaUrls.add(urlController.text.trim())); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Xác nhận", style: TextStyle(color: Colors.white)))), 
      ], 
    )); 
  } 

  Widget _buildProductImage(String url, double size) {
    if (url.startsWith('assets/')) return Image.asset(url, width: size, height: size, fit: BoxFit.cover);
    return Image.network(url, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: size, height: size, color: Colors.grey.shade100, child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey))); 
  }
}