import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  // GOOGLE SIGN-IN
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      }

      // Native (Android/iOS): use the google_sign_in package directly,
      // then hand the token to Firebase. Avoids the browser-redirect
      // "missing initial state" error from signInWithProvider.
      await _ensureGoogleSignInInitialized();
      final googleAccount = await _googleSignIn.authenticate();

      final idToken = googleAccount.authentication.idToken;
      if (idToken == null) {
        print("Google sign-in error: no ID token returned.");
        return null;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google sign-in error: $e");
      return null;
    }
  }

  // EMAIL/PASSWORD REGISTER
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Registration error: $e");
      return null;
    }
  }

  // EMAIL/PASSWORD LOGIN
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _googleSignIn
            .disconnect()
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        // ignore if user wasn't signed in with Google, or the call
        // timed out / failed — this must never block Firebase sign-out.
      }
    }
    await _auth.signOut();
  }

  Stream<User?> get userStream => _auth.authStateChanges();
}