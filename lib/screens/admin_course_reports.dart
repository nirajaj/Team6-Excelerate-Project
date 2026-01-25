import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCourseReports extends StatelessWidget {
  const AdminCourseReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          // 1. TABLE HEADERS (INCIDENT SOURCE, REPORTED ENTITY, MODERATION)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text("INCIDENT SOURCE", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))),
                Expanded(flex: 3, child: Text("REPORTED ENTITY", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))),
                Expanded(flex: 1, child: Text("MODERATION", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9)),

          // 2. LIVE REPORTS LIST FROM FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('course_reports').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text("NO SECURITY BREACHES LOGGED"));

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    var doc = snapshot.data!.docs[i];
                    return _buildReportRow(doc, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(DocumentSnapshot doc, BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    String reporterEmail = data['userEmail'] ?? "Anonymous";
    String courseTitle = data['courseTitle'] ?? "Unknown Vector";
    String issueText = data['issue'] ?? "No log provided.";

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // INCIDENT SOURCE (Reporter Info)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reporterEmail.split('@')[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                Text("ID: ${doc.id.substring(0, 5).toUpperCase()}", style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // REPORTED ENTITY (Target + Message + Badge)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Against: $courseTitle", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text("\"$issueText\"", style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                // PENDING BADGE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                  child: const Text("PENDING", style: TextStyle(color: Color(0xFF92400E), fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // MODERATION (Dismiss Button)
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () async {
                // DELETE FROM FIREBASE
                await doc.reference.delete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incident Cleared from Registry")));
                }
              },
              child: const Text(
                "DISMISS",
                style: TextStyle(color: Color(0xFF5D5FEF), fontWeight: FontWeight.w900, fontSize: 10),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}