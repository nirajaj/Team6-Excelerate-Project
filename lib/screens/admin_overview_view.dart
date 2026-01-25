import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOverviewView extends StatelessWidget {
  const AdminOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width to decide if we show 1 or 2 columns
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // --- 1. STATS GRID (2 columns on mobile) ---
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isMobile ? 0.9 : 1.1,
            children: [
              _buildStatCard("LEARNERS", "users", Icons.bolt, Colors.green),
              _buildStatCard("ENROLLS", "enrollments", Icons.electric_bolt_rounded, Colors.indigoAccent),
              _buildStatCard("REPORTS", "course_reports", Icons.bolt_sharp, Colors.redAccent),
              _buildStatCard("SUPPORT", "support_requests", Icons.bolt, Colors.orange),
            ],
          ),
          const SizedBox(height: 30),

          // --- 2. MARKET ABSORPTION (Full Width on Mobile) ---
          _buildMarketAbsorption(),
          const SizedBox(height: 20),

          // --- 3. RECENT SENTIMENT (Full Width on Mobile) ---
          _buildSentimentSection(),
          
          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String collection, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "...";
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
              FittedBox(
                child: Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMarketAbsorption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MARKET ABSORPTION", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),
          _absorptionBar("REACT ARCHITECTURE", 0.72),
          _absorptionBar("UI/UX MASTERCLASS", 0.80),
          _absorptionBar("WEB3 MASTERY", 0.76),
        ],
      ),
    );
  }

  Widget _absorptionBar(String title, double p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text("${(p * 100).toInt()}%", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: p, minHeight: 4, borderRadius: BorderRadius.circular(10), backgroundColor: const Color(0xFFF1F5F9), valueColor: const AlwaysStoppedAnimation(Color(0xFF5D5FEF))),
      ]),
    );
  }

  Widget _buildSentimentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("RECENT SIGNAL SENTIMENT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          const SizedBox(height: 15),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reviews').orderBy('timestamp', descending: true).limit(3).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text("NO RECENT SIGNALS", style: TextStyle(color: Colors.grey, fontSize: 10));
              }
              return Column(
                children: snapshot.data!.docs.map((doc) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(15)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(doc['user'].toString().split('@')[0].toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                      Text("★ ${doc['rating']}", style: const TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 5),
                    Text("\"${doc['msg']}\"", style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
                  ]),
                )).toList(),
              );
            }
          )
        ],
      ),
    );
  }
}