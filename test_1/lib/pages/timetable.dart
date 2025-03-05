import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../api_service.dart';

class TimetablePage extends StatefulWidget {
  final String apiUrl;

  const TimetablePage({super.key, required this.apiUrl});

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

  @override
  void initState() {
    super.initState();
    data = ApiService(apiUrl: widget.apiUrl).fetchData();

    // Set the initial page to the current day
    int currentDayIndex = _getCurrentDayIndex();
    _pageController = PageController(initialPage: currentDayIndex);
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
        backgroundColor: const Color.fromARGB(255, 254, 250, 121),
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

          // Collect unique and sorted time slots
          Set<String> timeSlots = {};
          for (var day in timetable.values) {
            for (var entry in day) {
              timeSlots.add(entry['Time']!);
            }
          }

          List<String> sortedTimeSlots = timeSlots.toList();
          sortedTimeSlots.sort((a, b) => _parseTime(a).compareTo(_parseTime(b)));

          // Determine the current and next class
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _findCurrentAndNextClass(sortedTimeSlots);
          });

          return Column(
            children: [
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Current Class: $currentClass',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.blue.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Next Class: $nextClass',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
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
              ),
            ],
          );
        },
      ),
    );
  }

  DateTime _parseTime(String time, {bool end = false}) {
    var parts = time.split(' - ');
    var targetTime = end ? parts[1] : parts[0];
    var startTimeParts = targetTime.split(':');
    var hours = int.parse(startTimeParts[0]);
    var minutes = int.parse(startTimeParts[1]);

    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hours, minutes);
  }

  void _findCurrentAndNextClass(List<String> sortedTimeSlots) {
    DateTime now = DateTime.now();
    String today = _getCurrentDay();

    String newCurrentClass = "No class currently";
    String newNextClass = "No class scheduled";

    for (String timeSlot in sortedTimeSlots) {
      DateTime classStart = _parseTime(timeSlot);
      DateTime classEnd = _parseTime(timeSlot, end: true);

      String subject = _getSubjectForTime(today, timeSlot);

      if (subject.isNotEmpty) {
        if (now.isAfter(classStart) && now.isBefore(classEnd)) {
          newCurrentClass = "$subject until ${timeSlot.split(' - ')[1]}";
        } else if (classStart.isAfter(now) && newNextClass == "No class scheduled") {
          newNextClass = "$subject at $timeSlot";
        }
      }
    }

    if (currentClass != newCurrentClass || nextClass != newNextClass) {
      setState(() {
        currentClass = newCurrentClass;
        nextClass = newNextClass;
      });
    }
  }

  String _getSubjectForTime(String day, String time) {
    var dayData = timetable[day];
    if (dayData != null) {
      var entry = dayData.firstWhere(
        (entry) => entry['Time'] == time,
        orElse: () => {'Subject': ''},
      );
      return entry['Subject'] ?? '';
    }
    return '';
  }

  String _getCurrentDay() {
    return daysOfWeek[DateTime.now().weekday - 1];
  }

  int _getCurrentDayIndex() {
    return DateTime.now().weekday - 1;
  }
}
