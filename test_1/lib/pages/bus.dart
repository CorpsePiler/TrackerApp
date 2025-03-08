import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'dart:convert';

class BusPage extends StatefulWidget {
  const BusPage({super.key});

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  late Future<List<Map<String, dynamic>>> data;
  String nextBusTime = "No buses available";
  String nextBusPickup = "";
  String nextBusDrop = "";

  final String apiUrl =
      'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=BUS';

  Map<String, List<Map<String, String>>> busSchedule = {
    'Weekday': [],
    'Weekend/Holiday': [],
  };

  bool isWeekend = false;
  String selectedSchedule = 'Weekday';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
    DateTime now = DateTime.now();
    if (now.weekday == 6 || now.weekday == 7) {
      isWeekend = true;
      selectedSchedule = 'Weekend/Holiday';
    }
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('bus_data');
    if (savedData != null) {
      List<Map<String, dynamic>> jsonData = List<Map<String, dynamic>>.from(json.decode(savedData));
      setState(() {
        _processBusData(jsonData);
        isLoading = false;
      });
    }
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await ApiService(apiUrl: apiUrl).fetchData();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('bus_data', json.encode(response));
      setState(() {
        _processBusData(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching bus data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _processBusData(List<Map<String, dynamic>> data) {
    busSchedule.forEach((key, value) => value.clear());
    for (var entry in data) {
      String day = entry['Day'] ?? 'Weekday';
      String time24 = entry['Time24'] ?? '00:00';
      String time12 = entry['Time'] ?? 'Unknown Time';
      String pickup = entry['Pickup'] ?? 'Unknown Pickup';
      String drop = entry['Drop'] ?? 'Unknown Destination';

      if (busSchedule.containsKey(day)) {
        busSchedule[day]!.add({
          'Time24': time24,
          'Time': time12,
          'Pickup': pickup,
          'Drop': drop,
        });
      }
    }
    busSchedule.forEach((key, value) {
      value.sort((a, b) => _parseTime24(a['Time24']!).compareTo(_parseTime24(b['Time24']!)));
    });
    _findNextBus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 62, 78, 75),
      appBar: AppBar(
        title: const Text(
          'Bus Schedule',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: const Color.fromARGB(255, 62, 78, 75),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Next Bus Widget
                Card(
                  color: const Color.fromARGB(255, 122, 133, 133),
                  margin: const EdgeInsets.all(25),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          "Next Bus",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFE0E2DB)),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          nextBusTime == "No buses available"
                              ? "No upcoming buses"
                              : "$nextBusPickup → $nextBusDrop",
                          style: const TextStyle(fontSize: 18, color: const Color(0xFFE0E2DB)),
                        ),
                        Text(
                          nextBusTime,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFE0E2DB)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Schedule Selector
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Weekday", style: TextStyle(fontSize: 16, color: Color(0xFFE0E2DB))),
                      Switch(
                        activeColor: const Color(0xFFE0E2DB),
                        inactiveThumbColor: const Color.fromARGB(255, 122, 133, 133),
                        inactiveTrackColor: const Color(0xFFE0E2DB),
                        value: selectedSchedule == "Weekend/Holiday",
                        onChanged: (bool value) {
                          setState(() {
                            selectedSchedule = value ? "Weekend/Holiday" : "Weekday";
                            _findNextBus();
                          });
                        },
                      ),
                      const Text("Weekend", style: TextStyle(fontSize: 16, color: Color(0xFFE0E2DB))),
                    ],
                  ),
                ),

                // Bus Schedule List
               Expanded(
                child: ListView.builder(
                  itemCount: busSchedule[selectedSchedule]!.length,
                  itemBuilder: (context, index) {
                    final bus = busSchedule[selectedSchedule]![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0), // Adjust radius as needed
                      ),
                      color: const Color.fromARGB(255, 122, 133, 133), // Ensure background color is here
                      child: ListTile(
                        tileColor: Colors.transparent, // Make tile background transparent
                        title: Text(
                          "${bus['Pickup']} → ${bus['Drop']}",
                          style: const TextStyle(fontSize: 20, color: Color(0xFFE0E2DB)),
                        ),
                        subtitle: Text(
                          bus['Time'] ?? "Unknown Time",
                          style: const TextStyle(fontSize: 16, color: Color(0xFFE0E2DB)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ],
            ),
    );
  }

  DateTime _parseTime24(String time24) {
    try {
      var parts = time24.split(':');
      return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (e) {
      return DateTime.now();
    }
  }

  void _findNextBus() {
    DateTime now = DateTime.now();
    String newNextBusTime = "No buses available";
    String newNextBusPickup = "";
    String newNextBusDrop = "";

    for (var bus in busSchedule[selectedSchedule]!) {
      DateTime busTime = _parseTime24(bus['Time24']!);
      if (busTime.isAfter(now)) {
        newNextBusTime = bus['Time'] ?? "Unknown Time";
        newNextBusPickup = bus['Pickup'] ?? "Unknown Pickup";
        newNextBusDrop = bus['Drop'] ?? "Unknown Destination";
        break;
      }
    }

    setState(() {
      nextBusTime = newNextBusTime;
      nextBusPickup = newNextBusPickup;
      nextBusDrop = newNextBusDrop;
    });
  }
}
