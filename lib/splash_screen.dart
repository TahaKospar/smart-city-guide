import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter_application_1/homePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()), 
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png", 
              width: 200, 
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.blue), 
            SizedBox(height: 20),
            Text(
              "Smart City Guide",
              style: TextStyle(
                fontSize: 25, 
                fontWeight: FontWeight.bold,
                fontFamily: "Delius" 
              ),
            ),
          ],
        ),
      ),
    );
  }
}