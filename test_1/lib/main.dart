import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'round', colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(secondary: Colors.greenAccent)),
      home: const HomePage()
    );
  }
}

