import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(User) onLogin;
  final AuthService? authService;

  const LoginScreen({
    super.key,
    required this.onLogin,
    this.authService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController =
      TextEditingController(); // Can be username or email
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Clear any existing password error
    setState(() {
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Check if Firebase AuthService is provided
        if (widget.authService != null) {
          await _loginWithFirebase();
        } else {
          await _loginWithLocal();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Firebase login method
  Future<void> _loginWithFirebase() async {
    // First check password length manually
    if (_passwordController.text.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters';
      });
      return;
    }

    String loginInput = _usernameController.text.trim();

    // Check if input is email or username
    bool isEmail = loginInput.contains('@');

    Map<String, dynamic> result;

    try {
      setState(() {
        _passwordError = null; // Clear any previous error
      });

      if (isEmail) {
        // Login with email
        result = await widget.authService!.loginWithEmail(
          email: loginInput,
          password: _passwordController.text,
        );
      } else {
        // Login with username
        result = await widget.authService!.loginWithUsername(
          username: loginInput,
          password: _passwordController.text,
        );
      }

      if (!mounted) return;

      if (result['success']) {
        // Get user data from Firestore
        final userData =
            await widget.authService!.getUserData(result['user'].uid);

        if (userData != null) {
          debugPrint("✅ User data retrieved: ${userData['username']}");

          // Create User object from Firestore data
          final user = User(
            username: userData['username'],
            email: userData['email'],
            password: '', // Don't store password
            name: userData['name'],
            grade: userData['grade'],
            registrationDate: DateTime.parse(userData['registrationDate']),
            firebaseUid: result['user'].uid,
          );

          // Also save to SharedPreferences for offline capability
          await _saveToSharedPreferences(user);

          widget.onLogin(user);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error loading user data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Show the friendly error message from auth service
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("Unexpected error in login: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection error. Please try again'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Local login method
  Future<void> _loginWithLocal() async {
    // First check password length manually
    if (_passwordController.text.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters';
      });
      return;
    }

    try {
      setState(() {
        _passwordError = null; // Clear any previous error
      });

      final prefs = await SharedPreferences.getInstance();
      final usersList = prefs.getStringList('users') ?? [];

      User? foundUser;

      for (String userJson in usersList) {
        Map<String, dynamic> userMap = json.decode(userJson);
        if (userMap['username'] == _usernameController.text &&
            userMap['password'] == _passwordController.text) {
          foundUser = User.fromJson(userMap);
          break;
        }
      }

      if (!mounted) return;

      if (foundUser != null) {
        widget.onLogin(foundUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // 💾 Helper method to save user to SharedPreferences
  Future<void> _saveToSharedPreferences(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users or create new list
      List<String>? usersList = prefs.getStringList('users') ?? [];

      // Check if user already exists in local storage
      bool userExists = false;
      for (int i = 0; i < usersList.length; i++) {
        Map<String, dynamic> userMap = json.decode(usersList[i]);
        if (userMap['email'] == user.email) {
          userExists = true;
          // Update existing user
          usersList[i] = json.encode(user.toJson());
          break;
        }
      }

      if (!userExists) {
        // Add new user
        usersList.add(json.encode(user.toJson()));
      }

      await prefs.setStringList('users', usersList);

      // Also save current user for quick access
      await prefs.setString('currentUser', json.encode(user.toJson()));
      await prefs.setBool('isLoggedIn', true);
    } catch (e) {
      debugPrint('Error saving to SharedPreferences: $e');
    }
  }

  // 🔄 Password reset method
  Future<void> _resetPassword() async {
    String loginInput = _usernameController.text.trim();

    if (loginInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if input looks like an email
    if (!loginInput.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.authService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset requires Firebase'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await widget.authService!.resetPassword(loginInput);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? result['error']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      if (result['success']) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Password must contain uppercase, lowercase, and numbers',
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          onRegister: () {
            Navigator.pop(context);
          },
          authService: widget.authService, // Pass authService to RegisterScreen
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade100],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calculate,
                      size: 100,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'MathNav',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text(
                      'Grade 6 Mathematics',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // UPDATED: Username/Email field
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username or Email',
                              hintText: 'Enter your username or email',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username or email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorText: _passwordError,
                            ),
                            onChanged: (value) {
                              if (_passwordError != null) {
                                setState(() {
                                  _passwordError = null;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          // NEW: Forgot password link
                          if (widget.authService != null) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _resetPassword,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Register link
                          TextButton(
                            onPressed: _goToRegister,
                            child: const Text(
                              'New Student? Register Here',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
