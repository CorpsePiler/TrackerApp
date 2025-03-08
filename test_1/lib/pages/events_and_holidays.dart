import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EHPage extends StatefulWidget {
  const EHPage({super.key});

  @override
  _EHPageState createState() => _EHPageState();
}

class _EHPageState extends State<EHPage> {
  final String apiUrl = 'https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=HOLIDAY';
  List<dynamic> holidays = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('holidays_data');
    if (savedData != null) {
      setState(() {
        holidays = json.decode(savedData);
        isLoading = false;
      });
    }
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('holidays_data', json.encode(data));
          setState(() {
            holidays = data;
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 62, 78, 75),
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: const Color(0xFFE0E2DB)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 62, 78, 75),
        title: const Text(
          'Events and Holidays',
          style: TextStyle(
            color: const Color(0xFFE0E2DB),
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: const Color(0xFFE0E2DB)),
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
          : holidays.isEmpty
              ? const Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: holidays.length,
                  itemBuilder: (context, index) {
                    final event = holidays[index];
                    return Card(
                      color: const Color.fromARGB(255, 122, 133, 133),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['Event'] ?? 'No Event',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFE0E2DB)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${event['Date'] ?? ''} - ${event['Day'] ?? ''}',
                              style: const TextStyle(fontSize: 18, color: const Color(0xFFE0E2DB)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}