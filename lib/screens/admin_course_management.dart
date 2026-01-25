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

  @override
  void initState() {
    super.initState();
    _fetchGlobalRegistry();
  }

  Future<void> _fetchGlobalRegistry() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=Technology&srlimit=15&format=json&origin=*');
    try {
      final res = await http.get(url, headers: {'User-Agent': 'Learnify/1.0'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        List results = data['query']['search'];
        List<Course> temp = [];
        for (var item in results) {
          final dUrl = Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/${item['title'].toString().replaceAll(' ', '_')}');
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
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _showEntryModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D5FEF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("INITIATE COURSE ENTRY +", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text("ENTRY", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("TYPE", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("MODERATION", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 30),
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
        bool isVisible = true;
        if (snapshot.hasData && snapshot.data!.exists) {
          isVisible = snapshot.data!.get('isVisible') ?? true;
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            children: [
              Expanded(flex: 3, child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(course.image, width: 35, height: 35, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.book))),
                const SizedBox(width: 12),
                Expanded(child: Text(course.title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isVisible ? Colors.black : Colors.grey))),
              ])),
              Expanded(flex: 2, child: Text("GLOBAL API", style: TextStyle(color: Colors.blueGrey[200], fontSize: 8, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                  icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: isVisible ? Colors.green : Colors.redAccent, size: 18),
                  onPressed: () async {
                    await firestore.collection('course_settings').doc(course.id).set({'isVisible': !isVisible, 'courseTitle': course.title}, SetOptions(merge: true));
                  },
                ),
              ])),
            ],
          ),
        );
      },
    );
  }

  // --- KEYBOARD-FIXED MODAL ---
  void _showEntryModal(BuildContext context) {
    final titleC = TextEditingController();
    final architectC = TextEditingController();
    final urlC = TextEditingController();
    final descC = TextEditingController();
    List<Map<String, String>> modules = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            child: Container(
              width: 500,
              // Use constrained height so the middle part can scroll
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- FIXED HEADER ---
                  const Text("ARCHITECTURAL ENTRY", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                  const Text("DEPLOYING NEW CURRICULUM NODE", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),

                  // --- SCROLLABLE BODY ---
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(child: _modalField("CURRICULUM TITLE", "e.g. Quantum React", titleC)),
                            const SizedBox(width: 15),
                            Expanded(child: _modalField("ARCHITECT", "Jane Smith", architectC)),
                          ]),
                          const SizedBox(height: 15),
                          _modalField("ASSET URL", "https://image-url.com", urlC),
                          const SizedBox(height: 15),
                          _modalField("SYNTHESIS DESCRIPTION", "Elaborate...", descC, maxLines: 3),
                          
                          const SizedBox(height: 25),
                          const Divider(),
                          const Text("CURRICULUM MODULES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                          const SizedBox(height: 15),

                          ...modules.asMap().entries.map((entry) {
                            int idx = entry.key;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(15)),
                              child: Row(children: [
                                CircleAvatar(radius: 10, backgroundColor: Colors.black, child: Text("${idx+1}", style: const TextStyle(fontSize: 8, color: Colors.white))),
                                const SizedBox(width: 10),
                                Expanded(child: Text(modules[idx]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => setModalState(() => modules.removeAt(idx)))
                              ]),
                            );
                          }).toList(),

                          Center(
                            child: TextButton.icon(
                              onPressed: () => _showAddModuleDialog(context, (newMod) => setModalState(() => modules.add(newMod))),
                              icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF5D5FEF)),
                              label: const Text("ADD STUDY MODULE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- FIXED FOOTER ---
                  const SizedBox(height: 30),
                  Row(children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("ABORT", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleC.text.isEmpty) return;
                          await firestore.collection('courses').add({
                            'title': titleC.text, 'instructor': architectC.text, 'image': urlC.text, 
                            'description': descC.text, 'category': 'Development', 'isVisible': true, 
                            'modules': modules, 'rating': '5.0', 'nodes': modules.length.toString(), 'level': 'Pro'
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D5FEF), foregroundColor: Colors.white, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: const Text("COMMIT NODE", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ])
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _showAddModuleDialog(BuildContext context, Function(Map<String, String>) onAdd) {
    final mTitle = TextEditingController();
    final mContent = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: const Text("STUDY CONTENT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: mTitle, decoration: const InputDecoration(hintText: "Lesson Title")),
        const SizedBox(height: 15),
        TextField(controller: mContent, maxLines: 5, decoration: const InputDecoration(hintText: "Study Material...")),
      ]),
      actions: [ElevatedButton(onPressed: () { if (mTitle.text.isNotEmpty) { onAdd({"title": mTitle.text, "content": mContent.text, "duration": "15:00"}); Navigator.pop(context); } }, child: const Text("ADD"))],
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