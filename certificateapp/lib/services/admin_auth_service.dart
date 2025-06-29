import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return userData['role'] == 'admin';
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Sign in admin with email and password
  Future<Map<String, dynamic>> signInAdmin(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'Authentication failed',
        };
      }

      // Check if user has admin role
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Admin account not found',
        };
      }

      final userData = userDoc.data()!;
      final role = userData['role'];

      if (role != 'admin') {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Access denied. Admin privileges required.',
        };
      }

      return {
        'success': true,
        'message': 'Admin login successful',
        'user': user,
        'userData': userData,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No admin account found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This admin account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  // Sign out admin
  Future<void> signOutAdmin() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out admin: $e');
    }
  }

  // Create admin account (for initial setup)
  Future<Map<String, dynamic>> createAdminAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'Failed to create admin account',
        };
      }

      // Update user display name
      await user.updateDisplayName(displayName);

      // Create admin user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'admin',
        'registrationCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isAdmin': true,
        'permissions': [
          'manage_certificates',
          'view_analytics',
          'manage_users',
          'system_settings',
        ],
      });

      return {
        'success': true,
        'message': 'Admin account created successfully',
        'user': user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to create admin account';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An admin account with this email already exists.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Failed to create admin account: ${e.message}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create admin account: $e',
      };
    }
  }

  // Get current admin user data
  Future<Map<String, dynamic>?> getCurrentAdminData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        if (userData['role'] == 'admin') {
          return userData;
        }
      }
      return null;
    } catch (e) {
      print('Error getting admin data: $e');
      return null;
    }
  }
} 