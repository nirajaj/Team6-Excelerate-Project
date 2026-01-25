import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'admin_overview_view.dart';
import 'admin_course_management.dart';
import 'admin_user_management.dart';
import 'admin_course_reports.dart';
import 'admin_message_management.dart'; // 1. IMPORT THE NEW MESSAGE SYSTEM

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTab = 0; // 0: Overview, 1: Courses, 2: Users, 3: Reports, 4: Messages

  final Color _primaryPurple = const Color(0xFF5D5FEF);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- FIXED ADMIN HEADER ---
            _buildAdminHeader(),

            // --- RESPONSIVE TITLE & TABS SECTION ---
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              child: Flex(
                direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ELITE GOVERNANCE", 
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -1)),
                      const Text("PLATFORM COMMAND CENTER", 
                        style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      if (isSmallScreen) const SizedBox(height: 20),
                    ],
                  ),
                  
                  _buildTopTabs(),
                ],
              ),
            ),

            const Divider(color: Color(0xFFF1F5F9), height: 30),
            
            // --- DYNAMIC CONTENT SWITCHER (NOW ALL TABS ARE MODULAR) ---
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  const AdminOverviewView(),       // Tab 0
                  const AdminCourseManagement(),   // Tab 1
                  const AdminUserManagement(),     // Tab 2
                  const AdminCourseReports(),      // Tab 3
                  const AdminMessageManagement(),  // Tab 4: REAL HIGH-FIDELITY MESSAGES
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: _primaryPurple, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)))),
          const SizedBox(width: 10),
          Text('Learnify', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _primaryPurple)),
          const Spacer(),
          const Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text("NIRAJ ADMIN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
            Text("ADMIN", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF5D5FEF))),
          ]),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(8), 
              decoration: BoxDecoration(color: const Color(0xFFFFEFEF), borderRadius: BorderRadius.circular(10)), 
              child: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFD90429))
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            _tabItem(0, "OVERVIEW"),
            _tabItem(1, "COURSES"),
            _tabItem(2, "USERS"),
            _tabItem(3, "REPORTS"),
            // MESSAGES TAB WITH DYNAMIC NOTIFICATION BADGE
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('support_requests').where('status', isEqualTo: 'active').snapshots(),
              builder: (context, snapshot) {
                int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return _tabItem(4, "MESSAGES", badgeCount: count);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(int index, String label, {int badgeCount = 0}) {
    bool isSel = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : Colors.transparent, 
          borderRadius: BorderRadius.circular(12), 
          boxShadow: isSel ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : null
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isSel ? _primaryPurple : Colors.grey)),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFF43F5E), shape: BoxShape.circle),
                child: Text(badgeCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
      ),
    );
  }
}