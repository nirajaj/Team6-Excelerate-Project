import 'package:flutter/material.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart'; 

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  String _searchQuery = "";
  String _activeCategory = "ALL";

  // --- FULL DATASET OF 8 COURSES WITH UNIQUE MODULES ---
  final List<Map<String, dynamic>> _courses = [
    {
      "title": "Scalable React Patterns",
      "description": "Master building high-performance web applications with micro-frontends.",
      "category": "DEVELOPMENT",
      "instructor": "Jane Smith",
      "rating": "4.8",
      "nodes": "1,250",
      "level": "Pro",
      "image": "https://images.pexels.com/photos/11035471/pexels-photo-11035471.jpeg?auto=compress&cs=tinysrgb&w=800",
      "modules": [
        {"title": "Architectural Patterns", "duration": "25:00"},
        {"title": "State Synchronization", "duration": "35:00"},
        {"title": "Performance Auditing", "duration": "45:00"}
      ]
    },
    {
      "title": "UI/UX Design Masterclass",
      "description": "Learn the psychology of design and high-fidelity prototyping.",
      "category": "DESIGN",
      "instructor": "Alex Rivera",
      "rating": "4.9",
      "nodes": "840",
      "level": "Expert",
      "image": "https://images.pexels.com/photos/196644/pexels-photo-196644.jpeg?auto=compress&cs=tinysrgb&w=800",
      "modules": [
        {"title": "Visual Hierarchy", "duration": "15:00"},
        {"title": "Design Systems 101", "duration": "50:00"},
        {"title": "Prototyping Logic", "duration": "30:00"}
      ]
    },
    {
      "title": "Full-Stack Web3 Mastery",
      "description": "Build the decentralized future with Solidity and Ethers.js.",
      "category": "BLOCKCHAIN",
      "instructor": "Marcus Aurelius",
      "rating": "4.7",
      "nodes": "2,100",
      "level": "Elite",
      "image": "https://images.pexels.com/photos/844124/pexels-photo-844124.jpeg?auto=compress&cs=tinysrgb&w=800",
      "modules": [
        {"title": "Smart Contract Security", "duration": "40:00"},
        {"title": "IPFS Integration", "duration": "20:00"},
        {"title": "Gas Optimization", "duration": "55:00"}
      ]
    },
    {
      "title": "Machine Learning Pipelines",
      "description": "Automate ML workflows using Docker and Kubernetes.",
      "category": "DATA SCIENCE",
      "instructor": "Dr. Emily Chen",
      "rating": "4.9",
      "nodes": "3,400",
      "level": "Pro",
      "image": "https://images.pexels.com/photos/2599244/pexels-photo-2599244.jpeg?auto=compress&cs=tinysrgb&w=800",
      "modules": [
        {"title": "Data Ingestion Nodes", "duration": "30:00"},
        {"title": "Model Training", "duration": "1:20:00"},
        {"title": "Deployment Protocols", "duration": "45:00"}
      ]
    },
    {
      "title": "Enterprise Flutter Architecture",
      "description": "Build native apps for every screen. Focus on Clean Architecture and BLoC.",
      "category": "DEVELOPMENT",
      "instructor": "David Lee",
      "rating": "4.6",
      "nodes": "5,400",
      "level": "Elite",
      "image": "https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg?auto=compress&cs=tinysrgb&w=800",
      "modules": [
        {"title": "Clean Architecture", "duration": "40:00"},
        {"title": "BLoC Pattern Deep Dive", "duration": "55:00"},
        {"title": "Automated Testing", "duration": "30:00"}
      ]
    },
    {
      "title": "Cybersecurity Operations",
      "description": "Defend against modern threats and incident response.",
      "category": "SECURITY",
      "instructor": "Sarah Connor",
      "rating": "4.8",
      "nodes": "1,120",
      "level": "Expert",
      "image": "https://images.pexels.com/photos/60504/security-protection-anti-virus-software-60504.jpeg?auto=compress&cs=tinysrgb&w=800",
      "modules": [
        {"title": "Penetration Testing", "duration": "60:00"},
        {"title": "Network Forensics", "duration": "45:00"},
        {"title": "Threat Intelligence", "duration": "35:00"}
      ]
    },
    {
      "title": "Product Leadership Strategy",
      "description": "Transition from management to leadership and drive product-led growth.",
      "category": "BUSINESS",
      "instructor": "Robert Sterling",
      "rating": "4.9",
      "nodes": "1,800",
      "level": "Expert",
      "image": "https://images.pexels.com/photos/3183150/pexels-photo-3183150.jpeg?auto=compress&cs=tinysrgb&w=800",
      "modules": [
        {"title": "Defining Vision", "duration": "20:00"},
        {"title": "Cross-functional Alignment", "duration": "40:00"},
        {"title": "Product-led Growth", "duration": "50:00"}
      ]
    },
    {
      "title": "Cloud Native AWS Solutions",
      "description": "Master AWS services for high-availability and serverless infrastructure.",
      "category": "CLOUD",
      "instructor": "Kevin Mitnick",
      "rating": "4.7",
      "nodes": "2,900",
      "level": "Pro",
      "image": "https://images.pexels.com/photos/1148820/pexels-photo-1148820.jpeg?auto=compress&cs=tinysrgb&w=800",
      "modules": [
        {"title": "Lambda Deep Dive", "duration": "35:00"},
        {"title": "DynamoDB Schema", "duration": "45:00"},
        {"title": "CloudFront Security", "duration": "25:00"}
      ]
    },
  ];

  final List<String> _categories = ["ALL", "DEVELOPMENT", "DESIGN", "BLOCKCHAIN", "DATA SCIENCE", "SECURITY", "BUSINESS", "CLOUD"];

  @override
  Widget build(BuildContext context) {
    final filtered = _courses.where((c) {
      final matchesQuery = c['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _activeCategory == "ALL" || c['category'] == _activeCategory;
      return matchesQuery && matchesCat;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6, height: 45,
                decoration: BoxDecoration(color: const Color(0xFF5D5FEF), borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(width: 15),
              const Text("REGISTRY", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 40),
          _buildSearchBar(),
          const SizedBox(height: 30),
          _buildCategoryPills(),
          const SizedBox(height: 40),
          ...filtered.map((course) => CourseCard(
            course: course,
            onApply: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CourseDetailScreen(course: course)),
              );
            },
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: "Query registry...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFFCBD5E1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _activeCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _activeCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Center(child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.w900))),
            ),
          );
        },
      ),
    );
  }
}