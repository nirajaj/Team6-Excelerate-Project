import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/header_widget.dart';
import 'dashboard_view.dart';
import 'academy_screen.dart';
import 'login_screen.dart';

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

    // 1. UPDATE THE DASHBOARD IN THE LIST
    final List<Widget> _pages = [
      DashboardView(
        firstName: firstName, 
        pulseAnimation: Tween(begin: 0.1, end: 0.3).animate(_pulseController),
        onAccessAcademy: () {
          // THIS CHANGES THE TAB TO ACADEMY (Index 1)
          setState(() {
            _selectedIndex = 1;
          });
        },
      ),
      const AcademyScreen(), 
      const Center(child: Text("Support Screen Active")), 
      const Center(child: Text("Profile Screen Active")), 
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              currentView: "HOME",
              onNavigate: (view) {},
              onLogout: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey)),
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