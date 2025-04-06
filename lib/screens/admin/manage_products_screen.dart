import 'package:ecommerce_app/screens/admin/add_edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/services/product_service.dart';
import 'package:ecommerce_app/models/product_model.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  _ManageProductsScreenState createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts().first; // Fetch products
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      final result = await _productService.deleteProduct(productId);

      if (result == 'not_for_sale') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sản phẩm đang được sử dụng và đã được chuyển sang trạng thái "Không bán".')),
        );
      } else if (result == 'deleted') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sản phẩm đã được xóa thành công.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi khi xử lý sản phẩm.')),
        );
      }

      // Refresh the product list
      setState(() {
        _productsFuture = _productService.getProducts().first;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi không xác định: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to Add Product Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditProductScreen(),
                ),
              ).then((_) {
                // Refresh products after adding a new product
                setState(() {
                  _productsFuture = _productService.getProducts().first;
                });
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi khi tải sản phẩm: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Không có sản phẩm nào.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Image.network(
                    product.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giá: ${product.price.toStringAsFixed(0)} VND'),
                      Text('Trạng thái: ${product.status == 'available' ? "Đang bán" : "Không bán"}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to Edit Product Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditProductScreen(product: product),
                            ),
                          ).then((_) {
                            // Refresh products after editing
                            setState(() {
                              _productsFuture = _productService.getProducts().first;
                            });
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteProduct(product.id!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}