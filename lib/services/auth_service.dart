import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  // Stream of user changes
  Stream<User?> get user => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;
  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required int grade,
    String? gender, // Add gender parameter
    String? batch, // Add batch parameter
    String? username, // Add optional username parameter
  }) async {
    try {
      if (!isPasswordStrong(password)) {
        return {
          'success': false,
          'error':
              'Password must be at least 8 characters with uppercase, lowercase, and numbers',
        };
      }

      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);
        await user.reload();

        // Use provided username or create from email
        String finalUsername = username ?? email.split('@')[0];

        debugPrint("📝 Username to store: '$finalUsername'");

        // Store additional user data in Firestore
        Map<String, dynamic> userData = {
          'uid': user.uid,
          'email': email,
          'username': finalUsername, // Store the actual username
          'name': name,
          'grade': grade,
          'gender': gender, // Add gender
          'batch': batch, // Add batch
          'registrationDate': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
        };

        debugPrint("📝 Saving to Firestore: $userData");

        await _firestore.collection('users').doc(user.uid).set(userData);

        debugPrint("✅ Firestore save successful");

        return {
          'success': true,
          'user': user,
        };
      }

      return {
        'success': false,
        'error': 'Registration failed',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      return {
        'success': false,
        'error': message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred',
      };
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("🔐 Attempting login with email: $email");

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Update last login time
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });

        // Get user data from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        return {
          'success': true,
          'user': user,
          'userData': userDoc.data(),
        };
      }

      return {
        'success': false,
        'error': 'Login failed',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Invalid username or password';
          break;
        case 'wrong-password':
          message = 'Invalid username or password';
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Try again later';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your connection';
          break;
        default:
          message = 'Invalid username or password';
      }
      return {
        'success': false,
        'error': message,
      };
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return {
        'success': false,
        'error': 'Connection error. Please try again',
      };
    }
  }

  // Login with username (convert username to email format)
  Future<Map<String, dynamic>> loginWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      // First, try to find the user in Firestore by username
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return {
          'success': false,
          'error': 'Username not found',
        };
      }

      // Get the email from Firestore
      String email = query.docs.first.get('email');

      // Now login with the email
      return await loginWithEmail(email: email, password: password);
    } catch (e) {
      return {
        'success': false,
        'error': 'Error finding username: ${e.toString()}',
      };
    }
  }

  // Register with username
  Future<Map<String, dynamic>> registerWithUsername({
    required String username,
    required String password,
    required String name,
    required int grade,
    String? gender, // Add gender parameter
  }) async {
    // Convert username to email format
    String email = '$username@mathnav.app';
    return await registerWithEmail(
      email: email,
      password: password,
      name: name,
      grade: grade,
      gender: gender, // Pass gender
      username: username,
    );
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error getting user data: $e');
    }
    return null;
  }

  // Update user grade
  Future<void> updateUserGrade(String uid, int newGrade) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'grade': newGrade,
      });
    } catch (e) {
      debugPrint('Error updating grade: $e');
    }
  }

  // Save quiz result
  Future<void> saveQuizResult({
    required String uid,
    required int quarter,
    required String topic,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      // Add quiz result to history
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('quiz_history')
          .add({
        'quarter': quarter,
        'topic': topic,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': (score / totalQuestions * 100).toStringAsFixed(1),
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update user stats
      DocumentReference userRef = _firestore.collection('users').doc(uid);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (snapshot.exists) {
          int totalQuizzes =
              (snapshot.data() as Map<String, dynamic>)['totalQuizzesTaken'] ??
                  0;
          int totalCorrect = (snapshot.data()
                  as Map<String, dynamic>)['totalCorrectAnswers'] ??
              0;
          int totalAttempted = (snapshot.data()
                  as Map<String, dynamic>)['totalQuestionsAttempted'] ??
              0;

          transaction.update(userRef, {
            'totalQuizzesTaken': totalQuizzes + 1,
            'totalCorrectAnswers': totalCorrect + score,
            'totalQuestionsAttempted': totalAttempted + totalQuestions,
          });
        }
      });
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
    }
  }
}
