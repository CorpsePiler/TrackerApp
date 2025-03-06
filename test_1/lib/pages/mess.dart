import 'package:flutter/material.dart';

class MessPage extends StatelessWidget {
  const MessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mess Menu',
          style: TextStyle(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 254, 250, 121),
        centerTitle: true,
      ),
    );
  }
}