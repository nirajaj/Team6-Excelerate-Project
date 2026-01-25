import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // --- 1. CONTROLLERS ---
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _isSubmitting = false;

  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // 2. FETCH FIREBASE DATA
    _nameController = TextEditingController(text: user?.displayName ?? "Student");
    _emailController = TextEditingController(text: user?.email ?? "Not Available");
  }

  // --- 3. FIREBASE SUBMISSION ---
  Future<void> _transmitInquiry() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await firestore.collection('support_requests').add({
        'identity': _nameController.text, // User can't change this
        'email': _emailController.text,    // User can't change this
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user?.uid,
        'status': 'active',
      });

      _subjectController.clear();
      _messageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Inquiry Transmitted Successfully"), 
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Colors
  final Color _primaryPurple = const Color(0xFF5D5FEF);
  final Color _darkNavy = const Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text("ELITE SUPPORT", 
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -1)),
          const Text("DIRECT LINK TO ADMINISTRATIVE GOVERNANCE", 
            style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 40),

          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 800;
            return Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CONNECTIVITY CARD
                Expanded(flex: isMobile ? 0 : 1, child: _buildConnectivityCard()),
                
                if (!isMobile) const SizedBox(width: 30),
                if (isMobile) const SizedBox(height: 30),

                // THE INQUIRY FORM
                Expanded(flex: isMobile ? 0 : 2, child: _buildInquiryForm()),
              ],
            );
          }),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildConnectivityCard() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: _darkNavy,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CONNECTIVITY", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2)),
          const SizedBox(height: 40),
          _contactItem(Icons.location_on_outlined, "HQ LOCATION", "128 Academy Plaza, San Francisco"),
          const SizedBox(height: 30),
          _contactItem(Icons.phone_outlined, "DIRECT AUDIO", "+1 (555) 900-LEARN"),
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
            child: const Text(
              "\"Our mission is to provide an uninterrupted, high-performance learning environment for every student on the platform.\"",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontStyle: FontStyle.italic, height: 1.5),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInquiryForm() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(45),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // LOCKED IDENTITY FIELD
                Expanded(child: _formField("IDENTITY", _nameController, isReadOnly: true)),
                const SizedBox(width: 20),
                // LOCKED EMAIL FIELD
                Expanded(child: _formField("EMAIL TERMINAL", _emailController, isReadOnly: true)),
              ],
            ),
            const SizedBox(height: 25),
            _formField("INQUIRY SUBJECT", _subjectController, hint: "e.g. Technical Support / Curriculum Doubt"),
            const SizedBox(height: 25),
            _formField("DETAILED LOG", _messageController, hint: "Elaborate on your requirement...", maxLines: 5),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _transmitInquiry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isSubmitting 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("TRANSMIT INQUIRY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
            )
          ],
        ),
      ),
    );
  }

  Widget _contactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: _primaryPurple, size: 22)),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ])
      ],
    );
  }

  Widget _formField(String label, TextEditingController controller, {String hint = "", int maxLines = 1, bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: isReadOnly, // --- THIS LOCKS THE FIELD ---
          validator: (v) => v!.isEmpty ? "Required" : null,
          style: TextStyle(
            color: isReadOnly ? Colors.grey[600] : Colors.black, // Darker text for locked fields
            fontWeight: isReadOnly ? FontWeight.w600 : FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isReadOnly ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC), // Gray background for locked fields
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
          ),
        ),
      ],
    );
  }
}