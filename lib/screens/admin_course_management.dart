import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class AdminCourseManagement extends StatefulWidget {
  const AdminCourseManagement({super.key});
  @override
  State<AdminCourseManagement> createState() => _AdminCourseManagementState();
}

class _AdminCourseManagementState extends State<AdminCourseManagement> {
  List<Course> _allApiCourses = [];
  bool _isLoading = true;
  final firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGlobalRegistry("Technology"); // Default startup
  }

  // --- FETCH 50 COURSES FROM API ---
  Future<void> _fetchGlobalRegistry(String query) async {
    setState(() => _isLoading = true);
    final url = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$query&srlimit=50&format=json&origin=*');
    try {
      final res = await http.get(url, headers: {'User-Agent': 'Learnify/1.0'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        List results = data['query']['search'];
        List<Course> temp = [];
        for (var item in results) {
          final dUrl = Uri.parse(
              'https://en.wikipedia.org/api/rest_v1/page/summary/${item['title'].toString().replaceAll(' ', '_')}');
          final dRes = await http.get(dUrl);
          if (dRes.statusCode == 200) {
            temp.add(Course.fromJson(json.decode(dRes.body)));
          }
        }
        setState(() {
          _allApiCourses = temp;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          // SEARCH & ADD ROW
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _fetchGlobalRegistry,
                  decoration: InputDecoration(
                    hintText: "Query live registry...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF5D5FEF)),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () => _showEntryModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D5FEF),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // TABLE HEADERS
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text("ENTRY", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("CLASSIFICATION", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text("MODERATION", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 30),
          // LIVE LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _allApiCourses.length,
                    itemBuilder: (context, i) => _buildModerationRow(_allApiCourses[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationRow(Course course) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('course_settings').doc(course.id).snapshots(),
      builder: (context, snapshot) {
        bool isVisible = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!.get('isVisible') ?? true
            : true;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(course.image, width: 35, height: 35, fit: BoxFit.cover, 
                      errorBuilder: (c, e, s) => const Icon(Icons.book, size: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(course.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: isVisible ? Colors.black : Colors.grey)),
                  ),
                ]),
              ),
              Expanded(
                  flex: 2,
                  child: Text("GLOBAL API",
                      style: TextStyle(
                          color: Colors.blueGrey[200],
                          fontSize: 8,
                          fontWeight: FontWeight.bold))),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: isVisible ? Colors.green : Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () async {
                    await firestore.collection('course_settings').doc(course.id).set(
                        {'isVisible': !isVisible, 'courseTitle': course.title},
                        SetOptions(merge: true));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- FIXED MODAL: NO MORE OVERFLOW ---
  void _showEntryModal(BuildContext context) {
    final titleC = TextEditingController();
    final architectC = TextEditingController();
    final urlC = TextEditingController();
    final descC = TextEditingController();
    List<Map<String, String>> modules = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20), // Essential for keyboard
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Container(
            width: 550,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8, // Limits height
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("ARCHITECTURAL ENTRY", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                const Text("DEPLOYING NEW CURRICULUM NODE", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),
                
                // Scrollable Area
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(children: [
                          Expanded(child: _modalField("CURRICULUM TITLE", "e.g. React Mastery", titleC)),
                          const SizedBox(width: 15),
                          Expanded(child: _modalField("ARCHITECT", "Jane Smith", architectC)),
                        ]),
                        const SizedBox(height: 15),
                        _modalField("ASSET URL", "https://...", urlC),
                        const SizedBox(height: 15),
                        _modalField("SYNTHESIS DESCRIPTION", "Summary...", descC, maxLines: 3),
                        const SizedBox(height: 20),
                        const Divider(),
                        const Text("MODULES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ...modules.map((m) => ListTile(title: Text(m['title']!), dense: true)),
                        TextButton.icon(
                          onPressed: () => _showAddModuleDialog(context, (newMod) => setModalState(() => modules.add(newMod))),
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text("ADD MODULE"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                // Footer
                Row(children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("ABORT"))),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleC.text.isEmpty) return;
                        await firestore.collection('courses').add({
                          'title': titleC.text, 'instructor': architectC.text, 'image': urlC.text,
                          'description': descC.text, 'category': 'Custom', 'isVisible': true,
                          'modules': modules, 'nodes': modules.length.toString(), 'level': 'Pro'
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D5FEF), 
                        foregroundColor: Colors.white, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      child: const Text("COMMIT"),
                    ),
                  ),
                ])
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showAddModuleDialog(BuildContext context, Function(Map<String, String>) onAdd) {
    final mTitle = TextEditingController();
    final mContent = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Add Lesson"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: mTitle, decoration: const InputDecoration(hintText: "Title")),
        TextField(controller: mContent, decoration: const InputDecoration(hintText: "Content")),
      ]),
      actions: [ElevatedButton(onPressed: () { onAdd({"title": mTitle.text, "content": mContent.text}); Navigator.pop(context); }, child: const Text("Add"))],
    ));
  }

  Widget _modalField(String label, String hint, TextEditingController c, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 8, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(controller: c, maxLines: maxLines, decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
    ]);
  }
}