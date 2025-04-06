import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Signup Method with Comprehensive Error Handling
  Future<UserModel?> signUp({
    required String email, 
    required String password, 
    required String fullName,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        throw Exception('All fields are required');
      }

      // Create user account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      User? firebaseUser = result.user;
      if (firebaseUser == null) {
        throw Exception('User creation failed');
      }

      // Create user model
      UserModel userModel = UserModel(
        id: firebaseUser.uid,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      // Detailed Firebase Authentication Errors
      switch (e.code) {
        case 'weak-password':
          print('The password is too weak.');
          break;
        case 'email-already-in-use':
          print('An account already exists for this email.');
          break;
        case 'invalid-email':
          print('The email address is not valid.');
          break;
        default:
          print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      return null;
    } on Exception catch (e) {
      print('Signup Error: ${e.toString()}');
      return null;
    } catch (e) {
      print('Unexpected signup error: $e');
      return null;
    }
  }
  // Đăng nhập
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      // Lấy thông tin người dùng từ Firestore
      DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(result.user!.uid)
        .get();

      return UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>, 
        result.user!.uid
      );
    } catch (e) {
      print('Đăng nhập lỗi: $e');
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Lấy người dùng hiện tại
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Google Sign-In Method
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? firebaseUser = result.user;

      if (firebaseUser == null) return null;

      // Check if user already exists in Firestore
      DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

      // If user doesn't exist, create a new user profile
      if (!userDoc.exists) {
        UserModel userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: firebaseUser.displayName ?? '',
        );

        await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toMap());

        return userModel;
      }

      // Return existing user
      return UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>, 
        firebaseUser.uid
      );
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }
}