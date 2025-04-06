import 'package:ecommerce_app/models/cart_item_model.dart';

class OrderModel {
  String id;
  String userId;
  List<CartItem> items;
  double totalPrice;
  String orderDate;
  String status;

  OrderModel({
    this.id = '',
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'orderDate': orderDate,
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'],
      items: (map['items'] as List)
          .map((itemMap) => CartItem.fromMap(itemMap))
          .toList(),
      totalPrice: map['totalPrice'].toDouble(),
      orderDate: map['orderDate'],
      status: map['status'],
    );
  }
}