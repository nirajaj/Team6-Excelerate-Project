import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/header_widget.dart';
import 'dashboard_view.dart';
import 'academy_screen.dart';
import 'login_screen.dart';
import 'support_screen.dart';
import 'user_profile_screen.dart'; // 1. IMPORT THE PROFILE SCREEN

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _selectedIndex = 0; 
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    String firstName = user?.displayName?.split(' ')[0] ?? "Explorer";

    // 2. UPDATED LIST OF PAGES TO INCLUDE USER PROFILE
    final List<Widget> _pages = [
      DashboardView(
        firstName: firstName, 
        pulseAnimation: Tween(begin: 0.1, end: 0.3).animate(_pulseController),
        onAccessAcademy: () {
          setState(() {
            _selectedIndex = 1; // Switches to Academy
          });
        },
      ),
      const AcademyScreen(),    // Index 1: Registry
      const SupportScreen(),    // Index 2: Elite Support Form
      const UserProfileScreen(), // Index 3: NOW SHOWS THE PROFESSIONAL PROFILE
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // FIXED HEADER (STAYS AT TOP)
            HeaderWidget(
              currentView: _selectedIndex == 0 ? "HOME" : "OTHER",
              onNavigate: (view) {
                setState(() {
                  _selectedIndex = 0; // Click logo to go home
                });
              },
              onLogout: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),

            // DYNAMIC MIDDLE AREA
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      // FIXED BOTTOM NAV (STAYS AT BOTTOM)
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navBtn(0, Icons.grid_view_rounded, "Dashboard"),
          _navBtn(1, Icons.school_outlined, "Academy"),
          _navBtn(2, Icons.headset_mic_outlined, "Support"),
          _navBtn(3, Icons.person_outline_rounded, "Profile"),
        ],
      ),
    );
  }

  Widget _navBtn(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF5D5FEF) : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), 
            style: TextStyle(
              fontSize: 8, 
              fontWeight: FontWeight.w900, 
              color: isSelected ? const Color(0xFF5D5FEF) : Colors.grey,
              letterSpacing: 0.5
            )
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}