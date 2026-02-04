import 'package:flutter/material.dart';
import 'package:flutter_application_1/homePage.dart';
import 'package:flutter_application_1/page1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences shard = await SharedPreferences.getInstance();
  Widget startScrean;
  String? savedName = shard.getString("name");
  if (savedName != null && savedName.isNotEmpty) {
    startScrean = const Page1();
  } else {
    startScrean = const Homepage();
  }
  runApp(MyApp(startScrean: startScrean));
}

class MyApp extends StatefulWidget {
  final Widget startScrean;
  const MyApp({super.key, required this.startScrean});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          appBarTheme:
              AppBarTheme(backgroundColor: Colors.cyan, centerTitle: true)),
      home: widget.startScrean,
    );
  }
}
