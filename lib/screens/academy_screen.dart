import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Added Firestore
import '../models/course_model.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Course> _wikiCourses = []; // Courses from Wikipedia API
  bool _isLoading = true;
  final String _defaultQuery = "Computer Science Skills"; 

  @override
  void initState() {
    super.initState();
    _fetchWikiRegistry(_defaultQuery);
  }

  // --- FETCH FROM WIKIPEDIA API ---
  Future<void> _fetchWikiRegistry(String query) async {
    setState(() => _isLoading = true);
    final url = Uri.parse('https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$query&srlimit=10&format=json&origin=*');
    
    try {
      final res = await http.get(url, headers: {'User-Agent': 'Learnify/1.0'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        List results = data['query']['search'];
        List<Course> tempCourses = [];
        for (var item in results) {
          final dUrl = Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/${item['title'].toString().replaceAll(' ', '_')}');
          final dRes = await http.get(dUrl, headers: {'User-Agent': 'Learnify/1.0'});
          if (dRes.statusCode == 200) {
            tempCourses.add(Course.fromJson(json.decode(dRes.body)));
          }
        }
        setState(() {
          _wikiCourses = tempCourses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text("REGISTRY", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
        
        // --- SEARCH BAR SECTION ---
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _searchController,
            onSubmitted: (val) => _fetchWikiRegistry(val),
            onChanged: (value) {
              setState(() {}); 
              if (value.isEmpty) _fetchWikiRegistry(_defaultQuery);
            },
            decoration: InputDecoration(
              hintText: "Search Millions of Vectors...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF5D5FEF)),
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      _fetchWikiRegistry(_defaultQuery);
                    },
                  )
                : null,
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),

        // --- RESULTS LIST (COMBINED FIREBASE + WIKI) ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // 2. Fetching Admin-managed courses from Firebase
            stream: FirebaseFirestore.instance.collection('courses').snapshots(),
            builder: (context, snapshot) {
              List<Course> firebaseCourses = [];
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  var course = Course.fromJson(doc.data() as Map<String, dynamic>);
                  // --- 3. THE VISIBILITY FILTER ---
                  // Only add the course if it is marked as visible by the Admin
                  if (course.isVisible) {
                    firebaseCourses.add(course);
                  }
                }
              }

              // Combine Admin courses and Wikipedia courses
              List<Course> combinedList = [...firebaseCourses, ..._wikiCourses];

              if (_isLoading && combinedList.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF5D5FEF)));
              }

              if (combinedList.isEmpty) {
                return const Center(child: Text("No vectors found in active registry."));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                itemCount: combinedList.length,
                itemBuilder: (context, i) => CourseCard(
                  course: combinedList[i], 
                  onApply: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (c) => CourseDetailScreen(course: combinedList[i]))
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}