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
      print('GoogleAuthService: Starting Google Sign-In process...');

      // Get Google Sign-In account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('GoogleAuthService: User cancelled the sign-in');
        return null;
      }

      print('GoogleAuthService: Google user selected: ${googleUser.email}');

      print('GoogleAuthService: Getting authentication...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('GoogleAuthService: Creating credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('GoogleAuthService: Signing in with Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);
      print('GoogleAuthService: Firebase sign-in successful');

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        print('GoogleAuthService: New user detected, creating profile...');
        // Create basic profile for new Google users
        await _createBasicGoogleUserProfile(userCredential.user!);
      } else {
        print('GoogleAuthService: Existing user, updating last login...');
        // Update last login for existing users
        await updateLastLogin(userCredential.user!.uid);
      }

      print('GoogleAuthService: Google Sign-In process completed successfully');
      return userCredential;
    } catch (e) {
      print('GoogleAuthService: Error during Google Sign-In: $e');
      print('GoogleAuthService: Error type: ${e.runtimeType}');
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
    } catch (e) {
      rethrow;
    }
  }

  // Update last login time for Google users
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  // Sign out from Google
  Future<void> signOut() async {
    try {
      print('GoogleAuthService: Starting sign out process...');

      // First, sign out from Firebase Auth
      if (_auth.currentUser != null) {
        print('GoogleAuthService: Signing out from Firebase Auth...');
        await _auth.signOut();
        print('GoogleAuthService: Firebase Auth sign out completed');
      } else {
        print('GoogleAuthService: No Firebase user to sign out');
      }

      // Then, sign out from Google Sign-In
      final isSignedIn = await _googleSignIn.isSignedIn();

      if (isSignedIn) {
        print('GoogleAuthService: Signing out from Google Sign-In...');
        await _googleSignIn.signOut();
        print('GoogleAuthService: Google Sign-In signed out successfully');

        // Try to disconnect the account to clear cache (with error handling)
        try {
          await _googleSignIn.disconnect();
          print('GoogleAuthService: Google Sign-In disconnected successfully');
        } catch (disconnectError) {
          print(
              'GoogleAuthService: Disconnect failed (this is normal): $disconnectError');
          // Disconnect failure is not critical, continue with sign out
        }
      } else {
        print('GoogleAuthService: User was not signed in with Google');
      }

      print('GoogleAuthService: Sign out process finished');
    } catch (e) {
      print('GoogleAuthService: Error during sign out: $e');
      // Don't rethrow - sign out should be graceful even if some steps fail
    }
  }

  // Check if user is signed in with Google
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  // Get current Google user
  Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      return null;
    }
  }

  // Force account selection by signing out and signing in again
  Future<UserCredential?> signInWithGoogleForceSelection() async {
    try {
      print('GoogleAuthService: Force selection - signing out completely...');

      // Sign out from both Firebase and Google
      await signOut();

      // Add a longer delay to ensure complete cleanup
      await Future.delayed(const Duration(seconds: 1));

      print('GoogleAuthService: Force selection - attempting fresh sign-in...');
      return await signInWithGoogle();
    } catch (e) {
      print('GoogleAuthService: Force Google Sign-In error: $e');
      rethrow;
    }
  }

  // Force fresh sign-in by completely clearing all states
  Future<UserCredential?> forceFreshSignIn() async {
    try {
      print('GoogleAuthService: Force fresh sign-in - clearing all states...');

      // Sign out from both services
      await signOut();

      // Add delay for complete cleanup
      await Future.delayed(const Duration(seconds: 1));

      // Force Google Sign-In to show account picker
      print(
          'GoogleAuthService: Force fresh sign-in - showing account picker...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('GoogleAuthService: Force fresh sign-in - user cancelled');
        return null;
      }

      print(
          'GoogleAuthService: Force fresh sign-in - user selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print('GoogleAuthService: Force fresh sign-in - successful');

      // Handle new/existing user logic
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _createBasicGoogleUserProfile(userCredential.user!);
      } else {
        await updateLastLogin(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      print('GoogleAuthService: Force fresh sign-in error: $e');
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
