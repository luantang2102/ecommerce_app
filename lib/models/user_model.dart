import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final DateTime? createdAt;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.createdAt,
    this.imageUrl,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt ?? DateTime.now(),
      'photoUrl': imageUrl,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }

  // Optional: Create from Firebase User
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? '',
      imageUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
    );
  }
}