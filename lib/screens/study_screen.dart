import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudyScreen extends StatefulWidget {
  final String courseId, title, pageTitle, sectionIndex;
  final int totalModules; // <--- UPDATED: Receives total count for Mastery logic
  
  const StudyScreen({
    super.key, 
    required this.courseId, 
    required this.title, 
    required this.pageTitle, 
    required this.sectionIndex,
    required this.totalModules, // <--- UPDATED
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  String _html = ""; 
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSectionContent();
  }

  // --- FETCH SPECIFIC ACADEMIC TEXT FROM WIKIPEDIA ---
  Future<void> _fetchSectionContent() async {
    final url = Uri.parse(
      'https://en.wikipedia.org/w/api.php?action=parse&page=${widget.pageTitle}&section=${widget.sectionIndex}&prop=text&format=json&origin=*'
    );
    
    try {
      final res = await http.get(url, headers: {'User-Agent': 'Learnify/1.0'});
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['parse'] != null && data['parse']['text'] != null) {
          setState(() { 
            _html = data['parse']['text']['*']; 
            _loading = false; 
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) { 
      if (mounted) setState(() => _loading = false); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        title: Text(widget.title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5))
      ),
      body: _loading 
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF5D5FEF))) 
      : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 1.1)),
            const SizedBox(height: 10),
            const Text("ACADEMIC VECTOR SOURCE: WIKIPEDIA", style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const Divider(height: 40, thickness: 2, color: Color(0xFFF1F5F9)),
            
            // RENDERS HIGH DENSITY TEXT
            HtmlWidget(
              _html, 
              textStyle: const TextStyle(fontSize: 17, height: 1.7, color: Color(0xFF1E293B)),
            ),
            
            const SizedBox(height: 50),
            
            // --- UPDATED: FINISH BUTTON SAVES TOTAL MODULES FOR MASTERY CALCULATION ---
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('progress').doc("${user.uid}_${widget.courseId}").set({
                    'userId': user.uid,
                    'courseTitle': widget.pageTitle,
                    'completed': FieldValue.arrayUnion([widget.sectionIndex]),
                    'totalModules': widget.totalModules, // <--- SAVED FOR MASTERY LOGIC
                    'lastUpdated': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                }
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A), 
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 70), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text("FINISH MODULE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}