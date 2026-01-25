import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserManagement extends StatelessWidget {
  const AdminUserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          // 1. TABLE HEADERS (ENTRY, CLASSIFICATION, MODERATION)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text("ENTRY", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))),
                Expanded(flex: 2, child: Text("CLASSIFICATION", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))),
                Expanded(flex: 1, child: Text("MODERATION", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1),

          // 2. LIVE USER LIST FROM FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text("NO USERS REGISTERED"));

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    var doc = snapshot.data!.docs[i];
                    return _buildUserRow(doc);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String name = data['name'] ?? "Unknown Learner";
    String email = data['email'] ?? "No Email Terminal";
    // Check if user is blocked (Default to active)
    bool isBlocked = data.containsKey('status') && data['status'] == 'blocked';

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          // ENTRY (Avatar + Name + Email)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF1F5F9),
                  backgroundImage: NetworkImage("https://api.dicebear.com/7.x/avataaars/png?seed=$name"),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                      Text(email, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // CLASSIFICATION (Status Badge)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isBlocked ? const Color(0xFFFFEFEF) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBlocked ? "BLOCKED" : "ACTIVE",
                  style: TextStyle(
                    color: isBlocked ? const Color(0xFFD90429) : const Color(0xFF065F46),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // MODERATION (Action Button)
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () async {
                // Toggle status in Firebase
                await doc.reference.update({
                  'status': isBlocked ? 'active' : 'blocked',
                });
              },
              child: Text(
                isBlocked ? "UNBLOCK" : "RESTRICT",
                style: TextStyle(
                  color: isBlocked ? Colors.green : const Color(0xFFD90429),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}