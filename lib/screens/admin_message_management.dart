import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMessageManagement extends StatelessWidget {
  const AdminMessageManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. SIMPLE HEADER (Removed the columns to save space)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Row(
            children: [
              Icon(Icons.message_outlined, size: 14, color: Colors.grey),
              SizedBox(width: 8),
              Text("ACTIVE INQUIRY LOG", 
                style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
        ),
        const Divider(color: Color(0xFFF1F5F9), height: 1),

        // 2. LIVE MESSAGES LIST
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('support_requests')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF5D5FEF)));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              // Filter for 'active' messages
              var activeDocs = snapshot.data!.docs.where((doc) => doc['status'] == 'active').toList();

              if (activeDocs.isEmpty) {
                return _buildEmptyState(msg: "ALL INQUIRIES PROCESSED");
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                itemCount: activeDocs.length,
                itemBuilder: (context, i) {
                  return _buildModernMessageCard(activeDocs[i], context);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernMessageCard(DocumentSnapshot doc, BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    String name = (data['identity'] ?? "Anonymous").toString().toUpperCase();
    String email = (data['email'] ?? "No Terminal").toString().toLowerCase();
    String subject = (data['subject'] ?? "General Query").toString().toUpperCase();
    String message = data['message'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW: Identity + Mark Read Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF1F5F9),
                child: Text(name[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D5FEF))),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    Text(email, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // THE MODERATION BUTTON (FIXED: No longer squished)
              TextButton(
                onPressed: () async {
                  await doc.reference.update({'status': 'archived'});
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("MARK READ", 
                  style: TextStyle(color: Color(0xFF5D5FEF), fontWeight: FontWeight.w900, fontSize: 9)),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
          ),

          // SUBJECT
          const Text("SUBJECT VECTOR", 
            style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(subject, 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF5D5FEF), letterSpacing: 0.5)),
          
          const SizedBox(height: 15),

          // MESSAGE BODY
          const Text("DETAILED LOG", 
            style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(message, 
            style: const TextStyle(color: Color(0xFF334155), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState({String msg = "NO ACTIVE INQUIRIES"}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons. inbox_outlined, size: 40, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text(msg, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
        ],
      ),
    );
  }
}