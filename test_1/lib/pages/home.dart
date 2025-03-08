import 'package:flutter/material.dart';
import 'package:test_1/pages/events_and_holidays.dart';
import 'timetable.dart';
import 'bus.dart';
import 'mess.dart';
import 'debt_tracker.dart';

class HomePage extends StatelessWidget {
  ThemeData get theme => ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color.fromARGB(255, 62, 78, 75), // Darker background
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 62, 78, 75), // Medium-dark AppBar
          centerTitle: true,
        ),
      );
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 62, 78, 75), // Darker background
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          'chub',
          style: TextStyle(
            color: Color(0xFFE0E2DB), // Light text for contrast
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 62, 78, 75), // Medium-dark AppBar
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Expanded(
              child: _buildMenuItem(
                context,
                title: 'Bus',
                icon: Icons.directions_bus,
                color: const Color.fromARGB(255, 122, 133, 133),
                destination: const BusPage(),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _buildMenuItem(
                context,
                title: 'Mess',
                icon: Icons.fastfood,
                color: const Color.fromARGB(255, 122, 133, 133),
                destination: const MessPage(),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _buildMenuItem(
                context,
                title: 'Timetable',
                icon: Icons.schedule,
                color: const Color.fromARGB(255, 122, 133, 133),
                destination: const TimetablePage(),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _buildMenuItem(
                context,
                title: 'Events and Holidays',
                icon: Icons.calendar_month,
                color: const Color.fromARGB(255, 122, 133, 133),
                destination: const EHPage(),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _buildMenuItem(
                context,
                title: 'Debt Tracker',
                icon: Icons.monetization_on,
                color: const Color.fromARGB(255, 122, 133, 133),
                destination: const DebtTrackerPage(),
              ),
            ),
            const SizedBox(height: 45),
          ],
        ),
      ),
    );
  }

  /// Builds a full-width menu item with rounded corners
  Widget _buildMenuItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required Widget destination,
      }) {
    return SizedBox(
      width: double.infinity, // Full width
      child: Material(
        color: color, // Medium-dark grey background
        borderRadius: BorderRadius.circular(20), // Rounded corners
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20), // Taller padding
            child: Row(
              children: [
                Icon(icon, size: 50, color: const Color(0xFFE0E2DB)), // Light icons
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26, // Bigger text
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 237, 240, 231), // Light text for contrast
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
