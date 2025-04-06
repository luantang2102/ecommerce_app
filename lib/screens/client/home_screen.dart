import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/screens/client/cart_screen.dart';
import 'package:ecommerce_app/screens/client/order_history_screen.dart';
import 'package:ecommerce_app/services/product_service.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  // Constructor to receive user information
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService productService = ProductService();
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = [
    'Tất cả', 'Điện tử', 'Âm thanh', 'Phụ kiện', 'Hiển thị'
  ];

  @override
  void initState() {
    super.initState();
    productService.ensureMockData(); 
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cửa hàng điện tử'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (_) => CartScreen(user: widget.user,)
              )
            )
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              // Use user information from the passed UserModel
              accountName: Text(widget.user.fullName),
              accountEmail: Text(widget.user.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: widget.user.imageUrl != null 
                  ? Image.network(widget.user.imageUrl!)
                  : Icon(Icons.person, size: 50),
              ),
            ),
            ListTile(
              title: Text('Trang chủ'),
              leading: Icon(Icons.home),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Đơn hàng của tôi'),
              leading: Icon(Icons.list),
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => OrderHistoryScreen(user: widget.user,)
                )
              )
            ),
            ListTile(
              title: Text('Đăng xuất'),
              leading: Icon(Icons.exit_to_app),
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Danh mục
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Danh sách sản phẩm
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: productService.getProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var products = snapshot.data!;
                
                // Lọc theo danh mục
                if (_selectedCategory != 'Tất cả') {
                  products = products.where((p) => 
                    p.categories.contains(_selectedCategory)).toList();
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product, user: widget.user,)
                        )
                      ),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              product.imageUrl, 
                              height: 150, 
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name, 
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${product.price.toStringAsFixed(0)} VND',
                                    style: TextStyle(
                                      color: Colors.red, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    product.description,
                                    style: TextStyle(color: Colors.grey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                                  )
                                ],
                                
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}