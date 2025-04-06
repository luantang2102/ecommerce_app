import 'package:ecommerce_app/models/cart_item_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/screens/client/order_history_screen.dart';
import 'package:ecommerce_app/screens/client/product_detail_screen.dart';
import 'package:ecommerce_app/services/cart_service.dart';
import 'package:ecommerce_app/services/product_service.dart';
import 'package:ecommerce_app/services/stripe_service.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final UserModel? user;

  const CartScreen({Key? key, this.user}) : super(key: key);
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() async {
    final cartService = Provider.of<CartService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await cartService.getCartItems(widget.user?.id ?? '1');
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Không thể tải giỏ hàng: $e');
    }
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  void _updateItemQuantity(CartItem item, int newQuantity) async {
    final cartService = Provider.of<CartService>(context, listen: false);

    try {
      setState(() {
        _isLoading = true;
      });

      // Update the cart item quantity
      await cartService.addToCart(
        Product(
          id: item.productId,
          name: item.name,
          description: 'No description available', // Provide a default description
          price: item.price,
          stock: 9999, // Assume stock is handled in the backend
          imageUrl: item.imageUrl,
        ),
        newQuantity - item.quantity,
        widget.user?.id ?? '1',
      );

      // Reload the cart items
      _loadCartItems();
    } catch (e) {
      _showErrorSnackBar('Không thể cập nhật số lượng: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeItem(CartItem item) async {
    final cartService = Provider.of<CartService>(context, listen: false);
    
    try {
      await cartService.removeFromCart(item, widget.user?.id ?? '1');
      _loadCartItems();
    } catch (e) {
      _showErrorSnackBar('Không thể xóa sản phẩm: $e');
    }
  }

  void _checkout() async {
    final cartService = Provider.of<CartService>(context, listen: false);
    
    // Prevent multiple checkout attempts
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create order first
      await cartService.createOrder(_cartItems, widget.user?.id ?? '1');

      // Attempt Stripe payment
      final paymentResult = await StripeService.instance.makePayment(
        name: widget.user?.fullName ?? 'Incognito', 
        amount: _calculateTotal()
      );

      // Handle payment result
      if (paymentResult.success) {
        // Payment successful
        await cartService.clearCart(widget.user?.id ?? '1');
        _showSuccessSnackBar('Thanh toán thành công');
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (_) => OrderHistoryScreen(user: widget.user,)
          )
        );
      } else {
        // Payment failed
        _showErrorSnackBar(paymentResult.message);
      }
    } catch (e) {
      _showErrorSnackBar('Thanh toán thất bại: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      )
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Giỏ hàng trống',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return ListTile(
                            leading: Image.network(
                              item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(item.name),
                            subtitle: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      _updateItemQuantity(item, item.quantity - 1);
                                    }
                                  },
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    _updateItemQuantity(item, item.quantity + 1);
                                  },
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(item),
                            ),
                            onTap: () async {
                              // Fetch the product details using ProductService
                              final productService = ProductService();
                              try {
                                final product = await productService.getProductById(item.productId);
                                if (product != null) {
                                  // Navigate to the ProductDetailScreen with the fetched product
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(product: product, user: widget.user),
                                    ),
                                  );
                                } else {
                                  _showErrorSnackBar('Sản phẩm không tồn tại');
                                }
                              } catch (e) {
                                _showErrorSnackBar('Không thể tải thông tin sản phẩm: $e');
                              }
                            },
                          );
                        },
                      ),
                    ),

                    // Total and Checkout Button
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng cộng:',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${_calculateTotal().toStringAsFixed(0)} VND',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _checkout,
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text('Thanh toán'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}