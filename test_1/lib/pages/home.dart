// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'timetable.dart'; 
import 'bus.dart';       
import 'mess.dart';
import 'debt_tracker.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tracker',
          style: TextStyle(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 60, 153),
        centerTitle: true,
      ),

      //DRAWER HEADER
      drawer: Drawer(
        backgroundColor: Colors.purple[50],
        child: Column(
          children: [
            DrawerHeader(child: Icon(
              Icons.book,
              size: 40
            ))
          ],
        )
      ),



      body: ListView(
        children: [
         ListTile(
          minTileHeight: 165,
          tileColor: Colors.deepPurple[800],
            leading: Icon(Icons.directions_bus, size: 30, color: Colors.white),
            minLeadingWidth: 30,
            title: Text('Bus', textScaleFactor: 2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BusPage()),
              );
            },
          ),
          ListTile(
            minTileHeight: 165,
            tileColor: Colors.deepPurple[600],
            leading: Icon(Icons.fastfood, size: 30, color: Colors.white),
            title: Text('Mess', textScaleFactor: 2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessPage()),
              );
            },
          ),
          ListTile(
            minTileHeight: 165,
            tileColor: Colors.deepPurple[400],
            leading: Icon(Icons.schedule, size: 30, color: Colors.white),
            title: Text('Timetable', textScaleFactor: 2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimetablePage()),
              );
            },
          ),
          ListTile(
            minTileHeight: 165,
            tileColor: Colors.deepPurple[200],
            leading: Icon(Icons.calendar_month, size: 30, color: Colors.white),
            title: Text('Events and Holidays', textScaleFactor: 2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimetablePage()),
              );
            },
          ),
          ListTile(
            minTileHeight: 165,
            tileColor: Colors.deepPurple[100],
            leading: Icon(Icons.monetization_on, size: 30, color: Colors.white),
            title: Text('Debt Tracker', textScaleFactor: 2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DebtTrackerPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

