import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/services/order_service.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class OrderHistoryScreen extends StatefulWidget {
  final UserModel? user;

  const OrderHistoryScreen({Key? key, this.user}) : super(key: key);
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    final orderService = Provider.of<OrderService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Pass the user ID if the user object exists
      final orders = await orderService.getUserOrders(
        widget.user?.id ?? '1' // Use an empty string as fallback
      );
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'))
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Paid':
        return Colors.green;
      case 'Shipped':
        return Colors.blue;
      case 'Delivered':
        return Colors.purple;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử đơn hàng'),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Chưa có đơn hàng nào', 
                    style: TextStyle(fontSize: 20, color: Colors.grey)
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn hàng #${order.id.substring(0, 6)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4), // Add spacing between lines
                        Text(
                          '${order.totalPrice.toStringAsFixed(0)} VND',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Ngày: ${order.orderDate.toString().substring(0, 10)}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      // Chi tiết sản phẩm
                      ...order.items.map((item) => ListTile(
                        leading: Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.price.toStringAsFixed(0)} VND x ${item.quantity}',
                        ),
                      )).toList(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}