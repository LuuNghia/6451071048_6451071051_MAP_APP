import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/product_review_model.dart'; 
 
class ReviewService { 
  final _db = FirebaseFirestore.instance; 
  final String collection = "reviews"; 
 
  /// APPROVE REVIEW 
  Future<void> approveAndUpdateProduct(ReviewModel review) async { 
    final reviewRef = _db.collection("reviews").doc(review.id); 
    final productRef = _db.collection("products").doc(review.productId); 
 
    await _db.runTransaction((transaction) async { 
      final reviewSnap = await transaction.get(reviewRef); 
      final productSnap = await transaction.get(productRef); 
 
      if (!reviewSnap.exists || !productSnap.exists) { 
        throw Exception("Review or Product not found"); 
      } 
 
      final reviewData = reviewSnap.data() as Map<String, dynamic>; 
 
      /// Nếu đã approve rồi thì không làm nữa 
      if (reviewData['isApproved'] == true) return; 
 
      final productData = productSnap.data() as Map<String, dynamic>; 
 
      double currentRating = (productData['rating'] ?? 0).toDouble(); 
      int ratingCount = productData['ratingCount'] ?? 0; 
      int reviewsCount = productData['reviewsCount'] ?? 0; 
 
      int fiveStar = productData['fiveStarCount'] ?? 0; 
      int fourStar = productData['fourStarCount'] ?? 0; 
      int threeStar = productData['threeStarCount'] ?? 0; 
      int twoStar = productData['twoStarCount'] ?? 0; 
      int oneStar = productData['oneStarCount'] ?? 0; double newRatingValue = review.rating; 
 
      /// Update số sao tương ứng 
      switch (newRatingValue.round()) { 
        case 5: 
          fiveStar++; 
          break; 
        case 4: 
          fourStar++; 
          break; 
        case 3: 
          threeStar++; 
          break; 
        case 2: 
          twoStar++; 
          break; 
        case 1: 
          oneStar++; 
          break; 
      } 
 
      /// Tính lại rating trung bình 
      double newAverage = 
          ((currentRating * ratingCount) + newRatingValue) / (ratingCount + 1); 
 
      /// 1. Update review 
      transaction.update(reviewRef, { 
        "isApproved": true, 
        "updatedAt": FieldValue.serverTimestamp(), 
      }); 
 
      /// 2. Update product 
      transaction.update(productRef, { 
        "rating": double.parse(newAverage.toStringAsFixed(1)), 
        "ratingCount": ratingCount + 1, 
        "reviewsCount": reviewsCount + 1, 
        "fiveStarCount": fiveStar, 
        "fourStarCount": fourStar, 
        "threeStarCount": threeStar, 
        "twoStarCount": twoStar, 
        "oneStarCount": oneStar, 
        "updatedAt": FieldValue.serverTimestamp(), 
      }); 
    }); 
  } 
 
  /// DELETE REVIEW AND UPDATE PRODUCT STATS
  Future<void> delete(String id) async {
    final reviewRef = _db.collection(collection).doc(id);

    await _db.runTransaction((transaction) async {
      final reviewSnap = await transaction.get(reviewRef);
      if (!reviewSnap.exists) return;

      final reviewData = reviewSnap.data() as Map<String, dynamic>;
      final bool wasApproved = reviewData['isApproved'] ?? false;
      final String productId = reviewData['productId'] ?? "";
      final double reviewRating = (reviewData['rating'] ?? 0).toDouble();

      if (wasApproved && productId.isNotEmpty) {
        final productRef = _db.collection("products").doc(productId);
        final productSnap = await transaction.get(productRef);

        if (productSnap.exists) {
          final productData = productSnap.data() as Map<String, dynamic>;

          double currentRating = (productData['rating'] ?? 0).toDouble();
          int ratingCount = productData['ratingCount'] ?? 0;
          int reviewsCount = productData['reviewsCount'] ?? 0;

          int fiveStar = productData['fiveStarCount'] ?? 0;
          int fourStar = productData['fourStarCount'] ?? 0;
          int threeStar = productData['threeStarCount'] ?? 0;
          int twoStar = productData['twoStarCount'] ?? 0;
          int oneStar = productData['oneStarCount'] ?? 0;

          // Decrement star count
          switch (reviewRating.round()) {
            case 5: fiveStar = (fiveStar > 0) ? fiveStar - 1 : 0; break;
            case 4: fourStar = (fourStar > 0) ? fourStar - 1 : 0; break;
            case 3: threeStar = (threeStar > 0) ? threeStar - 1 : 0; break;
            case 2: twoStar = (twoStar > 0) ? twoStar - 1 : 0; break;
            case 1: oneStar = (oneStar > 0) ? oneStar - 1 : 0; break;
          }

          // Recalculate average
          double newAverage = 0;
          if (ratingCount > 1) {
            newAverage = ((currentRating * ratingCount) - reviewRating) / (ratingCount - 1);
          }

          transaction.update(productRef, {
            "rating": double.parse(newAverage.toStringAsFixed(1)),
            "ratingCount": (ratingCount > 0) ? ratingCount - 1 : 0,
            "reviewsCount": (reviewsCount > 0) ? reviewsCount - 1 : 0,
            "fiveStarCount": fiveStar,
            "fourStarCount": fourStar,
            "threeStarCount": threeStar,
            "twoStarCount": twoStar,
            "oneStarCount": oneStar,
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }
      }

      // Finally delete the review
      transaction.delete(reviewRef);
    });
  }
 
  Stream<List<ReviewModel>> getAll() { 
    return _db 
        .collection(collection) 
        .orderBy("updatedAt", descending: true) 
        .snapshots() 
        .map( 
          (snapshot) => 
              snapshot.docs.map((e) => ReviewModel.fromSnapshot(e)).toList(), 
        ); 
  } 
} 