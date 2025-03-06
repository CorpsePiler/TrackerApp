import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late Future<List<Map<String, dynamic>>> data;
  late PageController _pageController;

  Map<String, List<Map<String, String>>> timetable = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
  };

  String currentClass = "No class currently";
  String currentClassEndTime = "";
  String nextClass = "No class scheduled";
  String nextClassTime = "";

  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  final Map<String, String> apiUrls = {
    'CSEA': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=CSEA',
    'CSEB': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=CSEB',
    'DSAI': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=DSAI',
    'ECE': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=ECE',
  };

  String selectedOption = 'CSEA';

  @override
  void initState() {
    super.initState();
    _loadSavedOption();
    int currentDayIndex = _getCurrentDayIndex();
    _pageController = PageController(initialPage: currentDayIndex);
  }

  Future<void> _loadSavedOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedOption = prefs.getString('selectedTimetable');
    if (savedOption != null && apiUrls.containsKey(savedOption)) {
      setState(() {
        selectedOption = savedOption;
      });
    }
    _fetchData();
  }

  Future<void> _saveSelectedOption(String option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTimetable', option);
  }

  void _fetchData() {
    setState(() {
      data = ApiService(apiUrl: apiUrls[selectedOption]!).fetchData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Timetable',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.deepPurple[800],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Dropdown to select timetable option
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedOption,
              items: apiUrls.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key, style: const TextStyle(fontSize: 18)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedOption = newValue;
                    _saveSelectedOption(newValue);
                    _fetchData();
                  });
                }
              },
            ),
          ),

          // Current Class Widget
          Card(
            color: Colors.green.shade100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                currentClass == "No class currently"
                    ? "No class ongoing"
                    : "Current Class: $currentClass (Ends at $currentClassEndTime)",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Next Class Widget
          Card(
            color: Colors.blue.shade100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                nextClass == "No class scheduled"
                    ? "No upcoming classes"
                    : "Next Class: $nextClass (At $nextClassTime)",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Timetable
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found.'));
                }

                timetable.forEach((key, value) => value.clear());

                for (var entry in snapshot.data!) {
                  String day = entry['Day'];
                  String time = entry['Time'];
                  String subject = entry['Subject'];

                  if (timetable.containsKey(day)) {
                    timetable[day]!.add({'Time': time, 'Subject': subject});
                  }
                }

                // Determine current and next class
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  _findCurrentAndNextClass();
                });

                return PageView.builder(
                  controller: _pageController,
                  itemCount: daysOfWeek.length,
                  itemBuilder: (context, index) {
                    String day = daysOfWeek[index];
                    List<Map<String, String>> classesForDay = timetable[day]!
                        .where((entry) => entry['Subject'] != null && entry['Subject']!.isNotEmpty)
                        .toList();

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: classesForDay.length,
                            itemBuilder: (context, index) {
                              String timeSlot = classesForDay[index]['Time'] ?? '';
                              String subject = classesForDay[index]['Subject'] ?? '';
                              return Card(
                                child: ListTile(
                                  title: Text(subject),
                                  subtitle: Text(timeSlot),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseTime(String time, {bool end = false}) {
  try {
    // Trim any extra spaces
    time = time.trim();

    // Handle 12-hour format with AM/PM
    final regExp = RegExp(r'(\d{1,2}):(\d{2})\s?(AM|PM)?', caseSensitive: false);
    final match = regExp.firstMatch(time);

    if (match == null) {
      throw FormatException("Invalid time format: $time");
    }

    int hours = int.parse(match.group(1)!);
    int minutes = int.parse(match.group(2)!);
    String? period = match.group(3)?.toUpperCase();

    // Convert 12-hour format to 24-hour format if AM/PM is present
    if (period != null) {
      if (period == "PM" && hours != 12) {
        hours += 12; // Convert PM times (except 12 PM)
      } else if (period == "AM" && hours == 12) {
        hours = 0; // Convert 12 AM to 00
      }
    }

    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hours, minutes);
  } catch (e) {
    print("Error parsing time: $time, Error: $e");
    return DateTime.now(); // Default fallback time
  }
}


  void _findCurrentAndNextClass() {
    DateTime now = DateTime.now();
    String today = _getCurrentDay();
    List<Map<String, String>> todayClasses = timetable[today] ?? [];

    String newCurrentClass = "No class currently";
    String newCurrentClassEndTime = "";
    String newNextClass = "No class scheduled";
    String newNextClassTime = "";

    for (var entry in todayClasses) {
      DateTime classStart = _parseTime(entry['Time']!);
      DateTime classEnd = _parseTime(entry['Time']!, end: true);
      String subject = entry['Subject']!;

      if (now.isAfter(classStart) && now.isBefore(classEnd)) {
        newCurrentClass = subject;
        newCurrentClassEndTime = entry['Time']!.split(' - ')[1];
      } else if (classStart.isAfter(now) && newNextClass == "No class scheduled") {
        newNextClass = subject;
        newNextClassTime = entry['Time']!;
      }
    }

    setState(() {
      currentClass = newCurrentClass;
      currentClassEndTime = newCurrentClassEndTime;
      nextClass = newNextClass;
      nextClassTime = newNextClassTime;
    });
  }

  String _getCurrentDay() => daysOfWeek[DateTime.now().weekday - 1];

  int _getCurrentDayIndex() => DateTime.now().weekday - 1;
}
