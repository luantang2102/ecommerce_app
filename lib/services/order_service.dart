import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/cart_item_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách đơn hàng của người dùng
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      print(userId);
      final ordersQuery = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      return ordersQuery.docs.map((doc) {
        // Chuyển đổi dữ liệu Firestore sang OrderModel
        final data = doc.data();
        data['id'] = doc.id;

        // Chuyển đổi items từ map sang CartItem
        final itemsData = data['items'] as List<dynamic>;
        final items = itemsData.map((itemData) => CartItem(
          productId: itemData['productId'],
          name: itemData['name'],
          price: (itemData['price'] as num).toDouble(),
          quantity: itemData['quantity'],
          imageUrl: itemData['imageUrl'],
        )).toList();

        // Tạo OrderModel với items đã được chuyển đổi
        return OrderModel(
          id: data['id'],
          userId: data['userId'],
          items: items,
          totalPrice: (data['totalPrice'] as num).toDouble(),
          orderDate: (data['orderDate'] as String),
          status: data['status'] ?? 'Pending',
        );
      }).toList();
    } catch (e) {
      print('Lỗi lấy đơn hàng: $e');
      rethrow;
    }
  }

  // Lấy tất cả đơn hàng
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final ordersQuery = await _firestore.collection('orders').get();

      return ordersQuery.docs.map((doc) {
        // Chuyển đổi dữ liệu Firestore sang OrderModel
        final data = doc.data();
        data['id'] = doc.id;

        // Chuyển đổi items từ map sang CartItem
        final itemsData = data['items'] as List<dynamic>;
        final items = itemsData.map((itemData) => CartItem(
          productId: itemData['productId'],
          name: itemData['name'],
          price: (itemData['price'] as num).toDouble(),
          quantity: itemData['quantity'],
          imageUrl: itemData['imageUrl'],
        )).toList();

        // Tạo OrderModel với items đã được chuyển đổi
        return OrderModel(
          id: data['id'],
          userId: data['userId'],
          items: items,
          totalPrice: (data['totalPrice'] as num).toDouble(),
          orderDate: (data['orderDate'] as String),
          status: data['status'] ?? 'Pending',
        );
      }).toList();
    } catch (e) {
      print('Lỗi lấy tất cả đơn hàng: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }
}