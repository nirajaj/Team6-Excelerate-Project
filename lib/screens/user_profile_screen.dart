import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- DYNAMIC 2D CHARACTER LOGIC (NOTION STYLE) ---
  String _getAvatarUrl(String name) {
    String n = name.toLowerCase();
    bool isGirl = n.endsWith('a') || n.endsWith('i') || n.endsWith('e') || n.contains('SARA');
    if (isGirl) {
      return "https://api.dicebear.com/7.x/notionists/png?seed=Sasha&backgroundColor=b6e3f4";
    } else {
      return "https://api.dicebear.com/7.x/notionists/png?seed=Felix&backgroundColor=c0aede";
    }
  }

  @override
  Widget build(BuildContext context) {
    // FORCE ALL CAPS FOR NAME AND EMAIL
    String fullName = (user?.displayName ?? "STUDENT").toUpperCase();
    String email = (user?.email ?? "USER TERMINAL").toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // 1. MAIN PROFILE CARD
                _buildMainProfileCard(fullName, email),
                const SizedBox(height: 30),

                // 2. REGISTRY HUB (Enrolled Courses)
                _buildRegistryHub(),
                const SizedBox(height: 30),

                // 3. MASTERY SPECTRA (Real Progress Tracking)
                _buildMasterySpectra(),
                const SizedBox(height: 30),

                // 4. CERTIFICATION CARD
                _buildCertificationCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainProfileCard(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(30), // Slightly reduced padding for better fit
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align image with top of text
            children: [
              // PREMIUM 2D CHARACTER
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(image: NetworkImage(_getAvatarUrl(name)), fit: BoxFit.cover),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- FIXED: WRAP PREVENTS THE RED OVERFLOW ERROR ---
                    Wrap(
                      spacing: 8, // Space between badges
                      runSpacing: 8, // Space if they wrap to next line
                      children: [
                        _badge("PLATINUM TIER LEARNER", Colors.black),
                        _badge("ACADEMIC YEAR 2024", const Color(0xFF5D5FEF).withOpacity(0.1), textColor: const Color(0xFF5D5FEF)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // Name
                    Text(
                      name, 
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1.2)
                    ),
                    const SizedBox(height: 5),
                    
                    // Email - FittedBox prevents long emails from breaking the UI
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        email, 
                        style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 40),
          
          // STATS BAR (SYNCED WITH FIREBASE)
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('progress').where('userId', isEqualTo: user?.uid).snapshots(),
            builder: (context, snapshot) {
              int masteryAchieved = 0;
              int activeStreams = snapshot.hasData ? snapshot.data!.docs.length : 0;

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data.containsKey('completed') && data.containsKey('totalModules')) {
                    List completed = data['completed'] ?? [];
                    int total = data['totalModules'] ?? 0;
                    if (completed.length >= total && total > 0) {
                      masteryAchieved++;
                    }
                  }
                }
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem("MASTERY ACHIEVED", masteryAchieved.toString()),
                  _statItem("ACTIVE STREAMS", activeStreams.toString()),
                  _statItem("GLOBAL STANDING", "ELITE 1%"),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildRegistryHub() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("REGISTRY HUB", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontStyle: FontStyle.italic)),
          const Text("CURRICULAR ENROLLMENT LOG", style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('enrollments').where('userId', isEqualTo: user?.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyPlaceholder("AWAITING PRIMARY ENROLLMENT DATA");
              }
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  String title = data.containsKey('courseTitle') ? data['courseTitle'] : data['courseId'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bookmark_added, color: Color(0xFF5D5FEF)),
                    title: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text("ENROLLED", style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildMasterySpectra() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(40)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MASTERY SPECTRA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, fontStyle: FontStyle.italic)),
          const SizedBox(height: 25),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('progress').where('userId', isEqualTo: user?.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("VOID DATA", style: TextStyle(color: Colors.white10, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2))));
              }
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  List completed = data['completed'] ?? [];
                  int total = data['totalModules'] ?? 10;
                  String title = data.containsKey('courseTitle') ? data['courseTitle'] : "COURSE VECTOR";
                  
                  double progressValue = (completed.length / total).clamp(0.1, 1.0); 

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progressValue, 
                          minHeight: 8, 
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: Colors.white10, 
                          valueColor: AlwaysStoppedAnimation(progressValue == 1.0 ? Colors.green : const Color(0xFF5D5FEF))
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String text) {
    return Container(
      height: 100, width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF1F5F9), width: 2), borderRadius: BorderRadius.circular(30)),
      child: Center(child: Text(text, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 8, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildCertificationCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF5D5FEF), Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(40)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("ELITE\nCERTIFICATION", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 1)),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF5D5FEF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("REQUEST VALIDATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
      ]),
    );
  }

  Widget _badge(String text, Color bg, {Color textColor = Colors.white}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Text(text, style: TextStyle(color: textColor, fontSize: 7, fontWeight: FontWeight.bold)));
  }

  Widget _statItem(String label, String value) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 7, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
    ]);
  }
}