import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for blocking check
import 'package:shared_preferences/shared_preferences.dart'; 
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

  // --- UPDATED LOGIN LOGIC WITH BLOCKING SECURITY ---
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter credentials", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    try {
      // 1. PATH: ADMIN LOGIN
      if (!_isStudent) {
        if (email == "nirajaj133@gmail.com" && password == "Team6go") {
          await prefs.setString('user_role', 'admin'); 
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

      // 2. PATH: STUDENT LOGIN
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      // --- 3. THE SECURITY CHECK (BLOCKING LOGIC) ---
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        String status = userDoc.get('status') ?? 'active';

        if (status == 'blocked') {
          // --- USER IS RESTRICTED BY ADMIN ---
          await FirebaseAuth.instance.signOut(); // Log them out immediately
          _showSnackBar("TERMINAL ACCESS REVOKED: ACCOUNT BLOCKED", Colors.red);
          setState(() => _isLoading = false);
          return; // Stop the login process
        }
      }

      // 4. SUCCESS: PROCEED TO STUDENT DASHBOARD
      await prefs.setString('user_role', 'student');
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }

    } on FirebaseAuthException catch (e) {
      String msg = "Login Failed";
      if (e.code == 'user-not-found') msg = "No user found with this email.";
      if (e.code == 'wrong-password') msg = "Incorrect password.";
      _showSnackBar(msg, Colors.red);
    } catch (e) {
      _showSnackBar("An unexpected error occurred", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: c, behavior: SnackBarBehavior.floating)
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Center(
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF5D5FEF), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Center(child: Text('L', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic))),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Welcome Back', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 8),
                Text('Elevate your skills with Learnify', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                const SizedBox(height: 35),

                // Role Switcher
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
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(child: GestureDetector(onTap: () => setState(() => _isStudent = true), behavior: HitTestBehavior.translucent, child: Center(child: Text("Student", style: TextStyle(fontWeight: FontWeight.bold, color: _isStudent ? _primaryColor : Colors.grey[600]))))),
                          Expanded(child: GestureDetector(onTap: () => setState(() => _isStudent = false), behavior: HitTestBehavior.translucent, child: Center(child: Text("Admin", style: TextStyle(fontWeight: FontWeight.bold, color: !_isStudent ? _primaryColor : Colors.grey[600]))))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Email
                TextField(controller: _emailController, decoration: InputDecoration(hintText: 'Email', filled: true, fillColor: _inputFillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                const SizedBox(height: 20),

                // Password
                TextField(
                  controller: _passwordController, 
                  obscureText: !_isPasswordVisible, 
                  decoration: InputDecoration(
                    hintText: 'Password', filled: true, fillColor: _inputFillColor, 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[500]), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                  )
                ),
                const SizedBox(height: 30),

                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                  child: Center(child: Text("Create an account", style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}