import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Enable account selection
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in or register with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out from Google first to allow account selection
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // Create basic profile for new Google users
        await _createBasicGoogleUserProfile(userCredential.user!);
      } else {
        // Update last login for existing users
        await updateLastLogin(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In error: $e');
      rethrow;
    }
  }

  // Create basic user profile in Firestore for new Google users (without role)
  Future<void> _createBasicGoogleUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'phoneNumber': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'authProvider': 'google',
        'emailVerified': user.emailVerified,
        'registrationCompleted': false, // Mark as needing registration
      });
      print('Basic Google user profile created successfully');
    } catch (e) {
      print('Error creating basic Google user profile: $e');
      rethrow;
    }
  }

  // Update last login time for Google users
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      print('Last login time updated for Google user');
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Sign out from Google
  Future<void> signOut() async {
    try {
      print('GoogleAuthService: Starting Google Sign-In sign out...');

      // Check if user is currently signed in with Google
      final isSignedIn = await _googleSignIn.isSignedIn();
      print(
          'GoogleAuthService: Is currently signed in with Google: $isSignedIn');

      if (isSignedIn) {
        // Sign out from Google Sign-In
        await _googleSignIn.signOut();
        print('GoogleAuthService: Google Sign-In signed out successfully');
      } else {
        print('GoogleAuthService: User was not signed in with Google');
      }

      // Also check Firebase Auth state
      if (_auth.currentUser != null) {
        print(
            'GoogleAuthService: Firebase user still exists: ${_auth.currentUser?.email}');
      } else {
        print('GoogleAuthService: No Firebase user found');
      }

      print('GoogleAuthService: Complete sign out process finished');
    } catch (e) {
      print('GoogleAuthService: Error signing out from Google: $e');
      rethrow;
    }
  }

  // Check if user is signed in with Google
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      print('Error checking Google Sign-In status: $e');
      return false;
    }
  }

  // Get current Google user
  Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      print('Error getting current Google user: $e');
      return null;
    }
  }

  // Force account selection by signing out and signing in again
  Future<UserCredential?> signInWithGoogleForceSelection() async {
    try {
      // Always sign out first to force account selection
      await _googleSignIn.signOut();
      return await signInWithGoogle();
    } catch (e) {
      print('Force Google Sign-In error: $e');
      rethrow;
    }
  }
}

/*
 * TODO: Implement Google Sign-In
 * 
 * To implement Google Sign-In, you'll need to:
 * 
 * 1. Update the google_sign_in package to a compatible version
 * 2. Configure Google Sign-In in Firebase Console
 * 3. Add the necessary configuration files
 * 4. Implement the actual sign-in flow
 * 
 * Example implementation (when API is compatible):
 * 
 * import 'package:google_sign_in/google_sign_in.dart';
 * 
 * class GoogleAuthService {
 *   final GoogleSignIn _googleSignIn = GoogleSignIn();
 *   
 *   Future<UserCredential?> signInWithGoogle() async {
 *     try {
 *       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
 *       
 *       if (googleUser == null) return null;
 * 
 *       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
 *       final credential = GoogleAuthProvider.credential(
 *         accessToken: googleAuth.accessToken,
 *         idToken: googleAuth.idToken,
 *       );
 * 
 *       final UserCredential userCredential = await _auth.signInWithCredential(credential);
 *       
 *       if (userCredential.additionalUserInfo?.isNewUser == true) {
 *         await _createGoogleUserProfile(userCredential.user!);
 *       }
 * 
 *       return userCredential;
 *     } catch (e) {
 *       print('Error signing in with Google: $e');
 *       rethrow;
 *     }
 *   }
 * }
 */
