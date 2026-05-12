import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/customer_model.dart';
import '../data/services/customer_service.dart';

class CustomerController extends ChangeNotifier {
  final CustomerService _service = CustomerService();
  
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool isLoading = false;
  
  int currentPage = 1;
  int rowsPerPage = 10;
  
  /// Stores the count of orders for each customer ID
  Map<String, int> orderCountMap = {};

  /// Returns the subset of customers for the current page
  List<CustomerModel> get paginatedData {
    int start = (currentPage - 1) * rowsPerPage;
    int end = start + rowsPerPage;
    if (start >= _filteredCustomers.length) return [];
    return _filteredCustomers.sublist(
      start, 
      end > _filteredCustomers.length ? _filteredCustomers.length : end
    );
  }

  /// Total number of pages based on filtered results
  int get totalPages => (_filteredCustomers.length / rowsPerPage).ceil();

  /// Fetches all customers and their order counts
  Future<void> fetchCustomers() async {
    isLoading = true;
    notifyListeners();
    try {
      _allCustomers = await _service.getAllCustomers();
      _filteredCustomers = List.from(_allCustomers);
      
      // Fetch order counts for each customer to display in the list
      final orderSnap = await FirebaseFirestore.instance.collection('orders').get();
      orderCountMap.clear();
      for (var doc in orderSnap.docs) {
        final userId = doc.data()['userId'] as String?;
        if (userId != null) {
          orderCountMap[userId] = (orderCountMap[userId] ?? 0) + 1;
        }
      }
    } catch (e) {
      debugPrint("Error in fetchCustomers: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Filters the customer list based on a search keyword
  void search(String keyword) {
    if (keyword.isEmpty) {
      _filteredCustomers = List.from(_allCustomers);
    } else {
      final searchLower = keyword.toLowerCase();
      _filteredCustomers = _allCustomers.where((c) {
        final nameMatch = c.fullName.toLowerCase().contains(searchLower);
        final emailMatch = c.email.toLowerCase().contains(searchLower);
        final phoneMatch = c.phone.toLowerCase().contains(searchLower);
        return nameMatch || emailMatch || phoneMatch;
      }).toList();
    }
    currentPage = 1;
    notifyListeners();
  }

  /// Changes the current page for pagination
  void changePage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
      notifyListeners();
    }
  }

  /// Fetches orders for a specific customer (used in details dialog)
  Future<List<Map<String, dynamic>>> getOrders(String customerId) async {
    try {
      final orderSnap = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: customerId)
          .get();
      return orderSnap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Error in getOrders: $e");
      return [];
    }
  }

  /// Deletes a customer and updates the local lists
  Future<void> delete(String id) async {
    try {
      await _service.deleteCustomer(id);
      _allCustomers.removeWhere((c) => c.id == id);
      _filteredCustomers.removeWhere((c) => c.id == id);
      orderCountMap.remove(id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error in delete customer: $e");
    }
  }
}