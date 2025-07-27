import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:oktoast/oktoast.dart'; // Changed from fluttertoast
import '../models/user_model.dart';
import 'firestore_service.dart';
import 'dart:developer';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Sign in with Email & Password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      showToast(
        e.message ?? "An unknown error occurred.",
        position: ToastPosition.bottom,
        backgroundColor: Colors.red,
        textStyle: TextStyle(color: Colors.white),
      );
      return null;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        showToast(
          "Google Sign-In canceled.",
          position: ToastPosition.bottom,
        );
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null && userCredential.additionalUserInfo!.isNewUser) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: user.email!,
          name: user.displayName ?? 'Google User',
          type: 'student',
          profileImageUrl: user.photoURL,
        );
        await _firestoreService.setUser(newUser);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      showToast(
        e.message ?? "Google Sign-In failed.",
        position: ToastPosition.bottom,
        backgroundColor: Colors.red,
        textStyle: TextStyle(color: Colors.white),
      );
      return null;
    } catch (e) {
      log("!! GOOGLE SIGN IN ERROR: $e");
      showToast(
        "An unexpected error occurred.",
        position: ToastPosition.bottom,
        backgroundColor: Colors.red,
        textStyle: TextStyle(color: Colors.white),
      );
      return null;
    }
  }

  // UPDATED: Register with Email, Password, and Name using OKToast
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String name) async { // Removed userType
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create a UserModel, always setting the type to 'student'
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          type: 'student', // Hardcoded to 'student'
        );

        // Save the new user's data to Firestore
        await _firestoreService.setUser(newUser);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      showToast(
        e.message ?? "Registration failed.",
        position: ToastPosition.bottom,
        backgroundColor: Colors.red,
        textStyle: TextStyle(color: Colors.white),
      );
      return null;
    } catch (e) {
      log("AN UNEXPECTED ERROR OCCURRED: $e");
      showToast(
        "An unexpected error occurred. Check debug console.",
        position: ToastPosition.bottom,
        backgroundColor: Colors.red,
        textStyle: TextStyle(color: Colors.white),
      );
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      showToast(
        "Error signing out.",
        position: ToastPosition.bottom,
        backgroundColor: Colors.red,
        textStyle: TextStyle(color: Colors.white),
      );
    }
  }
}
