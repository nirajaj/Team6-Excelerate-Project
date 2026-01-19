import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HeaderWidget extends StatelessWidget {
  final String currentView;
  final Function(String) onNavigate;
  final VoidCallback onLogout;

  const HeaderWidget({
    super.key,
    required this.currentView,
    required this.onNavigate,
    required this.onLogout,
  });

  // --- Brand Colors ---
  final Color _indigo600 = const Color(0xFF4F46E5);
  final Color _slate200 = const Color(0xFFE2E8F0);
  final Color _slate900 = const Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? "User";
    
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _slate200, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          // 1. LOGO & BRAND
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _indigo600,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _indigo600.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'L',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ).createShader(bounds),
                child: const Text(
                  'Learnify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),

          // 2. USER INFO & LOGOUT
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: _slate900,
                    ),
                  ),
                  const Text(
                    "STUDENT",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4F46E5),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              
              // --- UPDATED LOGOUT BUTTON MATCHING YOUR IMAGE ---
              GestureDetector(
                onTap: onLogout,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFEF), // Light Pink background from image
                    borderRadius: BorderRadius.circular(14), // Rounded square shape
                  ),
                  child: const Icon(
                    Icons.logout_rounded, // Exit icon from image
                    size: 20,
                    color: Color(0xFFD90429), // Bright Red icon color
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}