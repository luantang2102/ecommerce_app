import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final cloudinary = Cloudinary.signedConfig(
  apiKey: dotenv.get('CLOUDINARY_API_KEY'),
  apiSecret: dotenv.get('CLOUDINARY_API_SECRET'),
  cloudName: dotenv.get('CLOUDINARY_CLOUD_NAME'),
);

  Future<String> uploadImageToCloudinary(File imageFile) async {
    try {
      final response = await cloudinary.upload(
        file: imageFile.path,
        resourceType: CloudinaryResourceType.image,
        folder: 'ecommerce_app',
      );  

      if (response.isSuccessful) {
        return response.secureUrl!; // Return the secure URL of the uploaded image
      } else {
        throw Exception('Failed to upload image: ${response.error}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

  void uploadMockData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> mockProducts = [
      {
        "name": "Chuột không dây",
        "description": "Chuột không dây công thái học với DPI có thể điều chỉnh.",
        "price": 299000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954757/91d5f966-a609-4d1c-b319-676aa2a5c836.png",
        "stock": 150,
        "categories": ["Điện tử", "Phụ kiện"],
        "rating": 4.5
      },
      {
        "name": "Bàn phím cơ",
        "description": "Bàn phím cơ có đèn nền RGB với switch blue.",
        "price": 799000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954256/BAN-PHIM-XINMENG-02-jpg_fijq5q.webp",
        "stock": 100,
        "categories": ["Điện tử", "Bàn phím"],
        "rating": 4.7
      },
      {
        "name": "Tai nghe gaming",
        "description": "Tai nghe gaming âm thanh vòm, mic chống ồn.",
        "price": 599000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954363/11d63637-c9f8-4e88-9c70-523685d4114e.png",
        "stock": 80,
        "categories": ["Điện tử", "Âm thanh"],
        "rating": 4.3
      },
      {
        "name": "Đồng hồ thông minh",
        "description": "Đồng hồ thông minh chống nước, đo nhịp tim.",
        "price": 1499000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954481/41f708ae-11a3-4f4d-9611-046be626d4b3.png",
        "stock": 200,
        "categories": ["Thiết bị đeo", "Sức khỏe"],
        "rating": 4.6
      },
      {
        "name": "Loa Bluetooth",
        "description": "Loa Bluetooth di động, âm trầm mạnh mẽ.",
        "price": 399000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954525/9e147a80-335d-4ff7-80d2-ac7d03799401.png",
        "stock": 120,
        "categories": ["Điện tử", "Âm thanh"],
        "rating": 4.4
      },
      {
        "name": "Màn hình 4K",
        "description": "Màn hình 4K UHD 27 inch, hỗ trợ HDR.",
        "price": 5999000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954564/9ab195d4-d97e-4eff-b46a-06792e733920.png",
        "stock": 50,
        "categories": ["Điện tử", "Hiển thị"],
        "rating": 4.8
      },
      {
        "name": "Ổ cứng SSD di động",
        "description": "SSD 1TB USB-C tốc độ cao.",
        "price": 1299000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954463/612f4139-e478-41b8-9b60-c820d11b9ac2.png",
        "stock": 90,
        "categories": ["Điện tử", "Lưu trữ"],
        "rating": 4.7
      },
      {
        "name": "Điện thoại thông minh",
        "description": "Màn hình AMOLED, camera 3 ống kính.",
        "price": 8999000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954625/fbfef80f-98fc-4cc9-b151-3095745d063b.png",
        "stock": 75,
        "categories": ["Điện tử", "Di động"],
        "rating": 4.9
      },
      {
        "name": "Balo laptop",
        "description": "Balo chống nước, cổng sạc USB.",
        "price": 499000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954823/fc70a21f-1239-4002-ba7d-5b281ed2023e.png",
        "stock": 140,
        "categories": ["Phụ kiện", "Túi xách"],
        "rating": 4.6
      },
      {
        "name": "Tai nghe không dây",
        "description": "Tai nghe chống ồn, pin 24 giờ.",
        "price": 999000,
        "imageUrl": "https://res.cloudinary.com/drlx1uok3/image/upload/v1742954417/4cea3ee7-7aa1-4b85-859f-16fb11247971.png",
        "stock": 95,
        "categories": ["Điện tử", "Âm thanh"],
        "rating": 4.7
      }
    ];

    for (var product in mockProducts) {
      await firestore.collection('products').add(product);
    }

    print("Dữ liệu mô phỏng đã được tải lên Firebase!");
  }
  
  Future<void> addProduct(Product product, {File? imageFile}) async {
    try {
      String? imageUrl;

      // Upload the image if a file is provided
      if (imageFile != null) {
        imageUrl = await uploadImageToCloudinary(imageFile);
      }

      // Use the uploaded image URL or the existing one
      final productData = product.toMap();
      if (imageUrl != null) {
        productData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('products').add(productData);
      print('Product added successfully.');
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product, {File? imageFile}) async {
    try {
      String? imageUrl;

      // Upload the image if a file is provided
      if (imageFile != null) {
        imageUrl = await uploadImageToCloudinary(imageFile);
      }

      // Use the uploaded image URL or the existing one
      final productData = product.toMap();
      if (imageUrl != null) {
        productData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('products').doc(product.id).update(productData);
      print('Product updated successfully.');
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<String> deleteProduct(String productId) async {
    try {
      // Retrieve all carts
      final cartSnapshot = await _firestore.collection('carts').get();

      // Retrieve all orders
      final orderSnapshot = await _firestore.collection('orders').get();

      // Check if the product exists in any cart
      final isInCart = cartSnapshot.docs.any((doc) {
        final items = List<Map<String, dynamic>>.from(doc.data()['items'] ?? []);
        return items.any((item) => item['productId'] == productId);
      });

      // Check if the product exists in any order
      final isInOrder = orderSnapshot.docs.any((doc) {
        final items = List<Map<String, dynamic>>.from(doc.data()['items'] ?? []);
        return items.any((item) => item['productId'] == productId);
      });

      if (isInCart || isInOrder) {
        // If the product is in a cart or an order, update its status to "not for sale"
        await _firestore.collection('products').doc(productId).update({
          'status': 'not for sale',
        });
        return 'not_for_sale'; // Return a code indicating the product is marked as "not for sale"
      } else {
        // If the product is not in any cart or order, delete it
        await _firestore.collection('products').doc(productId).delete();
        return 'deleted'; // Return a code indicating the product was deleted
      }
    } catch (e) {
      print('Error deleting product: $e');
      return 'error'; // Return a code indicating an error occurred
    }
  }

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();

      if (doc.exists) {
        return Product.fromMap(doc.data()!, doc.id); // Convert Firestore data to Product
      } else {
        return null; // Return null if the product does not exist
      }
    } catch (e) {
      print('Error fetching product by ID: $e');
      rethrow;
    }
  }

  Future<void> ensureMockData() async {
    var snapshot = await _firestore.collection('products').get();
    if (snapshot.docs.isEmpty) {
      uploadMockData();
    }
  }
}