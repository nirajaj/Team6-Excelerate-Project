import 'package:flutter/material.dart';
import '../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onApply;
  const CourseCard({super.key, required this.course, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onApply,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(45), 
          border: Border.all(color: const Color(0xFFF1F5F9)), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24)]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // --- PROFESSIONAL IMAGE LOADER ---
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(45)), 
              child: Image.network(
                course.image, 
                height: 220, 
                width: double.infinity, 
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 220, 
                    color: const Color(0xFFF8FAFC),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5D5FEF))),
                  );
                },
                errorBuilder: (c, e, s) => Container(
                  height: 220, 
                  color: const Color(0xFFF1F5F9), 
                  child: const Center(child: Icon(Icons.biotech_outlined, size: 40, color: Colors.grey))
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(course.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                  const SizedBox(height: 12),
                  Row(children: [
                    CircleAvatar(radius: 22, backgroundImage: NetworkImage(course.instructorImage)),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("ARCHITECT", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w900)), 
                      Text(course.instructor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic))
                    ]),
                    const Spacer(),
                    Text("★ ${course.rating}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  ]),
                ]
              ),
            )
          ]
        ),
      ),
    );
  }
}