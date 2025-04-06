import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/services/order_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderService _orderService = OrderService();
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Ensure the initial status is valid
    final validStatuses = ['Chờ xử lý', 'Đang xử lý', 'Đã giao', 'Đã hủy'];
    _selectedStatus = validStatuses.contains(widget.order.status)
        ? widget.order.status
        : 'Chờ xử lý'; // Default to 'Chờ xử lý' if the status is invalid
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      await _orderService.updateOrderStatus(widget.order.id, newStatus);
      setState(() {
        _selectedStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thành công: $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã đơn hàng: ${order.id}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Mã khách hàng: ${order.userId}'),
            SizedBox(height: 8),
            Text('Tổng tiền: ${order.totalPrice.toStringAsFixed(2)} VND'),
            SizedBox(height: 8),
            Text('Ngày đặt: ${order.orderDate}'),
            SizedBox(height: 16),
            Text(
              'Sản phẩm:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...order.items.map((item) {
              return ListTile(
                title: Text(item.name),
                subtitle: Text('Số lượng: ${item.quantity}'),
                trailing: Text('${item.price.toStringAsFixed(2)} VND'),
              );
            }).toList(),
            SizedBox(height: 16),
            Text(
              'Trạng thái đơn hàng:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedStatus,
              items: ['Chờ xử lý', 'Đang xử lý', 'Đã giao', 'Đã hủy']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (newStatus) {
                if (newStatus != null) {
                  _updateOrderStatus(newStatus);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}