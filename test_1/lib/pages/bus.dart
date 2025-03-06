import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../api_service.dart';

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

  // Bus schedule categorized by day
  Map<String, List<Map<String, String>>> busSchedule = {
    'Weekday': [],
    'Weekend/Holiday': [],
  };

  bool isWeekend = false; // Flag for automatic detection
  String selectedSchedule = 'Weekday'; // Default selection

  @override
  void initState() {
    super.initState();
    _fetchBusData();

    // Auto-detect if today is a weekend
    DateTime now = DateTime.now();
    if (now.weekday == 6 || now.weekday == 7) {
      isWeekend = true;
      selectedSchedule = 'Weekend/Holiday';
    }
  }

  /// Fetch bus schedule from the API
  void _fetchBusData() {
    setState(() {
      data = ApiService(apiUrl: apiUrl).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bus Schedule',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.deepPurple[800],
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bus data available.'));
          }

          // Clear previous data
          busSchedule.forEach((key, value) => value.clear());

          // Categorize bus schedule
          for (var entry in snapshot.data!) {
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

          // Sort bus timings using `Time24`
          busSchedule.forEach((key, value) {
            value.sort((a, b) => _parseTime24(a['Time24']!).compareTo(_parseTime24(b['Time24']!)));
          });

          // Find the next bus
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _findNextBus();
          });

          // Select the correct schedule based on the toggle
          List<Map<String, String>> todaySchedule = busSchedule[selectedSchedule]!;

          return Column(
            children: [
              // Toggle Button for Weekday/Weekend
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
                          _findNextBus(); // Update next bus based on selection
                        });
                      },
                    ),
                    const Text("Weekend", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),

              // Next Bus Widget
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    nextBusTime == "No buses available"
                        ? "No upcoming buses"
                        : "Next Bus: $nextBusTime\nFrom: $nextBusPickup → To: $nextBusDrop",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Bus Timetable
              Expanded(
                child: ListView.builder(
                  itemCount: todaySchedule.length,
                  itemBuilder: (context, index) {
                    String time = todaySchedule[index]['Time'] ?? 'Unknown Time';
                    String pickup = todaySchedule[index]['Pickup'] ?? 'Unknown Pickup';
                    String drop = todaySchedule[index]['Drop'] ?? 'Unknown Destination';

                    return Card(
                      child: ListTile(
                        title: Text("$pickup → $drop"),
                        subtitle: Text(time),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Parse 24-hour time format (HH:MM) to DateTime
  DateTime _parseTime24(String time24) {
    try {
      var parts = time24.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hours, minutes);
    } catch (e) {
      print("Error parsing time24: $time24, Error: $e");
      return DateTime.now(); // Default fallback time
    }
  }

  /// Find the next upcoming bus
  void _findNextBus() {
    DateTime now = DateTime.now();
    List<Map<String, String>> todaySchedule = busSchedule[selectedSchedule]!;

    String newNextBusTime = "No buses available";
    String newNextBusPickup = "";
    String newNextBusDrop = "";

    for (var bus in todaySchedule) {
      String? busTimeString24 = bus['Time24'];
      if (busTimeString24 == null || busTimeString24.isEmpty) continue;

      DateTime busTime = _parseTime24(busTimeString24);
      if (busTime.isAfter(now)) {
        newNextBusTime = bus['Time'] ?? "Unknown Time"; // Use 12-hour format
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

