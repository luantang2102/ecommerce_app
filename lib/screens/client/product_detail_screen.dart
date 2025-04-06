import 'package:ecommerce_app/screens/client/cart_screen.dart';
import 'package:ecommerce_app/services/auth_service.dart';
import 'package:ecommerce_app/services/cart_service.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final UserModel? user;
  final Product product;

  const ProductDetailScreen({Key? key, required this.product, this.user}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _incrementQuantity() {
    if (_quantity < widget.product.stock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() async {
    final cartService = Provider.of<CartService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // Lấy người dùng hiện tại
      final currentUser = authService.getCurrentUser();
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng đăng nhập'))
        );
        return;
      }

      // Thêm vào giỏ hàng
      await cartService.addToCart(
        widget.product, 
        _quantity,
        widget.user?.id ?? '1'
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm vào giỏ hàng'),
          action: SnackBarAction(
            label: 'Xem giỏ hàng', 
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (_) => CartScreen(user: widget.user,)
              )
            ),
          ),
        )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết sản phẩm'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            Image.network(
              product.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),

            // Thông tin sản phẩm
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      // Đánh giá
                      Row(
                        children: List.generate(
                          5, 
                          (starIndex) => Icon(
                            starIndex < product.rating.round() 
                              ? Icons.star 
                              : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          )
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('${product.rating} (100 đánh giá)')
                    ],
                  ),
                  SizedBox(height: 10),
                  // Giá
                  Text(
                    '${product.price.toStringAsFixed(0)} VND',
                    style: TextStyle(
                      fontSize: 24, 
                      color: Colors.red, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10),
                  // Mô tả
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  
                  // Số lượng
                  Row(
                    children: [
                      Text(
                        'Số lượng:', 
                        style: TextStyle(fontSize: 18)
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: _decrementQuantity,
                      ),
                      Text(
                        '$_quantity', 
                        style: TextStyle(fontSize: 18)
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                  Text(
                    'Còn ${product.stock} sản phẩm', 
                    style: TextStyle(color: Colors.grey)
                  ),
                  SizedBox(height: 20),

                  // Nút thêm giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      child: Text(
                        'Thêm vào giỏ hàng', 
                        style: TextStyle(fontSize: 18)
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}