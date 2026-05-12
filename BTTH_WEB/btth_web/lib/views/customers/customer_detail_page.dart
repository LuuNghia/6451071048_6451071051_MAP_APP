import 'package:btth_web/data/models/address_model.dart';
import 'package:btth_web/data/models/customer_model.dart';
import 'package:btth_web/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CustomerDetailPage extends StatefulWidget {
  final CustomerModel customer;
  const CustomerDetailPage({super.key, required this.customer});
  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  List<AddressModel> addresses = [];
  List<OrderModel> orders = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final addressSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.customer.id)
        .collection('addresses')
        .get();
    final orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: widget.customer.id)
        .get();
    addresses = addressSnapshot.docs
        .map((doc) => AddressModel.fromFirestore(doc))
        .toList();
    orders = orderSnapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList();
    setState(() {
      isLoading = false;
    });
  }

  double get totalSpent =>
      orders.fold(0, (sum, item) => sum + item.totalAmount);
  double get averageOrderValue =>
      orders.isEmpty ? 0 : totalSpent / orders.length;
  DateTime? get lastOrderDate {
    if (orders.isEmpty) return null;
    orders.sort(
      (a, b) => (b.orderDate ?? DateTime(2000)).compareTo(
        a.orderDate ?? DateTime(2000),
      ),
    );
    return orders.first.orderDate;
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FD),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4318FF)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2B3674),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chi tiết khách hàng",
          style: TextStyle(
            color: Color(0xFF2B3674),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- LEFT SIDE: Profile & Address ---
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildSectionCard(
                    title: "Thông tin khách hàng",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(
                              0xFF4318FF,
                            ).withOpacity(0.1),
                            child: Text(
                              widget.customer.firstName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4318FF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        infoRow("Họ", widget.customer.lastName),
                        infoRow("Tên", widget.customer.firstName),
                        infoRow("Email", widget.customer.email),
                        infoRow("Số điện thoại", widget.customer.phone),
                        infoRow("Ngày sinh", formatDate(widget.customer.dateOfBirth)),
                        const Divider(height: 32),
                        infoRow("Đơn hàng cuối", formatDate(lastOrderDate)),
                        infoRow(
                          "Giá trị đơn hàng TB",
                          averageOrderValue.toStringAsFixed(0),
                        ),
                        infoRow(
                          "Ngày đăng ký",
                          formatDate(widget.customer.createdAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: "Địa chỉ giao hàng",
                    child: addresses.isEmpty
                        ? const Text(
                            "Không tìm thấy địa chỉ",
                            style: TextStyle(color: Color(0xFFA3AED0)),
                          )
                        : Column(
                            children: addresses
                                .map((address) => _buildAddressItem(address))
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            /// --- RIGHT SIDE: Orders Table ---
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  _buildSectionCard(
                    title: "Lịch sử đơn hàng",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xFFF4F7FE),
                            ),
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(label: _TableLabel("Mã đơn")),
                              DataColumn(label: _TableLabel("Ngày đặt")),
                              DataColumn(label: _TableLabel("Số lượng")),
                              DataColumn(label: _TableLabel("Trạng thái")),
                              DataColumn(label: _TableLabel("Tổng tiền")),
                            ],
                            rows: orders
                                .map(
                                  (order) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          order.id,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF4318FF),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(formatDate(order.orderDate)),
                                      ),
                                      DataCell(
                                        Text(order.itemCount.toString()),
                                      ),
                                      DataCell(
                                        _buildStatusBadge(order.orderStatus),
                                      ),
                                      DataCell(
                                        Text(
                                          order.totalAmount.toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Báo cáo tổng quát",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2B3674),
                                ),
                              ),
                              Text(
                                "Tổng chi tiêu ${totalSpent.toStringAsFixed(0)}đ trên ${orders.length} đơn hàng",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4318FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildAddressItem(AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault
              ? const Color(0xFF4318FF)
              : const Color(0xFFE0E5F2),
        ),
        color: address.isDefault
            ? const Color(0xFF4318FF).withOpacity(0.02)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: address.isDefault
                ? const Color(0xFF4318FF)
                : const Color(0xFFA3AED0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.isDefault)
                  const Text(
                    "ĐỊA CHỈ MẶC ĐỊNH",
                    style: TextStyle(
                      color: Color(0xFF4318FF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  address.fullAddress,
                  style: const TextStyle(
                    color: Color(0xFF2B3674),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    String vietnameseStatus = status;
    Color color = Colors.blue;

    switch (status.toLowerCase()) {
      case 'delivered':
        vietnameseStatus = "Đã giao";
        color = Colors.green;
        break;
      case 'cancelled':
        vietnameseStatus = "Đã hủy";
        color = Colors.red;
        break;
      case 'processing':
        vietnameseStatus = "Đang xử lý";
        color = Colors.orange;
        break;
      case 'pending':
        vietnameseStatus = "Chờ xử lý";
        color = Colors.amber;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        vietnameseStatus,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFA3AED0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2B3674),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableLabel extends StatelessWidget {
  final String label;
  const _TableLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFA3AED0),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}
