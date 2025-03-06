import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EHPage extends StatefulWidget {
  const EHPage({Key? key}) : super(key: key);

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
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        print('Raw Data: ${response.body}');
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            holidays = data; // Directly assign the list
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
      appBar: AppBar(
        title: const Text(
          'Events and Holidays',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color.fromRGBO(179, 157, 219, 1),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : holidays.isEmpty
              ? const Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: holidays.length,
                  itemBuilder: (context, index) {
                    final event = holidays[index];
                    print('Event: $event');
                    return ListTile(
                      title: Text(event['Event'] ?? 'No Event'),
                      subtitle: Text('${event['Date'] ?? ''} - ${event['Day'] ?? ''}'),
                    );
                  },
                ),
    );
  }
}
