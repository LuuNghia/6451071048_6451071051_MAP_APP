import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import '../../data/models/product_model.dart'; 
import '../../controller/login_controller.dart'; 
 
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
      Get.snackbar("Error", "Could not load review data"); 
    } finally { 
      setState(() => isLoading = false); 
    } 
  } 
 
  Future<void> submitReview() async { 
    final user = auth.currentUser; 
    if (user == null) { 
      Get.snackbar("Error", "You must be logged in to write a review"); 
      return; 
    } 
 
    // Validation 
    if (titleController.text.trim().isEmpty) { 
      Get.snackbar( 
        "Required", 
        "Please enter a headline for your review", 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white, 
      ); 
      return; 
    } 
 
    if (reviewController.text.trim().isEmpty) { 
      Get.snackbar( 
        "Required", 
        "Please write some details about your experience", 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white, 
      ); 
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
        'isApproved': false, // Cần admin duyệt lại khi sửa hoặc tạo mới 
        'isDeleted': false, 
      }; 
 
      if (widget.reviewId == null) { 
        // Thêm mới 
        await FirebaseFirestore.instance.collection('reviews').add({ 
          ...reviewData, 
          'createdAt': Timestamp.now(), 
        }); 
      } else { 
        // Cập nhật 
        await FirebaseFirestore.instance 
            .collection('reviews') 
            .doc(widget.reviewId) 
            .update(reviewData); 
      } 
 
      // Lưu ý: updateProductRating chỉ tính toán dựa trên các review đã IS_APPROVED = TRUE ;
      await updateProductRating(); 
 
      Get.back(); 
      Get.snackbar( 
        "Success", 
        "Your review has been submitted for approval", 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.green, 
        colorText: Colors.white, 
      ); 
    } catch (e) { 
      Get.snackbar("Error", e.toString()); 
    } finally { 
      setState(() => isLoading = false); 
    } 
  } 
 
  Future<void> updateProductRating() async { 
    final snapshot = await FirebaseFirestore.instance
        .collection('reviews') 
        .where('productId', isEqualTo: widget.product.id) 
        .where('isApproved', isEqualTo: true) 
        .where('isDeleted', isEqualTo: false) 
        .get(); 
 
    double total = 0; 
    for (var doc in snapshot.docs) { 
      total += (doc['rating'] ?? 0).toDouble(); 
    } 
 
    final count = snapshot.docs.length; 
    final avg = count == 0 ? 0.0 : total / count; 
 
    await FirebaseFirestore.instance 
        .collection('products') 
        .doc(widget.product.id) 
        .update({'rating': avg, 'ratingCount': count}); 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: Colors.white, 
      appBar: AppBar( 
        title: Text( 
          widget.reviewId == null ? "Write Review" : "Edit Review", 
          style: const TextStyle( 
            color: Colors.black, 
            fontWeight: FontWeight.bold, 
          ), 
        ), 
        backgroundColor: Colors.white, 
        elevation: 0.5, 
        iconTheme: const IconThemeData(color: Colors.black), 
      ), 
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView( 
              padding: const EdgeInsets.all(20), 
              child: Column( 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [ 
                  /// PRODUCT INFO SUMMARY 
                  Row( 
                    children: [ 
                      ClipRRect( 
                        borderRadius: BorderRadius.circular(8), 
                        child: Image.network( 
                          widget.product.thumbnail,
                            width: 60, 
                          height: 60, 
                          fit: BoxFit.cover, 
                        ), 
                      ), 
                      const SizedBox(width: 12), 
                      Expanded( 
                        child: Text( 
                          widget.product.title, 
                          style: const TextStyle( 
                            fontSize: 16, 
                            fontWeight: FontWeight.w500, 
                          ), 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis, 
                        ), 
                      ), 
                    ], 
                  ), 
 
                  const Padding( 
                    padding: EdgeInsets.symmetric(vertical: 20), 
                    child: Divider(), 
                  ), 
 
                  /// STAR RATING PICKER 
                  const Center( 
                    child: Text( 
                      "How would you rate it?", 
                      style: TextStyle( 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                      ), 
                    ), 
                  ), 
                  const SizedBox(height: 8), 
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: List.generate(5, (index) { 
                      return GestureDetector( 
                        onTap: () => setState(() => rating = index + 1.0), 
                        child: Icon( 
                          index < rating 
                              ? Icons.star_rounded 
                              : Icons.star_outline_rounded, 
                          size: 48, 
                          color: Colors.amber, 
                        ), 
                      );
                        }), 
                  ), 
 
                  const SizedBox(height: 30), 
 
                  /// INPUT FIELDS 
                  const Text( 
                    "Add a headline", 
                    style: TextStyle(fontWeight: FontWeight.bold), 
                  ), 
                  const SizedBox(height: 8), 
                  TextField( 
                    controller: titleController, 
                    decoration: InputDecoration( 
                      hintText: "What's most important to know?", 
                      filled: true, 
                      fillColor: Colors.grey.shade50, 
                      border: OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(12), 
                        borderSide: BorderSide(color: Colors.grey.shade300), 
                      ), 
                      enabledBorder: OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(12), 
                        borderSide: BorderSide(color: Colors.grey.shade200), 
                      ), 
                    ), 
                  ), 
 
                  const SizedBox(height: 20), 
 
                  const Text( 
                    "Write your review", 
                    style: TextStyle(fontWeight: FontWeight.bold), 
                  ), 
                  const SizedBox(height: 8), 
                  TextField( 
                    controller: reviewController, 
                    maxLines: 5, 
                    decoration: InputDecoration( 
                      hintText: "What did you like or dislike?", 
                      filled: true, 
                      fillColor: Colors.grey.shade50, 
                      border: OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(12), 
                        borderSide: BorderSide(color: Colors.grey.shade300), 
                      ), 
                      enabledBorder: OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(12), 
                        borderSide: BorderSide(color: Colors.grey.shade200), 
                      ), 
                    ), 
                  ), 
 
                  const SizedBox(height: 25), 
 
                  /// MEDIA SECTION 
                  const Text( 
                    "Add Photos", 
                    style: TextStyle(fontWeight: FontWeight.bold), 
                  ), 
                  const SizedBox(height: 10), 
                  SizedBox( 
                    height: 90, 
                    child: ListView( 
                      scrollDirection: Axis.horizontal, 
                      children: [ 
                        // Button to add 
                        GestureDetector( 
                          onTap: _showAddImageDialog, 
                          child: Container( 
                            width: 90, 
                            height: 90, 
                            decoration: BoxDecoration( 
                              color: Colors.grey.shade100, 
                              borderRadius: BorderRadius.circular(12), 
                              border: Border.all( 
                                color: Colors.grey.shade300, 
                                style: BorderStyle.solid, 
                              ), 
                            ), 
                            child: const Icon( 
                              Icons.add_a_photo_outlined, 
                              color: Colors.grey, 
                            ), 
                          ), 
                        ), 
                        const SizedBox(width: 10), 
                        // List of images 
                        ...mediaUrls.map( 
                          (url) => Padding( 
                            padding: const EdgeInsets.only(right: 10), 
                            child: Stack( 
                              children: [ 
                                ClipRRect( 
                                  borderRadius: BorderRadius.circular(12), 
                                  child: Image.network( 
                                    url, 
                                    width: 90, 
                                    height: 90, 
                                    fit: BoxFit.cover, 
                                  ), 
                                ), 
                                Positioned( 
                                  right: 4, 
                                  top: 4, 
                                  child: GestureDetector( 
                                    onTap: () => 
                                        setState(() => mediaUrls.remove(url)), 
                                    child: Container( 
                                      decoration: const BoxDecoration( 
                                        color: Colors.black54, 
                                        shape: BoxShape.circle, 
                                      ), 
                                      child: const Icon( 
                                        Icons.close, 
                                        color: Colors.white, 
                                        size: 18, 
                                      ), 
                                    ), 
                                  ), 
                                ), 
                              ], 
                            ), 
                          ), 
                        ), 
                      ], 
                    ), 
                  ), 
 
                  const SizedBox(height: 40), 
 
                  /// SUBMIT BUTTON 
                  SizedBox( 
                    width: double.infinity, 
                    height: 55, 
                    child: ElevatedButton( 
                      onPressed: submitReview, 
                      style: ElevatedButton.styleFrom( 
                        backgroundColor: Colors.black, 
                        foregroundColor: Colors.white, 
                        shape: RoundedRectangleBorder( 
                          borderRadius: BorderRadius.circular(15), 
                        ), 
                        elevation: 0, 
    ), 
                      child: Text( 
                        widget.reviewId == null 
                            ? "Submit Review" 
                            : "Update Review", 
                        style: const TextStyle( 
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                        ), 
                      ), 
                    ), 
                  ), 
                  const SizedBox(height: 20), 
                ], 
              ), 
            ), 
    ); 
  } 
 
  void _showAddImageDialog() { 
    final urlController = TextEditingController(); 
    showDialog( 
      context: context, 
      builder: (_) => AlertDialog( 
        shape: RoundedRectangleBorder(borderRadius: 
BorderRadius.circular(20)), 
        title: const Text("Add Image Link"), 
        content: TextField( 
          controller: urlController, 
          autofocus: true, 
          decoration: const InputDecoration( 
            hintText: "Paste image URL here...", 
            border: UnderlineInputBorder(), 
          ), 
        ), 
        actions: [ 
          TextButton( 
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel"), 
          ), 
          ElevatedButton( 
            onPressed: () { 
              if (urlController.text.trim().isNotEmpty) { 
                setState(() => 
mediaUrls.add(urlController.text.trim())); 
              } 
              Navigator.pop(context); 
            }, 
            child: const Text("Add"), 
          ),
            ], 
      ), 
    ); 
  } 
} 