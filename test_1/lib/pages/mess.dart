import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../api_service.dart';

class MessPage extends StatefulWidget {
  const MessPage({super.key});

  @override
  _MessPageState createState() => _MessPageState();
}

class _MessPageState extends State<MessPage> {
  late Future<List<Map<String, dynamic>>> data;
  late PageController _pageController;

  Map<String, List<Map<String, String>>> messMenu = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final String apiUrl =
      'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=MESS';

  @override
  void initState() {
    super.initState();
    data = ApiService(apiUrl: apiUrl).fetchData();
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
          'Mess Menu',
          style: TextStyle(color: Colors.black, fontSize: 30),
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
            return const Center(child: Text('No data found.'));
          }

          // Populate messMenu with fetched data
          messMenu.forEach((key, value) => value.clear());
          for (var entry in snapshot.data!) {
            String day = entry['Day'];
            String meal = entry['Meal'];
            String item = entry['Item'];

            if (messMenu.containsKey(day)) {
              messMenu[day]!.add({'Meal': meal, 'Item': item});
            }
          }

          return PageView.builder(
            controller: _pageController,
            itemCount: daysOfWeek.length,
            itemBuilder: (context, index) {
              String day = daysOfWeek[index];
              List<Map<String, String>> mealsForDay = messMenu[day]!;

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
                      itemCount: mealsForDay.length,
                      itemBuilder: (context, index) {
                        String meal = mealsForDay[index]['Meal'] ?? '';
                        String item = mealsForDay[index]['Item'] ?? '';
                        return Card(
                          child: ListTile(
                            title: Text(meal),
                            subtitle: Text(item),
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
    );
  }

  String _getCurrentDay() => daysOfWeek[DateTime.now().weekday - 1];

  int _getCurrentDayIndex() => DateTime.now().weekday - 1;
}
