import 'package:flutter/material.dart';

class BusPage extends StatelessWidget {
  const BusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bus Schedule',
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