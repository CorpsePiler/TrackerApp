// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:test_1/pages/events_and_holidays.dart';
import 'timetable.dart';
import 'bus.dart';
import 'mess.dart';
import 'debt_tracker.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: const Text(
          'Tracker',
          style: TextStyle(
            color: Colors.black,
            fontSize: 40,
          ),
        ),
        backgroundColor: Colors.deepPurple[800],
        centerTitle: true,
      ),



      body: ListView(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 15, right: 50),
            minTileHeight: 160,
            tileColor: Colors.deepPurple[800],
            leading: const Icon(Icons.directions_bus, size: 40, color: Colors.white),
            title: const Text('Bus', textScaleFactor: 2.4, textAlign: TextAlign.center),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BusPage()));
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 15, right: 50),
            minTileHeight: 160,
            tileColor: Colors.deepPurple[600],
            leading: const Icon(Icons.fastfood, size: 40, color: Colors.white),
            title: const Text('Mess', textScaleFactor: 2.4, textAlign: TextAlign.center),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MessPage()));
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 15, right: 50),
            minTileHeight: 160,
            tileColor: Colors.deepPurple[400],
            leading: const Icon(Icons.schedule, size: 40, color: Colors.white),
            title: const Text('Timetable', textScaleFactor: 2.4, textAlign: TextAlign.center),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimetablePage(),
                ),
              );
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 15, right: 50),
            minTileHeight: 160,
            tileColor: const Color.fromRGBO(179, 157, 219, 1),
            leading: const Icon(Icons.calendar_month, size: 40, color: Colors.white),
            title: const Text('Events and Holidays', textScaleFactor: 2.4, textAlign: TextAlign.center),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EHPage(),
                ),
              );
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 15, right: 50),
            minTileHeight: 160,
            tileColor: Colors.deepPurple[100],
            leading: const Icon(Icons.monetization_on, size: 40, color: Colors.white),
            title: const Text('Debt Tracker', textScaleFactor: 2.4, textAlign: TextAlign.center),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebtTrackerPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
