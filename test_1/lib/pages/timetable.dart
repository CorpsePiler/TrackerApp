import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'dart:convert';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late PageController _pageController;

  // Updated timetable map to include all days (if needed).
  Map<String, List<Map<String, String>>> timetable = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    // If you want weekends, uncomment these:
    // 'Saturday': [],
    // 'Sunday': [],
  };

  String currentClass = "No class currently";
  String currentClassEndTime = "";
  String nextClass = "No class scheduled";
  String nextClassTime = "";

  // Update the list if you add weekends.
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  final Map<String, String> apiUrls = {
    'CSEA': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=CSEA',
    'CSEB': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=CSEB',
    'DSAI': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=DSAI',
    'ECE': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=ECE',
  };

  String selectedOption = 'CSEA';
  bool isLoading = true;

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
      selectedOption = savedOption;
    }
    
    String? savedData = prefs.getString('timetable_data_$selectedOption');
    if (savedData != null) {
      List<Map<String, dynamic>> jsonData =
          List<Map<String, dynamic>>.from(json.decode(savedData));
      _processTimetableData(jsonData);
      setState(() {
        isLoading = false;
      });
    } else {
      await _fetchData();
    }
  }

  Future<void> _saveSelectedOption(String option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTimetable', option);
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await ApiService(apiUrl: apiUrls[selectedOption]!).fetchData();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'timetable_data_$selectedOption', json.encode(response));
      _processTimetableData(response);
    } catch (e) {
      print('Error fetching data: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _processTimetableData(List<Map<String, dynamic>> data) {
    // Clear existing data
    timetable.forEach((key, value) => value.clear());
    for (var entry in data) {
      String day = entry['Day'];
      String time = entry['Time'];
      String subject = entry['Subject'];
      if (timetable.containsKey(day)) {
        timetable[day]!.add({'Time': time, 'Subject': subject});
      }
    }
    _findCurrentAndNextClass();
  }

  String _getCurrentDay() => daysOfWeek[DateTime.now().weekday - 1];
  int _getCurrentDayIndex() => DateTime.now().weekday - 1;

  DateTime _parseTime(String time) {
    try {
      final regExp = RegExp(
          r'(\d{1,2}):(\d{2})\s?(AM|PM)?',
          caseSensitive: false);
      final match = regExp.firstMatch(time.trim());

      if (match == null) return DateTime.now();

      int hours = int.parse(match.group(1)!);
      int minutes = int.parse(match.group(2)!);
      String? period = match.group(3)?.toUpperCase();

      if (period != null) {
        if (period == "PM" && hours != 12) hours += 12;
        if (period == "AM" && hours == 12) hours = 0;
      }

      return DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, hours, minutes);
    } catch (e) {
      return DateTime.now();
    }
  }

  void _findCurrentAndNextClass() {
    DateTime now = DateTime.now();
    String today = _getCurrentDay();
    List<Map<String, String>> todayClasses = timetable[today] ?? [];

    currentClass = "No class currently";
    currentClassEndTime = "";
    nextClass = "No class scheduled";
    nextClassTime = "";

    for (var entry in todayClasses) {
      DateTime classStart = _parseTime(entry['Time']!.split(' - ')[0]);
      DateTime classEnd = _parseTime(entry['Time']!.split(' - ')[1]);
      String subject = entry['Subject']!;

      if (now.isAfter(classStart) && now.isBefore(classEnd)) {
        currentClass = subject;
        currentClassEndTime = entry['Time']!.split(' - ')[1];
      } else if (classStart.isAfter(now) && nextClass == "No class scheduled") {
        nextClass = subject;
        nextClassTime = entry['Time']!;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Timetable', style: TextStyle(color: Colors.white, fontSize: 30)),
        backgroundColor: Colors.deepPurple[800],
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dropdown to select timetable section.
                DropdownButton<String>(
                  value: selectedOption,
                  items: apiUrls.keys.map((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key, style: const TextStyle(fontSize: 18)),
                    );
                  }).toList(),
                  onChanged: (newValue) async {
                    if (newValue != null) {
                      setState(() {
                        selectedOption = newValue;
                        isLoading = true;
                      });
                      await _saveSelectedOption(newValue);
                      await _loadSavedOption();
                    }
                  },
                ),
                // Display current class information.
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
                // Display next class information.
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
                // PageView with a header for the day.
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: daysOfWeek.length,
                    itemBuilder: (context, index) {
                      String day = daysOfWeek[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              day,
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: timetable[day]?.length ?? 0,
                              itemBuilder: (context, i) {
                                var entry = timetable[day]![i];
                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    title: Text(entry['Subject'] ?? ''),
                                    subtitle: Text(entry['Time'] ?? ''),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
