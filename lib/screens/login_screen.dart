import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Add this
import 'signup_screen.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isStudent = true; 
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final Color _primaryColor = const Color(0xFF5D5FEF); 
  final Color _inputFillColor = const Color(0xFFF3F4F6); 

  // --- UPDATED LOGIN LOGIC ---
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter credentials", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance(); // Open storage

    try {
      if (!_isStudent) {
        // --- ADMIN LOGIN PATH ---
        if (email == "nirajaj133@gmail.com" && password == "Team6go") {
          await prefs.setString('user_role', 'admin'); // SAVE ROLE AS ADMIN
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
          }
          return;
        } else {
          _showSnackBar("Invalid Admin Credentials", Colors.red);
          setState(() => _isLoading = false);
          return;
        }
      }

      // --- STUDENT LOGIN PATH ---
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      await prefs.setString('user_role', 'student'); // SAVE ROLE AS STUDENT
      
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }

    } catch (e) {
      _showSnackBar("Login Failed", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));
  }

  @override
  Widget build(BuildContext context) {
    // ... (Keep your existing UI code exactly as it is) ...
    // Just make sure the Sign In button calls _handleLogin
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo, Title, etc. (Same as before)
                Center(
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF5D5FEF), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(child: Text('L', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Welcome Back', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 35),

                // Account Type Switcher
                Container(
                  height: 55,
                  decoration: BoxDecoration(color: _inputFillColor, borderRadius: BorderRadius.circular(16)),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        alignment: _isStudent ? Alignment.centerLeft : Alignment.centerRight,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(child: GestureDetector(onTap: () => setState(() => _isStudent = true), child: Center(child: Text("Student", style: TextStyle(fontWeight: FontWeight.bold, color: _isStudent ? _primaryColor : Colors.grey))))),
                          Expanded(child: GestureDetector(onTap: () => setState(() => _isStudent = false), child: Center(child: Text("Admin", style: TextStyle(fontWeight: FontWeight.bold, color: !_isStudent ? _primaryColor : Colors.grey))))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Email and Password Inputs (Same as before)
                TextField(controller: _emailController, decoration: InputDecoration(hintText: 'Email', filled: true, fillColor: _inputFillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                const SizedBox(height: 20),
                TextField(controller: _passwordController, obscureText: !_isPasswordVisible, decoration: InputDecoration(hintText: 'Password', filled: true, fillColor: _inputFillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)))),
                const SizedBox(height: 30),

                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Sign In"),
                ),
                // Footer (Create Account)
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                  child: Center(child: Text("Create an account", style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}