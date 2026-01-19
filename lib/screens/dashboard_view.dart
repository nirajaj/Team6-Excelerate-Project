import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  final String firstName;
  final Animation<double> pulseAnimation;
  final VoidCallback onAccessAcademy; // <--- 1. Callback added

  const DashboardView({
    super.key,
    required this.firstName,
    required this.pulseAnimation,
    required this.onAccessAcademy, // <--- 2. Required in constructor
  });

  // --- Brand Colors ---
  final Color _slate900 = const Color(0xFF0F172A);
  final Color _primaryIndigo = const Color(0xFF5D5FEF);
  final Color _slate400 = const Color(0xFF94A3B8);
  final Color _slate50 = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(),
          const SizedBox(height: 35),
          _buildProtocolSection(),
          const SizedBox(height: 35),
          _buildStreakCard(),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _slate900,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: FadeTransition(
              opacity: pulseAnimation,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: _primaryIndigo.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _primaryIndigo, blurRadius: 100, spreadRadius: 20)],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBadge(),
              const SizedBox(height: 30),
              _buildGreetingText(),
              const SizedBox(height: 15),
              _buildStatusDescription(),
              const SizedBox(height: 35),
              
              // --- 3. THE BUTTON LOGIC ---
              GestureDetector(
                onTap: onAccessAcademy, // <--- This triggers the switch
                child: _buildHeroButton("Access Academy", _primaryIndigo, Colors.white),
              ),
              
              const SizedBox(height: 12),
              _buildHeroButton("Daily Brief", Colors.white.withOpacity(0.05), Colors.white, hasBorder: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: _primaryIndigo),
          const SizedBox(width: 8),
          const Text(
            "SYNCHRONIZED NODE ACTIVE",
            style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingText() {
    return Text.rich(
      TextSpan(
        text: "GREETINGS, ",
        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
        children: [
          TextSpan(text: firstName.toUpperCase(), style: TextStyle(color: _primaryIndigo.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildStatusDescription() {
    return Text.rich(
      TextSpan(
        text: "Platform status is ",
        style: TextStyle(color: _slate400, fontSize: 16, fontWeight: FontWeight.w500),
        children: const [
          TextSpan(text: "nominal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          TextSpan(text: ". You have 0 active curricula in your terminal."),
        ],
      ),
    );
  }

  Widget _buildProtocolSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DAILY PROTOCOL", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
        Text("ACADEMIC STATUS: PEAK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _slate400, letterSpacing: 2)),
        const SizedBox(height: 25),
        _buildProtocolItem("Sync Curricula", "12m estimated", "in-progress"),
        _buildProtocolItem("Verify Peer Signal", "Community Action", "pending"),
        _buildProtocolItem("Protocol Review", "Archived", "done"),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: _slate900,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: _primaryIndigo.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SYNC STREAK", style: TextStyle(color: _primaryIndigo, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3, fontStyle: FontStyle.italic)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text("12", style: TextStyle(color: Colors.white, fontSize: 75, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              const SizedBox(width: 8),
              Text("SOLS", style: TextStyle(color: _primaryIndigo, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white10, thickness: 1.5),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.85,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(_primaryIndigo),
            ),
          ),
          const SizedBox(height: 15),
          Center(child: Text("MASTERY LEVEL: 85%", style: TextStyle(color: _slate400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
        ],
      ),
    );
  }

  Widget _buildHeroButton(String label, Color bg, Color text, {bool hasBorder = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: hasBorder ? Border.all(color: Colors.white10) : null,
      ),
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _buildProtocolItem(String title, String time, String status) {
    bool isDone = status == "done";
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: isDone ? const Color(0xFFECFDF5) : _slate50, borderRadius: BorderRadius.circular(16)),
            child: Icon(isDone ? Icons.check : Icons.circle, size: 20, color: isDone ? const Color(0xFF10B981) : _primaryIndigo.withOpacity(0.5)),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDone ? _slate400 : _slate900, decoration: isDone ? TextDecoration.lineThrough : null)),
              Text(time.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _slate400, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }
}