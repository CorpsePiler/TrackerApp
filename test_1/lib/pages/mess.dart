import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'dart:convert';

class MessPage extends StatefulWidget {
  const MessPage({super.key});

  @override
  _MessPageState createState() => _MessPageState();
}

class _MessPageState extends State<MessPage> {
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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    int currentDayIndex = _getCurrentDayIndex();
    _pageController = PageController(initialPage: currentDayIndex);
    _loadSavedData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('mess_menu_data');
    if (savedData != null) {
      List<Map<String, dynamic>> jsonData = List<Map<String, dynamic>>.from(json.decode(savedData));
      _processMessMenuData(jsonData);
      setState(() {
        isLoading = false;
      });
    } else {
      await _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await ApiService(apiUrl: apiUrl).fetchData();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('mess_menu_data', json.encode(response));
      _processMessMenuData(response);
    } catch (e) {
      print('Error fetching data: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _processMessMenuData(List<Map<String, dynamic>> data) {
    messMenu.forEach((key, value) => value.clear());
    for (var entry in data) {
      String day = entry['Day'];
      String meal = entry['Meal'];
      String item = entry['Item'];

      if (messMenu.containsKey(day)) {
        messMenu[day]!.add({'Meal': meal, 'Item': item});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mess Menu',
          style: TextStyle(fontSize: 26, color: Colors.white),
        ),
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
          : PageView.builder(
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
                          fontSize: 28,
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
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: ListTile(
                              leading: const Icon(Icons.restaurant_menu, color: Colors.deepPurple),
                              title: Text(meal, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item),
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

  String _getCurrentDay() => daysOfWeek[DateTime.now().weekday - 1];

  int _getCurrentDayIndex() => DateTime.now().weekday - 1;
}
