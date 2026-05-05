import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart'; 
import 'package:timeago/timeago.dart' as timeago; 
 
class ReviewRatingScreen extends StatelessWidget { 
  final String productId; 
  final double rating; 
  final int reviewCount; 
 
  const ReviewRatingScreen({ 
    super.key, 
    required this.productId, 
    required this.rating, 
    required this.reviewCount, 
  }); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: const Color( 
        0xFFF8F9FA, 
      ), // Nền xám rất nhạt cực kỳ sang trọng 
      appBar: AppBar( 
        title: const Text( 
          'Đánh giá sản phẩm', 
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
       body: SingleChildScrollView( 
        physics: const BouncingScrollPhysics(), 
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [ 
            /// 1. TỔNG QUAN RATING (NHẤT QUÁN VỚI CARD CỦA HOME) 
            Container( 
              margin: const EdgeInsets.all(16), 
              padding: const EdgeInsets.all(24), 
              decoration: BoxDecoration( 
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [ 
                  BoxShadow( 
                    color: Colors.black.withOpacity(0.04), 
                    blurRadius: 20, 
                    offset: const Offset(0, 10), 
                  ), 
                ], 
              ), 
              child: _buildRatingOverview(), 
            ), 
 
            const Padding( 
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), 
              child: Text( 
                "Nhận xét từ khách hàng", 
                style: TextStyle( 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF2D2D2D), 
                ), 
              ), 
            ), 
 
            /// 2. DANH SÁCH REVIEW 
            Padding( 
              padding: const EdgeInsets.symmetric(horizontal: 16), 
              child: _buildReviewList(), 
            ), 
 
            const SizedBox(height: 30), 
          ], 
        ), 
      ), 
    ); 
  } 
 
  // ================= OVERVIEW SECTION ================= 
  Widget _buildRatingOverview() { 
    return Row( 
      children: [ 
        // Cột trái: Điểm trung bình 
        Expanded( 
          flex: 2, 
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [ 
              Text( 
                rating.toStringAsFixed(1), 
                style: const TextStyle( 
                  fontSize: 52, 
                  fontWeight: FontWeight.w800, 
                  color: Color(0xFF2D3436), 
                  letterSpacing: -1, 
                ), 
              ), 
              Row( 
                mainAxisAlignment: MainAxisAlignment.center, 
                children: List.generate( 
                  5, 
                  (index) => Icon( 
                    index < rating.round() 
                        ? Icons.star_rounded 
                        : Icons.star_outline_rounded, 
                    size: 20, 
                    color: Colors.amber, 
                  ), 
                ), 
              ), 
              const SizedBox(height: 8), 
              Text( 
                '$reviewCount đánh giá', 
                style: TextStyle( 
                  color: Colors.grey.shade500, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w500, 
                ), 
              ), 
            ], 
          ), 
        ), 
 
        // Đường kẻ dọc 
        Container( 
          height: 80, 
          width: 1, 
          color: Colors.grey.shade100, 
          margin: const EdgeInsets.symmetric(horizontal: 15),
            Widget _buildRatingOverview() { 
return Row( 
      children: [ 
        // Cột trái: Điểm trung bình 
        Expanded( 
          flex: 2, 
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [ 
              Text( 
                rating.toStringAsFixed(1), 
                style: const TextStyle( 
                  fontSize: 52, 
                  fontWeight: FontWeight.w800, 
                  color: Color(0xFF2D3436), 
                  letterSpacing: -1, 
                ), 
              ), 
              Row( 
                mainAxisAlignment: MainAxisAlignment.center, 
                children: List.generate( 
                  5, 
                  (index) => Icon( 
                    index < rating.round() 
                        ? Icons.star_rounded 
                        : Icons.star_outline_rounded, 
                    size: 20, 
                    color: Colors.amber, 
                  ), 
                ), 
              ), 
              const SizedBox(height: 8), 
              Text( 
                '$reviewCount đánh giá', 
                style: TextStyle( 
                  color: Colors.grey.shade500, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w500, 
                ), 
              ), 
            ], 
          ), 
        ), 
 
        // Đường kẻ dọc 
        Container( 
          height: 80, 
          width: 1, 
          color: Colors.grey.shade100, 
          margin: const EdgeInsets.symmetric(horizontal: 15),
            .orderBy('createdAt', descending: true) 
          .snapshots(), 
      builder: (context, snapshot) { 
        if (snapshot.connectionState == ConnectionState.waiting) { 
          return const Center( 
            child: Padding( 
              padding: EdgeInsets.all(40), 
              child: CircularProgressIndicator(), 
            ), 
          ); 
        } 
 
        final docs = snapshot.data?.docs ?? []; 
 
        if (docs.isEmpty) { 
          return Center( 
            child: Column( 
              children: [ 
                const SizedBox(height: 60), 
                Container( 
                  padding: const EdgeInsets.all(20), 
                  decoration: BoxDecoration( 
                    color: Colors.white, 
                    shape: BoxShape.circle, 
                    boxShadow: [ 
                      BoxShadow( 
                        color: Colors.black.withOpacity(0.03), 
                        blurRadius: 10, 
                      ), 
                    ], 
                  ), 
                  child: Icon( 
                    Icons.rate_review_outlined, 
                    size: 50, 
                    color: Colors.grey.shade300, 
                  ), 
                ), 
                const SizedBox(height: 16), 
                Text( 
                  "Chưa có đánh giá nào.\nHãy là người đầu tiên nhận xét!", 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: Colors.grey.shade500, height: 1.5), 
                ), 
              ], 
            ), 
          ); 
        }
          .orderBy('createdAt', descending: true) 
          .snapshots(), 
      builder: (context, snapshot) { 
        if (snapshot.connectionState == ConnectionState.waiting) { 
          return const Center( 
            child: Padding( 
              padding: EdgeInsets.all(40), 
              child: CircularProgressIndicator(), 
            ), 
          ); 
        } 
 
        final docs = snapshot.data?.docs ?? []; 
 
        if (docs.isEmpty) { 
          return Center( 
            child: Column( 
              children: [ 
                const SizedBox(height: 60), 
                Container( 
                  padding: const EdgeInsets.all(20), 
                  decoration: BoxDecoration( 
                    color: Colors.white, 
                    shape: BoxShape.circle, 
                    boxShadow: [ 
                      BoxShadow( 
                        color: Colors.black.withOpacity(0.03), 
                        blurRadius: 10, 
                      ), 
                    ], 
                  ), 
                  child: Icon( 
                    Icons.rate_review_outlined, 
                    size: 50, 
                    color: Colors.grey.shade300, 
                  ), 
                ), 
                const SizedBox(height: 16), 
                Text( 
                  "Chưa có đánh giá nào.\nHãy là người đầu tiên nhận xét!", 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: Colors.grey.shade500, height: 1.5), 
                ), 
              ], 
            ), 
          ); 
        }
         '$star', 
            style: const TextStyle( 
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              color: Colors.black54, 
            ), 
          ), 
        ), 
        const SizedBox(width: 4), 
        const Icon(Icons.star_rounded, size: 14, color: Colors.amber), 
        const SizedBox(width: 8), 
        Expanded( 
          child: Container( 
            height: 6, 
            decoration: BoxDecoration( 
              borderRadius: BorderRadius.circular(10), 
              color: Colors.grey.shade100, 
            ), 
            child: FractionallySizedBox( 
              alignment: Alignment.centerLeft, 
              widthFactor: value, 
              child: Container( 
                decoration: BoxDecoration( 
                  borderRadius: BorderRadius.circular(10), 
                  gradient: LinearGradient( 
                    colors: [Colors.amber, Colors.amber.shade300], 
                  ), 
                ), 
              ), 
            ), 
          ), 
        ), 
      ], 
    ); 
  } 
} 
 
