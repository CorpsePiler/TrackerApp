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
      appBar: AppBar(
        title: const Text(
          'Bus Schedule',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 30),
        ),
        backgroundColor: Colors.deepPurple[800],
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 255, 255, 255)),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Weekday", style: TextStyle(fontSize: 16)),
                      Switch(
                        value: selectedSchedule == "Weekend/Holiday",
                        onChanged: (bool value) {
                          setState(() {
                            selectedSchedule = value ? "Weekend/Holiday" : "Weekday";
                            _findNextBus();
                          });
                        },
                      ),
                      const Text("Weekend", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: busSchedule[selectedSchedule]!.length,
                    itemBuilder: (context, index) {
                      final bus = busSchedule[selectedSchedule]![index];
                      return ListTile(
                        title: Text("${bus['Pickup']} → ${bus['Drop']}", style: TextStyle(fontSize: 20)),
                        subtitle: Text(bus['Time'] ?? "Unknown Time"),
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
