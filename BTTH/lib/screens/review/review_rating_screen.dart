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
      backgroundColor: const Color(0xFFF8F9FA), 
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
 
  Widget _buildRatingOverview() { 
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('products').doc(productId).snapshots(),
      builder: (context, productSnapshot) {
        // Fallback to constructor values if snapshot hasn't loaded or product doesn't exist
        double displayRating = rating;
        int displayReviewCount = reviewCount;

        if (productSnapshot.hasData && productSnapshot.data!.exists) {
          final data = productSnapshot.data!.data() as Map<String, dynamic>;
          displayRating = (data['rating'] ?? 0).toDouble();
          displayReviewCount = data['ratingCount'] ?? 0;
        }

        return IntrinsicHeight(
          child: Row( 
            children: [ 
              Expanded( 
                flex: 2, 
                child: Column( 
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [ 
                    Text( 
                      displayRating.toStringAsFixed(1), 
                      style: TextStyle( 
                        fontSize: 58, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.blue.shade900, 
                        letterSpacing: -2, 
                        height: 1,
                      ), 
                    ), 
                    const SizedBox(height: 8),
                    Row( 
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: List.generate( 
                        5, 
                        (index) => Icon( 
                          index < displayRating.round() 
                              ? Icons.star_rounded 
                              : Icons.star_outline_rounded, 
                          size: 22, 
                          color: Colors.amber, 
                        ), 
                      ), 
                    ), 
                    const SizedBox(height: 8), 
                    Text( 
                      '$displayReviewCount đánh giá', 
                      style: TextStyle( 
                        color: Colors.grey.shade600, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600, 
                      ), 
                    ), 
                  ], 
                ), 
              ), 
       
              VerticalDivider(
                width: 40,
                thickness: 1.5,
                color: Colors.grey.shade100,
                indent: 10,
                endIndent: 10,
              ),
       
              Expanded( 
                flex: 3, 
                child: StreamBuilder<QuerySnapshot>( 
                  stream: FirebaseFirestore.instance 
                      .collection('reviews') 
                      .where('productId', isEqualTo: productId) 
                      .where('isDeleted', isEqualTo: false) 
                      .snapshots(), 
                  builder: (context, snapshot) { 
                    if (!snapshot.hasData) return const SizedBox(); 
       
                    final docs = snapshot.data!.docs; 
                    final total = docs.length; 
                    Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0}; 
       
                    for (var doc in docs) { 
                      int r = (doc['rating'] ?? 0).toInt(); 
                      if (r >= 1 && r <= 5) counts[star_key(r)] = (counts[star_key(r)] ?? 0) + 1; 
                    } 
       
                    return Column( 
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [5, 4, 3, 2, 1].map((star) { 
                        return Padding( 
                          padding: const EdgeInsets.symmetric(vertical: 3), 
                          child: _StarProgressRow( 
                            star: star, 
                            value: total == 0 ? 0 : (counts[star]! / total), 
                          ), 
                        ); 
                      }).toList(), 
                    ); 
                  }, 
                ), 
              ), 
            ], 
          ),
        );
      },
    ); 
  } 

  int star_key(int r) => r.clamp(1, 5);
 
  Widget _buildReviewList() { 
    final currentUserId = FirebaseAuth.instance.currentUser?.uid; 
 
    return StreamBuilder<QuerySnapshot>( 
      stream: FirebaseFirestore.instance 
          .collection('reviews') 
          .where('productId', isEqualTo: productId) 
          .where('isDeleted', isEqualTo: false) 
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
        return ListView.separated( 
          shrinkWrap: true, 
          padding: const EdgeInsets.only(top: 10), 
          physics: const NeverScrollableScrollPhysics(), 
          itemCount: docs.length, 
          separatorBuilder: (context, index) => const SizedBox(height: 16), 
          itemBuilder: (context, index) { 
            final data = docs[index].data() as Map<String, dynamic>; 
            final isApproved = data['isApproved'] ?? false; 
            final userId = data['userId']; 
            final isOwner = userId == currentUserId; 
 
            if (!isApproved && !isOwner) { 
              return const SizedBox.shrink(); 
            } 
 
            return _ReviewItem( 
              reviewId: docs[index].id, 
              isOwner: isOwner, 
              isApproved: isApproved, 
              userName: data['userName'] ?? 'Người dùng', 
              title: data['title'] ?? '', 
              rating: (data['rating'] ?? 0).toDouble(), 
              reviewText: data['reviewText'] ?? '', 
              mediaUrls: List<String>.from(data['mediaUrls'] ?? []), 
              createdAt: (data['createdAt'] as Timestamp).toDate(), 
              userImage: data['userProfileImage'], 
            ); 
          }, 
        ); 
      }, 
    ); 
  } 
} 
 
class _StarProgressRow extends StatelessWidget { 
  final int star; 
  final double value; 
 
