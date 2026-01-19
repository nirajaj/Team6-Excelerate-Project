import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For User data
import 'package:cloud_firestore/cloud_firestore.dart'; // For Database logic

class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  String _activeTab = 'CURRICULUM'; 
  
  // --- Firebase Enrollment States ---
  bool _isEnrolled = false;
  bool _isLoading = true; // Shows a loader while checking database

  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkEnrollment();
  }

  // 1. Check if this specific user is already enrolled in this specific course
  Future<void> _checkEnrollment() async {
    if (user == null) return;
    
    try {
      final doc = await _firestore
          .collection('enrollments')
          .doc("${user!.email}_${widget.course['title']}")
          .get();

      if (mounted) {
        setState(() {
          _isEnrolled = doc.exists;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Save Enrollment to Firebase
  Future<void> _handleEnrollment() async {
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _firestore
          .collection('enrollments')
          .doc("${user!.email}_${widget.course['title']}")
          .set({
        'userEmail': user!.email,
        'courseTitle': widget.course['title'],
        'progress': 0, // Default progress
        'enrolledAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _isEnrolled = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Enrollment Error: $e");
    }
  }

  // --- Brand Colors ---
  final Color _indigo600 = const Color(0xFF5D5FEF);
  final Color _slate900 = const Color(0xFF0F172A);
  final Color _slate400 = const Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopNav(context),
              const SizedBox(height: 25),
              _buildHeroSection(course),
              const SizedBox(height: 30),
              _buildStatsRow(course),
              const SizedBox(height: 35),
              Text(
                "\"${course['description']}\"",
                style: TextStyle(color: _slate400.withOpacity(0.8), fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, height: 1.5),
              ),
              const SizedBox(height: 35),
              _buildAICard(),
              const SizedBox(height: 40),
              _buildTabSwitcher(),
              const SizedBox(height: 25),
              _activeTab == 'CURRICULUM' ? _buildCurriculumList() : _buildDiscussionPlaceholder(),
              const SizedBox(height: 40),

              // --- DYNAMIC ENROLL SECTION ---
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildEnrollSection(),

              const SizedBox(height: 25),
              _buildArchitectCard(course),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: _indigo600, size: 18),
            label: Text("ACADEMY BACK", style: TextStyle(color: _indigo600, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          ),
          const Row(children: [
            Text("REVIEW", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
            SizedBox(width: 15),
            Text("REPORT", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          ])
        ],
      ),
    );
  }

  Widget _buildHeroSection(Map<String, dynamic> course) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        image: DecorationImage(image: NetworkImage(course['image']), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, _slate900.withOpacity(0.8)]),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _indigo600, borderRadius: BorderRadius.circular(10)),
              child: Text(course['category'], style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 10),
            Text(course['title'], style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> course) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem("RATING", "★ ${course['rating']}"),
        _statItem("NODES", course['nodes'] ?? "1,250"),
        _statItem("LEVEL", course['level'] ?? "Pro", isIndigo: true),
      ],
    );
  }

  Widget _statItem(String label, String val, {bool isIndigo = false}) {
    return Column(children: [
      Text(label, style: TextStyle(color: _slate400, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      const SizedBox(height: 5),
      Text(val, style: TextStyle(color: isIndigo ? _indigo600 : _slate900, fontSize: 18, fontWeight: FontWeight.w900)),
    ]);
  }

  Widget _buildAICard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: _slate900, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("AI-SYNTHESIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Text("ANALYZE", style: TextStyle(color: _slate900, fontSize: 10, fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_tabBtn("CURRICULUM"), _tabBtn("DISCUSSION")],
      ),
    );
  }

  Widget _tabBtn(String label) {
    bool isSel = _activeTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(color: isSel ? _slate900 : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(color: isSel ? Colors.white : _slate400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildCurriculumList() {
    final List modules = widget.course['modules'] ?? [];
    return Column(
      children: List.generate(modules.length, (index) {
        final module = modules[index];
        return _curriculumItem((index + 1).toString(), module['title'], module['duration']);
      }),
    );
  }

  Widget _curriculumItem(String num, String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(num, style: TextStyle(color: _slate400, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: _slate900, fontWeight: FontWeight.w900, fontSize: 16)),
          Text(time, style: TextStyle(color: _slate400, fontSize: 10, fontWeight: FontWeight.bold)),
        ])
      ]),
    );
  }

  Widget _buildDiscussionPlaceholder() {
    return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Registry is empty.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))));
  }

  // --- THE ENROLL SECTION (CHANGES UI BASED ON FIREBASE DATA) ---
  Widget _buildEnrollSection() {
    if (_isEnrolled) {
      // VIEW: ENROLLED STATE (Screenshot 2)
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
        child: Column(
          children: [
            Text("ELITE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: _slate900)),
            const SizedBox(height: 25),
            // Authenticated Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD1FAE5))),
              child: const Center(child: Text("AUTHENTICATED", style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))),
            ),
            const SizedBox(height: 25),
            // Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("SYNC PROGRESS", style: TextStyle(color: _slate400, fontSize: 10, fontWeight: FontWeight.w900)),
                Text("0%", style: TextStyle(color: _indigo600, fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(value: 0.05, minHeight: 8, backgroundColor: Color(0xFFF8FAFC), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5D5FEF))),
            ),
            const SizedBox(height: 30),
            // Resume Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: _slate900, borderRadius: BorderRadius.circular(20)),
              child: const Center(child: Text("RESUME STREAM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5))),
            )
          ],
        ),
      );
    } else {
      // VIEW: NOT ENROLLED (Screenshot 1)
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), border: Border.all(color: const Color(0xFFF1F5F9)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
        child: Column(
          children: [
            Text("ELITE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: _slate900)),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: _handleEnrollment, // Triggers Firebase Save
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(color: _indigo600, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: _indigo600.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
                child: const Center(child: Text("ENROLL NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5))),
              ),
            )
          ],
        ),
      );
    }
  }

  Widget _buildArchitectCard(Map<String, dynamic> course) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: _slate900, borderRadius: BorderRadius.circular(35)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 25, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=${course['instructor']}")),
              const SizedBox(width: 15),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(course['instructor'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                Text("ARCHITECT", style: TextStyle(color: _indigo600, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ])
            ],
          ),
          const SizedBox(height: 20),
          Text("\"Expert in high-performance curriculum architecture.\"", style: TextStyle(color: _slate400, fontSize: 13, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}