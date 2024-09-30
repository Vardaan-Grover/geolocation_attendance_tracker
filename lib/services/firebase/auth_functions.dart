import 'package:firebase_auth/firebase_auth.dart';

class AuthFunctions {
  /// This function creates a new user account inside Firebase Auth (not Firestore).You still need to call `createNewUser` from `FirestoreFunctions` to create a new user in Firestore.
  ///
  ///
  /// Parameters:
  /// - `email`: The email address of the user.
  /// - `password`: The password of the user.
  ///
  /// Returns:
  /// - `"success"`: If the user was created successfully.
  /// OR
  /// - error message: If the user creation failed.
  static Future<String> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message ?? 'An error occurred.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  /// This function signs in a user using their email and password.
  /// 
  /// Parameters:
  /// - `email`: The email address of the user.
  /// - `password`: The password of the user.
  /// 
  /// Returns:
  /// - `"success"`: If the user was signed in successfully.
  /// 
  /// OR
  /// 
  /// - error message: If the sign in failed.
  static Future<String> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid email') {
        return 'Invalid email provided.';
      } else {
        return e.message ?? 'An error occurred';
      }
    } catch (e) {
      return e.toString();
    }
  }

  /// This function signs out the current user.
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Returns a `User` object if the user is logged in, otherwise returns `null`.
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
