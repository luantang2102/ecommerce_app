import 'package:ecommerce_app/screens/admin/order_details.screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/services/order_service.dart';
import 'package:ecommerce_app/models/order_model.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  _ManageOrdersScreenState createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getAllOrders(); // Lấy danh sách đơn hàng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý đơn hàng'),
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi khi tải đơn hàng: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Không có đơn hàng nào.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Mã đơn hàng: ${order.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng tiền: ${order.totalPrice.toStringAsFixed(2)} VND'),
                      Text('Trạng thái: ${order.status}'),
                      Text('Ngày đặt: ${order.orderDate}'),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(order: order),
                      ),
                    );
                    setState(() {
                      _ordersFuture = _orderService.getAllOrders(); // Refresh the order list
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}