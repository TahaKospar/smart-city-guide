import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/homePage.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart City Guide',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }
          // التهيئة تمت بنجاح
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && user.emailVerified) {
            return const Homepage();
          } else {
            return Login();
          }
        },
      ),
      routes: {
        "homepage": (context) => const Homepage(),
        "login": (context) => Login(),
        "register": (context) => Register(),
      },
    );
  }

  Future<void> _initialize() async {
    await Firebase.initializeApp();
    await Supabase.initialize(
      url: 'https://gyatkbzbjekkmejwpybw.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5YXRrYnpiamVra21landweWJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2MTMxMTEsImV4cCI6MjA5MDE4OTExMX0.fLuUmMKmBH2kJNGZ-7EiwZNzOM5cV-czxiJU7lzWJjU',
    );
  }
}