  const _StarProgressRow({required this.star, required this.value}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Row( 
      children: [ 
        SizedBox( 
          width: 10, 
          child: Text( 
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
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration( 
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [ 
          BoxShadow( 
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 20, 
            offset: const Offset(0, 8), 
          ), 
        ], 
        border: Border.all(color: Colors.grey.shade50),
      ), 
      child: Column( 
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [ 
          Row( 
            children: [ 
              Container( 
                decoration: BoxDecoration( 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.blue.shade100, width: 2), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ), 
                child: CircleAvatar( 
                  radius: 24, 
                  backgroundColor: Colors.blue.shade50, 
                  backgroundImage: userImage != null 
                      ? NetworkImage(userImage!) 
                      : null, 
                  child: userImage == null 
                      ? Icon(Icons.person_rounded, color: Colors.blue.shade300, size: 28) 
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
                        fontWeight: FontWeight.w800, 
                        fontSize: 16, 
                        color: Color(0xFF2D3436),
                      ), 
                    ), 
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text( 
                          timeago.format(createdAt, locale: 'vi'), 
                          style: TextStyle( 
                            fontSize: 12, 
                            color: Colors.grey.shade500, 
                            fontWeight: FontWeight.w500,
                          ), 
                        ),
                      ],
                    ), 
                  ], 
                ), 
              ), 
              if (isOwner) 
                _buildActionMenu(context)
            ], 
          ), 
 
          const SizedBox(height: 18), 
 
          Row( 
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: List.generate( 
                    5, 
                    (index) => Icon( 
                      index < rating 
                          ? Icons.star_rounded 
                          : Icons.star_outline_rounded, 
                      size: 14, 
                      color: Colors.amber, 
                    ), 
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (title.isNotEmpty) 
                Expanded(
                  child: Text( 
                    title, 
                    style: const TextStyle( 
                      fontWeight: FontWeight.w800, 
                      fontSize: 15, 
                      color: Color(0xFF2D3436), 
                    ), 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ), 
            ],
          ), 
 
          const SizedBox(height: 12), 
 
          Text( 
            reviewText, 
            style: TextStyle( 
              height: 1.6, 
              color: Colors.grey.shade700, 
              fontSize: 14, 
              fontWeight: FontWeight.w400,
            ), 
          ), 
 
          const SizedBox(height: 18), 
 
          if (mediaUrls.isNotEmpty) 
            SizedBox( 
              height: 90, 
              child: ListView.separated( 
                scrollDirection: Axis.horizontal, 
                physics: const BouncingScrollPhysics(), 
                itemCount: mediaUrls.length, 
                separatorBuilder: (_, __) => const SizedBox(width: 12), 
                itemBuilder: (context, index) { 
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect( 
                      borderRadius: BorderRadius.circular(16), 
                      child: Image.network( 
                        mediaUrls[index], 
                        width: 90, 
                        height: 90, 
                        fit: BoxFit.cover, 
                      ), 
                    ),
                  ); 
                }, 
              ), 
            ), 
 
          const SizedBox(height: 20), 
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [ 
              if (isOwner && !isApproved) 
                Container( 
                  padding: const EdgeInsets.symmetric( 
                    horizontal: 14, 
                    vertical: 8, 
                  ), 
                  decoration: BoxDecoration( 
                    color: Colors.orange.shade50, 
                    borderRadius: BorderRadius.circular(12), 
                    border: Border.all(color: Colors.orange.shade100),
                  ), 
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending_actions_rounded, size: 14, color: Colors.orange),
                      const SizedBox(width: 6),
                      const Text( 
                        "Đang chờ duyệt", 
                        style: TextStyle( 
                          color: Colors.orange, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold, 
                        ), 
                      ),
                    ],
                  ), 
                ) 
              else 
                const SizedBox(), 
 
              _buildHelpfulButton(),
            ], 
          ), 
        ], 
      ), 
    ); 
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              SizedBox(width: 10),
              Text("Xóa đánh giá", style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'delete') _confirmDelete(context);
      },
    );
  }

  Widget _buildHelpfulButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell( 
          onTap: () {}, 
          borderRadius: BorderRadius.circular(12), 
          child: Padding( 
            padding: const EdgeInsets.symmetric( 
              horizontal: 14, 
              vertical: 8, 
            ), 
            child: Row( 
              children: [ 
                Icon( 
                  Icons.thumb_up_alt_rounded, 
                  size: 16, 
                  color: Colors.grey.shade600, 
                ), 
                const SizedBox(width: 8), 
                Text( 
                  "Hữu ích", 
                  style: TextStyle( 
                    color: Colors.grey.shade700, 
                    fontSize: 13,
                    fontWeight: FontWeight.w600, 
                  ), 
                ), 
              ], 
            ), 
          ), 
        ),
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