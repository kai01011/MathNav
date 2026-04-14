import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegister;
  final AuthService? authService;

  const RegisterScreen({
    super.key,
    required this.onRegister,
    this.authService,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedGender = 'Male'; // Default gender selection
  String _selectedBatch = '2025-2026'; // Default batch selection

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isMet ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // If Firebase AuthService is provided, use Firebase
        if (widget.authService != null) {
          await _registerWithFirebase();
        } else {
          // Otherwise use local SharedPreferences
          await _registerWithLocal();
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

  // New method for Firebase registration
  Future<void> _registerWithFirebase() async {
    try {
      debugPrint("📝 Attempting to register with Firebase...");
      debugPrint("Username: ${_usernameController.text.trim()}");
      debugPrint("Email: ${_emailController.text.trim()}");
      debugPrint("Name: ${_nameController.text.trim()}");

      final result = await widget.authService!.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        grade: 6, // Fixed to grade 6
        gender: _selectedGender, // Add gender
        batch: _selectedBatch, // Add batch
        username: _usernameController.text.trim(),
      );

      debugPrint("📝 Registration result: $result");

      if (!mounted) return;

      if (result['success']) {
        debugPrint("✅ Registration successful!");
        debugPrint("👤 User UID: ${result['user']?.uid}");

        // Also save to SharedPreferences for offline capability
        await _saveToSharedPreferences(result['user']);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onRegister();
      } else {
        debugPrint("❌ Registration failed: ${result['error']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("🔥 Firebase Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Modified local registration to include email
  Future<void> _registerWithLocal() async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing users or create new list
    List<String>? usersList = prefs.getStringList('users') ?? [];
    Map<String, dynamic> users = {};

    // Parse existing users
    for (String userJson in usersList) {
      Map<String, dynamic> userMap = json.decode(userJson);
      users[userMap['username']] = userMap;
    }

    // Check if username already exists
    if (users.containsKey(_usernameController.text)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username already exists!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if email already exists
    bool emailExists = false;
    for (var userMap in users.values) {
      if (userMap['email'] == _emailController.text) {
        emailExists = true;
        break;
      }
    }

    if (emailExists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email already registered!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create new user with email
    final newUser = User(
      username: _usernameController.text,
      email: _emailController.text, // Add email to User model
      password: _passwordController.text,
      name: _nameController.text,
      grade: 6, // Fixed to grade 6
      gender: _selectedGender, // Add gender
      batch: _selectedBatch, // Add batch
      registrationDate: DateTime.now(), firebaseUid: null,
    );

    // Add to users list
    usersList.add(json.encode(newUser.toJson()));
    await prefs.setStringList('users', usersList);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful! Please login.'),
        backgroundColor: Colors.green,
      ),
    );

    widget.onRegister();
  }

  // Helper method to save to SharedPreferences
  Future<void> _saveToSharedPreferences(dynamic firebaseUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create a local user object
      final localUser = User(
        username: _usernameController.text,
        email: _emailController.text,
        password: '', // Don't store password in local
        name: _nameController.text,
        grade: 6, // Fixed to grade 6
        gender: _selectedGender, // Add gender
        batch: _selectedBatch, // Add batch
        registrationDate: DateTime.now(),
        firebaseUid: firebaseUser?.uid, // Store Firebase UID
      );

      // Get existing users or create new list
      List<String>? usersList = prefs.getStringList('users') ?? [];

      // Check if user already exists in local storage
      bool userExists = false;
      for (int i = 0; i < usersList.length; i++) {
        Map<String, dynamic> userMap = json.decode(usersList[i]);
        if (userMap['email'] == _emailController.text) {
          userExists = true;
          // Update existing user with Firebase UID
          userMap['firebaseUid'] = firebaseUser?.uid;
          usersList[i] = json.encode(userMap);
          break;
        }
      }

      if (!userExists) {
        // Add new user
        usersList.add(json.encode(localUser.toJson()));
      }

      await prefs.setStringList('users', usersList);
    } catch (e) {
      debugPrint('Error saving to SharedPreferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for MathNav'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Full Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.account_circle),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.length < 4) {
                            return 'Username must be at least 4 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // NEW: Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: 'example@gmail.com',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Email validation regex
                          final emailRegExp = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password Field
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
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Password must contain at least one uppercase letter';
                          }
                          if (!value.contains(RegExp(r'[a-z]'))) {
                            return 'Password must contain at least one lowercase letter';
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Password must contain at least one number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password requirements:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildRequirement(
                              'At least 8 characters',
                              _passwordController.text.length >= 8,
                            ),
                            _buildRequirement(
                              'At least one uppercase letter',
                              _passwordController.text
                                  .contains(RegExp(r'[A-Z]')),
                            ),
                            _buildRequirement(
                              'At least one lowercase letter',
                              _passwordController.text
                                  .contains(RegExp(r'[a-z]')),
                            ),
                            _buildRequirement(
                              'At least one number',
                              _passwordController.text
                                  .contains(RegExp(r'[0-9]')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Gender Selection
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        items: ['Male', 'Female'].map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // Batch/Enrollment Selection
                      DropdownButtonFormField<String>(
                        value: _selectedBatch,
                        decoration: InputDecoration(
                          labelText: 'School Year / Batch',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        items: [
                          '2024-2025',
                          '2025-2026',
                          '2026-2027',
                          '2027-2028',
                        ].map((batch) {
                          return DropdownMenuItem(
                            value: batch,
                            child: Text(batch),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBatch = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
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
                                  'REGISTER',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Login Link
                      TextButton(
                        onPressed: widget.onRegister,
                        child: const Text(
                          'Already have an account? Login',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