// ================= COMPONENT: REVIEW ITEM ================= 
class _ReviewItem extends StatelessWidget { 
  final String reviewId; 
  final bool isOwner; 
  final bool isApproved; 
  final String userName; 
  final String title; 
  final double rating; 
  final String reviewText; 
  final List<String> mediaUrls; 
  final DateTime createdAt; 
  final String? userImage; 
   const _ReviewItem({ 
    required this.reviewId, 
    required this.isOwner, 
    required this.isApproved, 
    required this.title, 
    required this.userName, 
    required this.rating, 
    required this.reviewText, 
    required this.createdAt, 
    required this.mediaUrls, 
    this.userImage, 
  }); 
 
  @override 
  Widget build(BuildContext context) { 
    return Container( 
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration( 
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [ 
          BoxShadow( 
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 15, 
            offset: const Offset(0, 5), 
          ), 
        ], 
      ), 
      child: Column( 
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [ 
          /// HEADER 
          Row( 
            children: [ 
              Container( 
                decoration: BoxDecoration( 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.blue.shade50, width: 
2), 
                ), 
                child: CircleAvatar( 
                  radius: 22, 
                  backgroundColor: Colors.blue.shade50, 
                  backgroundImage: userImage != null 
                      ? NetworkImage(userImage!) 
                      : null, 
                  child: userImage == null 
                      ? Icon(Icons.person, color: Colors.blue.shade200) 
                      : null, 
                ), 

), 
              const SizedBox(width: 12), 
              Expanded( 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [ 
                    Text( 
                      userName, 
                      style: const TextStyle( 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16, 
                      ), 
                    ), 
                    Text( 
                      timeago.format(createdAt), 
                      style: TextStyle( 
                        fontSize: 12, 
                        color: Colors.grey.shade400, 
                      ), 
                    ), 
                  ], 
                ), 
              ), 
              if (isOwner) 
                IconButton( 
                  onPressed: () => _confirmDelete(context), 
                  icon: Icon( 
                    Icons.delete_outline_rounded, 
                    color: Colors.red.shade300, 
                    size: 22, 
                  ), 
                ), 
            ], 
          ), 
 
          const SizedBox(height: 16), 
 
          /// RATING 
          Row( 
            children: List.generate( 
              5, 
              (index) => Icon( 
                index < rating 
                    ? Icons.star_rounded 
                    : Icons.star_outline_rounded, 
                size: 18, 
                color: Colors.amber, 
              ), 
            ), 
          ),
           const SizedBox(height: 12), 
 
          /// CONTENT 
          if (title.isNotEmpty) 
            Padding( 
              padding: const EdgeInsets.only(bottom: 6), 
              child: Text( 
                title, 
                style: const TextStyle( 
                  fontWeight: FontWeight.w700, 
                  fontSize: 16, 
                  color: Color(0xFF2D3436), 
                ), 
              ), 
            ), 
          Text( 
            reviewText, 
            style: TextStyle( 
              height: 1.6, 
              color: Colors.grey.shade700, 
              fontSize: 14, 
            ), 
          ), 
 
          const SizedBox(height: 16), 
 
          /// MEDIA GRID 
          if (mediaUrls.isNotEmpty) 
            SizedBox( 
              height: 100, 
              child: ListView.separated( 
                scrollDirection: Axis.horizontal, 
                physics: const BouncingScrollPhysics(), 
                itemCount: mediaUrls.length, 
                separatorBuilder: (_, __) => const SizedBox(width: 12), 
                itemBuilder: (context, index) { 
                  return ClipRRect( 
                    borderRadius: BorderRadius.circular(12), 
                    child: Image.network( 
                      mediaUrls[index], 
                      width: 100, 
                      height: 100, 
                      fit: BoxFit.cover, 
                    ), 
                  ); 
                }, 
              ), 
            ),
             /// FOOTER 
          const SizedBox(height: 16), 
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [ 
              if (isOwner && !isApproved) 
                Container( 
                  padding: const EdgeInsets.symmetric( 
                    horizontal: 12, 
                    vertical: 6, 
                  ), 
                  decoration: BoxDecoration( 
                    color: Colors.orange.shade50, 
                    borderRadius: BorderRadius.circular(12), 
                  ), 
                  child: const Text( 
                    "⏳ Đang chờ duyệt", 
                    style: TextStyle( 
                      color: Colors.orange, 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                    ), 
                  ), 
                ) 
              else 
                const SizedBox(), 
 
              Material( 
                color: Colors.transparent, 
                child: InkWell( 
                  onTap: () {}, 
                  borderRadius: BorderRadius.circular(8), 
                  child: Padding( 
                    padding: const EdgeInsets.symmetric( 
                      horizontal: 8, 
                      vertical: 4, 
                    ), 
                    child: Row( 
                      children: [ 
                        Icon( 
                          Icons.thumb_up_alt_outlined, 
                          size: 16, 
                          color: Colors.grey.shade500, 
                        ), 
                        const SizedBox(width: 6), 
                        Text( 
                          "Hữu ích", 
                          style: TextStyle( 
                            color: Colors.grey.shade500, 
                            fontSize: 13, fontWeight: FontWeight.w500, 
                          ), 
                        ), 
                      ], 
                    ), 
                  ), 
                ), 
              ), 
            ], 
          ), 
        ], 
      ), 
    ); 
  } 
 
  void _confirmDelete(BuildContext context) { 
    showDialog( 
      context: context, 
      builder: (context) => AlertDialog( 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
        title: const Text("Xóa đánh giá?"), 
        content: const Text("Bạn có chắc chắn muốn xóa phản hồi này không?"), 
        actions: [ 
          TextButton( 
            onPressed: () => Navigator.pop(context), 
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)), 
          ), 
          ElevatedButton( 
            onPressed: () async { 
              await FirebaseFirestore.instance 
                  .collection('reviews') 
                  .doc(reviewId) 
                  .update({'isDeleted': true, 'updatedAt': Timestamp.now()}); 
              Navigator.pop(context); 
            }, 
            style: ElevatedButton.styleFrom( 
              backgroundColor: Colors.redAccent, 
              shape: RoundedRectangleBorder( 
                borderRadius: BorderRadius.circular(10), 
              ), 
              elevation: 0, 
            ), 
            child: const Text("Xác nhận xóa"), 
          ), 
        ], 
      ), 
   ); 
  } 
} 