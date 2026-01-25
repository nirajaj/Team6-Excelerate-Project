import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import 'study_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;
  final _comment = TextEditingController();
  final _reportController = TextEditingController(); 
  int _userRating = 5;
  bool _isEnrolled = false;
  List<Module> _curriculum = [];
  bool _isLoadingModules = true;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    if (user == null) return;

    // 1. Check if user is already enrolled
    final doc = await firestore
        .collection('enrollments')
        .doc("${user!.uid}_${widget.course.id}")
        .get();

    // 2. Fetch REAL high-density Curriculum from Wikipedia API
    final url = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=parse&page=${widget.course.title}&format=json&prop=sections&origin=*');
    try {
      final res = await http.get(url, headers: {'User-Agent': 'Learnify/1.0'});
      final data = json.decode(res.body);
      if (data['parse'] != null) {
        List sections = data['parse']['sections'];
        setState(() {
          // --- FIXED: Explicitly cast to Module and provide empty content placeholder ---
          _curriculum = sections
              .where((s) => s['level'] == "2")
              .map<Module>((s) => Module(
                  id: s['index'].toString(), 
                  title: s['line'],
                  content: "")) // Content is fetched dynamically in StudyScreen
              .toList();
        });
      }
      // Fallback if Wiki is empty
      if (_curriculum.isEmpty) {
        _curriculum = [
          Module(id: "1", title: "Technical Overview", content: "")
        ];
      }
    } catch (e) {
      debugPrint("Registry error: $e");
    }

    if (mounted) {
      setState(() {
        _isEnrolled = doc.exists;
        _isLoadingModules = false;
      });
    }
  }

  // --- REPORT POPUP LOGIC ---
  void _showReportPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text("REPORT ISSUE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: TextField(
          controller: _reportController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Describe the issue...",
            filled: true, fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              if (_reportController.text.isNotEmpty) {
                await firestore.collection('course_reports').add({
                  'courseId': widget.course.id,
                  'courseTitle': widget.course.title,
                  'userEmail': user!.email,
                  'issue': _reportController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                _reportController.clear();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Issue Logged"), backgroundColor: Colors.redAccent));
                }
              }
            },
            child: const Text("SUBMIT"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('progress').doc("${user!.uid}_${widget.course.id}").snapshots(),
        builder: (context, snapshot) {
          List done = (snapshot.hasData && snapshot.data!.exists) ? snapshot.data!.get('completed') ?? [] : [];
          double p = _curriculum.isEmpty ? 0 : (done.length / _curriculum.length).clamp(0.0, 1.0);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildHeader(context), 
                const SizedBox(height: 25),
                _buildTopicImage(),
                const SizedBox(height: 25),
                Text(widget.course.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                const SizedBox(height: 20),
                _statsRow(),
                const SizedBox(height: 30),
                Text("\"${widget.course.description}\"", style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 15)),
                const SizedBox(height: 40),
                const Text("CURRICULUM", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 15),
                
                // --- CURRICULUM LIST ---
                _isLoadingModules 
                  ? const LinearProgressIndicator() 
                  : Column(children: _curriculum.map((m) => _tile(m, done.contains(m.id))).toList()),
                
                const SizedBox(height: 40),
                _isEnrolled ? _progressUI(p) : _enrollBtn(),
                const SizedBox(height: 50),
                _ratingSection(),
                const SizedBox(height: 30),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
      Row(children: [
        const Text("REVIEW", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10)),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: _showReportPopup,
          child: const Text("REPORT", style: TextStyle(color: Color(0xFFD90429), fontWeight: FontWeight.w900, fontSize: 10)),
        ),
      ])
    ]);
  }

  Widget _buildTopicImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Image.network(widget.course.image, height: 220, width: double.infinity, fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(height: 220, color: const Color(0xFFF8FAFC), child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5D5FEF))));
        },
        errorBuilder: (c, e, s) => Container(height: 220, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(40)), child: const Icon(Icons.biotech, color: Colors.grey, size: 40))),
    );
  }

  Widget _ratingSection() => Container(
    padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(30)),
    child: Column(children: [
      const Text("SENTIMENT SIGNAL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(onPressed: () => setState(() => _userRating = i + 1), icon: Icon(i < _userRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 30)))),
      TextField(controller: _comment, decoration: const InputDecoration(hintText: "Add feedback...")),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () async {
        await firestore.collection('reviews').add({
          'userId': user!.uid,
          'user': user!.email, 
          'courseId': widget.course.id,
          'course': widget.course.title, 
          'rating': _userRating, 
          'msg': _comment.text,
          'timestamp': FieldValue.serverTimestamp()
        });
        _comment.clear();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SENTIMENT LOGGED")));
      }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: const Center(child: Text("SUBMIT", style: TextStyle(color: Colors.white)))),
    ]),
  );

  Widget _statsRow() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _st("NODES", widget.course.nodes), _st("LEVEL", widget.course.level), _st("RATING", "★ ${widget.course.rating}") ]);
  Widget _st(String l, String v) => Column(children: [Text(l, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)), Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))]);
  
  Widget _tile(Module m, bool done) => GestureDetector(
    onTap: () => _isEnrolled ? Navigator.push(context, MaterialPageRoute(builder: (c) => StudyScreen(
      courseId: widget.course.id, 
      title: m.title, 
      pageTitle: widget.course.title, 
      sectionIndex: m.id,
      totalModules: _curriculum.length, 
    ))) : null,
    child: Opacity(opacity: _isEnrolled ? 1.0 : 0.5, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(25)), child: Row(children: [Icon(done ? Icons.check_circle : Icons.play_circle_fill, color: done ? Colors.green : const Color(0xFF5D5FEF)), const SizedBox(width: 15), Expanded(child: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)))]))),
  );

  Widget _progressUI(double p) => Column(children: [ 
    LinearProgressIndicator(value: p, minHeight: 12, borderRadius: BorderRadius.circular(10), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5D5FEF))), 
    const SizedBox(height: 10), 
    Text("SYNC: ${(p * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)) 
  ]);

  Widget _enrollBtn() => ElevatedButton(onPressed: () async {
    await firestore.collection('enrollments').doc("${user!.uid}_${widget.course.id}").set({
      'userId': user!.uid, 
      'courseId': widget.course.id,
      'courseTitle': widget.course.title, 
      'enrolledAt': FieldValue.serverTimestamp(),
    });
    if (mounted) setState(() => _isEnrolled = true);
  }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D5FEF), minimumSize: const Size(double.infinity, 70), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))), child: const Text("ENROLL NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));
}