import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'google_auth_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      await updateLastLogin(userCredential.user!.uid);

      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _createUserProfile(userCredential.user!);

      return userCredential;
    } catch (e) {
      debugPrint('Error creating user with email and password: $e');
      rethrow;
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'phoneNumber': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'role': 'Recipient', // Default role
        'isActive': true,
        'authProvider': 'email',
      });
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required String fullName,
    required String role,
    String? organization,
    String? phoneNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'displayName': fullName,
        'role': role,
        'organization': organization,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Sign out (handles both email/password and Google Sign-In)
  Future<void> signOut() async {
    try {
      debugPrint('AuthService: Starting sign out process...');

      // First, sign out from Google if user was signed in with Google
      try {
        await _googleAuthService.signOut();
        debugPrint('AuthService: Google Sign-In sign out completed');
      } catch (e) {
        debugPrint('AuthService: Error signing out from Google: $e');
        // Continue with Firebase sign out even if Google sign out fails
      }

      // Then, sign out from Firebase Auth
      try {
        await _auth.signOut();
        debugPrint('AuthService: Firebase Auth sign out completed');
      } catch (e) {
        debugPrint('AuthService: Error signing out from Firebase: $e');
        rethrow;
      }

      debugPrint(
          'AuthService: Complete sign out process finished successfully');
    } catch (e) {
      debugPrint('AuthService: Error in sign out process: $e');
      rethrow;
    }
  }

  // Check if user exists in Firestore
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking if user exists: $e');
      return false;
    }
  }

  // Update last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  // Get Google Auth Service
  GoogleAuthService get googleAuthService => _googleAuthService;
}
