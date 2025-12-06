import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user.dart' as models;

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _getGoogleSignIn {
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn!;
  }

  // Get current user
  models.User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return models.User(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
    );
  }

  // Stream of auth state changes
  Stream<models.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return models.User(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
      );
    });
  }

  // Sign in with Google
  Future<models.User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _getGoogleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      return models.User(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
      );
    } catch (e) {
      // Log error for debugging
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign in with Apple
  Future<models.User?> signInWithApple() async {
    try {
      // For web, use Firebase's built-in Apple auth provider with popup
      if (kIsWeb) {
        final provider = firebase_auth.OAuthProvider("apple.com");
        provider.addScope('email');
        provider.addScope('name');

        final firebase_auth.UserCredential userCredential =
            await _firebaseAuth.signInWithPopup(provider);

        final firebaseUser = userCredential.user;
        if (firebaseUser == null) return null;

        return models.User(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
        );
      }

      // For native platforms (iOS/macOS), use sign_in_with_apple package
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential from the Apple ID credential
      final oauthCredential =
          firebase_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: appleCredential.identityToken,
      );

      // Sign in to Firebase with the Apple credential
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Update display name if available from Apple
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty && firebaseUser.displayName == null) {
          await firebaseUser.updateDisplayName(displayName);
        }
      }

      return models.User(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
      );
    } catch (e) {
      // Log error for debugging
      debugPrint('Error signing in with Apple: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
    } catch (e) {
      // Log error for debugging
      debugPrint('Error signing out: $e');
    }
  }

  // Check if Apple Sign In is available (iOS 13+, macOS 10.15+, or web)
  Future<bool> checkAppleSignInAvailability() async {
    // Apple Sign-In is available on web via Firebase
    if (kIsWeb) {
      return true;
    }
    // Use try-catch to handle platforms where Platform is not available
    try {
      if (!Platform.isIOS && !Platform.isMacOS) {
        return false;
      }
      return await SignInWithApple.isAvailable();
    } catch (e) {
      return false;
    }
  }
}
