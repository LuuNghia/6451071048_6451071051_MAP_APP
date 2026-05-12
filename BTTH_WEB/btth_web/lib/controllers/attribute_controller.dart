import 'package:flutter/material.dart'; 
import '../data/models/attribute_model.dart'; 
import '../data/services/attribute_service.dart'; 
 
class AttributeController extends ChangeNotifier { 
  List<AttributeModel> _allData = []; 
  List<AttributeModel> _filteredData = []; 
 
  int currentPage = 0; 
  int rowsPerPage = 5; 
  String _searchText = ""; 
 
  /// SET DATA từ stream 
  void setData(List<AttributeModel> data) { 
    _allData = data; 
    _applyFilter(); 
  } 
 
  /// SEARCH 
  void search(String value) { 
    _searchText = value.toLowerCase(); 
    currentPage = 0; 
    _applyFilter(); 
  } 
 
  /// FILTER LOGIC 
  void _applyFilter() { 
    if (_searchText.isEmpty) { 
      _filteredData = _allData; 
    } else { 
      _filteredData = _allData.where((e) { 
        return e.name.toLowerCase().contains(_searchText) || e.attributeValues.join("|").toLowerCase().contains(_searchText); 
      }).toList(); 
    } 
    notifyListeners(); 
  } 
 
  /// PAGINATION 
  List<AttributeModel> get paginatedData { 
    final start = currentPage * rowsPerPage; 
    final end = start + rowsPerPage; 
    return _filteredData.sublist( 
      start, 
      end > _filteredData.length ? _filteredData.length : end, 
    ); 
  } 

  Map<String, int> productCounts = {};
  void updateProductCounts(List<dynamic> products) {
    productCounts.clear();
    bool hasNewAttributes = false;
    
    for (var p in products) {
      final attributes = p['attributes'];
      if (attributes != null && attributes is List) {
        for (var attr in attributes) {
          final name = attr['name'] as String?;
          if (name != null) {
            productCounts[name] = (productCounts[name] ?? 0) + 1;
            
            // Nếu phát hiện thuộc tính này chưa có trong danh sách attributes hiện tại
            // Chúng ta sẽ đánh dấu để tự động đồng bộ
            if (!_allData.any((a) => a.name == name)) {
               hasNewAttributes = true;
            }
          }
        }
      }
    }
    
    // Nếu phát hiện có thuộc tính mới từ sản phẩm, thực hiện đồng bộ tự động
    if (hasNewAttributes) {
      syncFromProducts();
    }
    
    notifyListeners();
  }
  bool isSyncing = false;
  Future<void> syncFromProducts() async {
    isSyncing = true;
    notifyListeners();
    try {
      await _service.syncFromProducts();
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  final _service = AttributeService();
  int get totalPages => (_filteredData.length / rowsPerPage).ceil(); 
}