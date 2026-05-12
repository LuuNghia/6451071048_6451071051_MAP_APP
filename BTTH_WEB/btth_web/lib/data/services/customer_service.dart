import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerService {
  final _db = FirebaseFirestore.instance;

  /// Fetch all customers from Firestore
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final snapshot = await _db
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Error fetching customers: $e';
    }
  }

  /// Get a single customer by ID
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      final doc = await _db.collection('users').doc(customerId).get();
      if (doc.exists) {
        return CustomerModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error fetching customer details: $e';
    }
  }

  /// Update customer information
  Future<void> updateCustomer(String customerId, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(customerId).update(data);
    } catch (e) {
      throw 'Error updating customer: $e';
    }
  }

  /// Delete a customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _db.collection('users').doc(customerId).delete();
    } catch (e) {
      throw 'Error deleting customer: $e';
    }
  }

  /// Search customers by name or email (simple client-side filter or startAt/endAt)
  /// For now, keeping it simple as a fetch all.
}
