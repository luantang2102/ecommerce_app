# E-Commerce App

An e-commerce mobile application built with **Flutter** and **Dart** that allows users to browse products, manage their cart, place orders, and view order history. The app integrates with **Firebase** for backend services and **Stripe** for payment processing.

---

## Features

### Client Features
- **User Authentication**: Login and register functionality using Firebase Authentication.
- **Product Browsing**: View a list of products with details like name, price, and description.
- **Cart Management**: Add, update, and remove products from the cart.
- **Order Placement**: Place orders and make payments using Stripe.
- **Order History**: View past orders with details like order ID, total price, and status.

### Admin Features
- **Product Management**: Add, edit, and delete products.
- **Order Management**: View and manage customer orders.
- **Mock Data Upload**: Upload mock product data to Firebase for testing.

---

## Technologies Used

### Frontend
- **Flutter**: Cross-platform UI framework for building the app.
- **Provider**: State management for managing app-wide state.

### Backend
- **Firebase**:
  - **Authentication**: User login and registration.
  - **Firestore**: Database for storing products, orders, and user data.

### Payment Integration
- **Stripe**: Secure payment processing for order payments.

### Other Tools
- **Cloudinary**: For uploading and managing product images.
- **Dio**: For making HTTP requests to Stripe's API.
- **flutter_dotenv**: For managing environment variables securely.
