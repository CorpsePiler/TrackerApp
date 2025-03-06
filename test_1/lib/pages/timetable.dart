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
  String nextClass = "No class scheduled";

  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  // API URLs for different timetables
  final Map<String, String> apiUrls = {
    'CSEA': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=CSEA',
    'CSEB': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=CSEB',
    'DSAI': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=DSAI',
    'ECE': 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=ECE',
  };

  String selectedOption = 'CSEA'; // Default value

  @override
  void initState() {
    super.initState();
    _loadSavedOption(); // Load the saved selection
    int currentDayIndex = _getCurrentDayIndex();
    _pageController = PageController(initialPage: currentDayIndex);
  }

  /// Load the saved timetable option from SharedPreferences
  Future<void> _loadSavedOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedOption = prefs.getString('selectedTimetable');
    if (savedOption != null && apiUrls.containsKey(savedOption)) {
      setState(() {
        selectedOption = savedOption;
      });
    }
    _fetchData(); // Fetch data after loading the saved option
  }

  /// Save the selected timetable option to SharedPreferences
  Future<void> _saveSelectedOption(String option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTimetable', option);
  }

  /// Fetch data based on the selected timetable option
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
          // Dropdown for selecting CSEA, CSEB, DSAI, ECE
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
                    _saveSelectedOption(newValue); // Save selection
                    _fetchData(); // Fetch new data
                  });
                }
              },
            ),
          ),

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

                // Clear existing timetable
                timetable.forEach((key, value) => value.clear());

                // Populate the timetable with data
                for (var entry in snapshot.data!) {
                  String day = entry['Day'];
                  String time = entry['Time'];
                  String subject = entry['Subject'];

                  if (timetable.containsKey(day)) {
                    timetable[day]!.add({'Time': time, 'Subject': subject});
                  }
                }

                return Expanded(
                  child: PageView.builder(
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDay() => daysOfWeek[DateTime.now().weekday - 1];

  int _getCurrentDayIndex() => DateTime.now().weekday - 1;
}
