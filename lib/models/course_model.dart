class Course {
  final String id, title, description, instructor, instructorImage, rating, nodes, level, image;
  final bool isVisible;
  final List<Module> modules; // --- NEW: Added Curriculum List ---

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.instructorImage,
    required this.rating,
    required this.nodes,
    required this.level,
    required this.image,
    required this.isVisible,
    required this.modules, // --- Added to Constructor ---
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    String title = json['title'] ?? 'Untitled Vector';

    // Unique ID generation for stable tracking
    int pageId = (json['pageid'] as num?)?.toInt() ?? 
                 (json['id']?.hashCode) ?? 
                 title.hashCode;

    // --- 1. UNIQUE TECH IMAGE ENGINE ---
    // Uses the pageId to "lock" a unique tech image for every course
    String courseImg = "https://loremflickr.com/800/600/coding,technology,computer/all?lock=$pageId";

    // --- 2. UNIQUE ARCHITECT ENGINE ---
    final List<String> architects = ["Architect J. Vance", "Lead Dev K. Thorne", "Senior Engineer Sarah", "AI Researcher Marcus"];
    String instructorName = architects[pageId % architects.length];

    // --- 3. MODULE MAPPING ---
    // This parses the curriculum list from the JSON data
    var modulesJson = json['modules'] as List? ?? [];
    List<Module> moduleList = modulesJson.map((m) => Module.fromJson(m)).toList();

    return Course(
      id: pageId.toString(),
      title: title,
      description: json['extract'] ?? json['description'] ?? 'Technical documentation active.',
      instructor: json['instructor'] ?? instructorName,
      instructorImage: "https://api.dicebear.com/7.x/avataaars/png?seed=$pageId",
      rating: json['rating']?.toString() ?? (4 + (pageId % 10) / 10).toStringAsFixed(1),
      nodes: json['nodes']?.toString() ?? "${300 + (pageId % 1000)}",
      level: json['level'] ?? (pageId % 2 == 0 ? "Expert" : "Professional"),
      image: json['image'] ?? courseImg,
      isVisible: json['isVisible'] ?? true,
      modules: moduleList, // Now returns the actual curriculum
    );
  }
}

class Module {
  final String id, title, content;

  Module({required this.id, required this.title, required this.content});

  // --- NEW: Factory to handle Module parsing ---
  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id']?.toString() ?? '1',
      title: json['title']?.toString() ?? 'Untitled Module',
      content: json['content']?.toString() ?? 'Study content active.',
    );
  }
}