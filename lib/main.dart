import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Added for Security Check
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LearnifyApp());
}

class LearnifyApp extends StatelessWidget {
  const LearnifyApp({super.key});

  // Fetch the role saved during the Login process
  Future<String> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? 'student';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learnify',
      theme: ThemeData(
        useMaterial3: true, 
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      // --- UPDATED PERSISTENCE & SECURITY LOGIC ---
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While checking connection
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // If a user session exists
          if (snapshot.hasData) {
            final User currentUser = snapshot.data!;

            // --- 2. THE SECURITY GUARD: Check Database for Blocked Status ---
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
              builder: (context, userDocSnapshot) {
                if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                // If document exists, check the 'status' field
                if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                  var userData = userDocSnapshot.data!.data() as Map<String, dynamic>;
                  
                  if (userData['status'] == 'blocked') {
                    // USER IS RESTRICTED: Force Sign Out
                    FirebaseAuth.instance.signOut();
                    return const LoginScreen();
                  }
                }

                // --- 3. ROLE-BASED ROUTING ---
                return FutureBuilder<String>(
                  future: _getUserRole(),
                  builder: (context, roleSnapshot) {
                    if (roleSnapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(body: Center(child: CircularProgressIndicator()));
                    }

                    // Route to Admin Dashboard if role matches and email is correct
                    if (roleSnapshot.data == 'admin' && currentUser.email == "nirajaj133@gmail.com") {
                      return const AdminDashboard();
                    }
                    
                    // Otherwise, route to normal Student Home
                    return const HomeScreen();
                  },
                );
              },
            );
          }

          // If no user is logged in
          return const LoginScreen();
        },
      ),
    );
  }
}