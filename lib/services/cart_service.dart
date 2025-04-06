import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/models/cart_item_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/order_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      print(userId);
      final cartDoc = await _firestore
        .collection('carts')
        .doc(userId) 
        .get();

      if (!cartDoc.exists || cartDoc.data()?['items'] == null) {
        return [];
      }

      final cartData = cartDoc.data()?['items'] as List<dynamic>;
      return cartData.map((item) => CartItem(
        productId: item['productId'],
        name: item['name'],
        price: item['price'].toDouble(),
        quantity: item['quantity'],
        imageUrl: item['imageUrl'],
      )).toList();
    } catch (e) {
      print('Lỗi lấy giỏ hàng: $e');
      rethrow;
    }
  }

  Future<void> addToCart(Product product, int quantity, String userId) async {
    try {
      // Kiểm tra xem sản phẩm có tồn tại trong Firestore không
      if (product.stock < quantity) {
        throw Exception('Not enough stock available');
      }

      final cartDoc = await _firestore.collection('carts').doc(userId).get();
      List<dynamic> currentItems = cartDoc.data()?['items'] ?? [];

      // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
      bool productExists = false;
      for (var item in currentItems) {
        if (item['productId'] == product.id) {
          productExists = true;
          await updateCartItem(userId, product.id!, quantity); 
          break;
        }
      }

      // Nếu sản phẩm chưa có trong giỏ hàng, thêm mới
      if (!productExists) {
        await _firestore.collection('carts').doc(userId).set({
          'items': FieldValue.arrayUnion([
            {
              'productId': product.id,
              'name': product.name,
              'price': product.price,
              'quantity': quantity,
              'imageUrl': product.imageUrl,
            }
          ])
        }, SetOptions(merge: true));
      }

      // Cập nhật số lượng tồn kho của sản phẩm
      await _firestore.collection('products').doc(product.id).update({
        'stock': FieldValue.increment(-quantity),
      });
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> updateCartItem(String userId, String productId, int newQuantity) async {
    try {
      final cartDoc = await _firestore.collection('carts').doc(userId).get();

      if (!cartDoc.exists || cartDoc.data()?['items'] == null) {
        throw Exception('Cart does not exist');
      }

      final cartData = cartDoc.data()?['items'] as List<dynamic>;

      // Kiểm tra xem sản phẩm có trong giỏ hàng không
      final updatedItems = cartData.map((item) {
        if (item['productId'] == productId) {
          return {
            ...item,
            'quantity': item['quantity'] + newQuantity,
          };
        }
        return item;
      }).toList();

      // Cập nhật giỏ hàng với số lượng mới
      await _firestore.collection('carts').doc(userId).update({
        'items': updatedItems,
      });
    } catch (e) {
      print('Error updating cart item: $e');
      rethrow;
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeFromCart(CartItem item, String userId) async {
    try {
      await _firestore.collection('carts').doc(userId).update({
        'items': FieldValue.arrayRemove([
          {
            'productId': item.productId,
            'name': item.name,
            'price': item.price,
            'quantity': item.quantity,
            'imageUrl': item.imageUrl,
          }
        ])
      });
    } catch (e) {
      print('Lỗi xóa khỏi giỏ hàng: $e');
      rethrow;
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearCart(String userId) async {
    try {
      // Lấy các mục trong giỏ hàng để khôi phục số lượng tồn kho
      final cartItems = await getCartItems(userId);

      // Xóa toàn bộ mục khỏi giỏ hàng
      await _firestore.collection('carts').doc(userId).set({
        'items': []
      });

      // Khôi phục số lượng tồn kho cho các sản phẩm
      for (var item in cartItems) {
        await _firestore
          .collection('products')
          .doc(item.productId)
          .update({
            'stock': FieldValue.increment(item.quantity)
          });
      }
    } catch (e) {
      print('Lỗi xóa giỏ hàng: $e');
      rethrow;
    }
  }
  
  // Tạo đơn hàng
  Future<OrderModel> createOrder(List<CartItem> cartItems, String userId) async {
    try {
      double totalPrice = cartItems.fold(
        0, 
        (total, item) => total + (item.price * item.quantity)
      );

      OrderModel order = OrderModel(
        userId: userId,
        items: cartItems,
        totalPrice: totalPrice,
        orderDate: DateTime.now().toIso8601String(),
        status: 'Pending',
      );

      // Lưu đơn hàng
      DocumentReference orderRef = await _firestore
        .collection('orders')
        .add(order.toMap());

      // Cập nhật ID của đơn hàng
      order.id = orderRef.id;

      return order;
    } catch (e) {
      print('Lỗi tạo đơn hàng: $e');
      rethrow;
    }
  }
}