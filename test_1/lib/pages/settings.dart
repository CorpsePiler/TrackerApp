import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedYear = "1st Year";
  String selectedBranch = "CSE";
  String selectedSection = "A";

  final List<String> years = ["1st Year", "2nd Year", "3rd Year", "4th Year"];
  final List<String> branches = ["CSE", "DSAI", "ECE"];
  final List<String> sections = ["A", "B"];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedYear = prefs.getString("selectedYear") ?? "1st Year";
      selectedBranch = prefs.getString("selectedBranch") ?? "CSE";
      selectedSection = prefs.getString("selectedSection") ?? "A";
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedYear", selectedYear);
    await prefs.setString("selectedBranch", selectedBranch);
    await prefs.setString("selectedSection", selectedSection);
    await prefs.setString("selectedApiUrl", _getApiUrl());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings Saved!")),
    );
  }

  String _getApiUrl() {
    if (selectedYear == "1st Year") {
      if (selectedBranch == "CSE") {
        return selectedSection == "A"
            ? "https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=CSEA"
            : "https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=CSEB";
      } else if (selectedBranch == "DSAI") {
        return "https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=DSAI";
      } else {
        return "https://script.google.com/macros/s/AKfycbzZ1ctMGkHygQpuxKXQXLn-Yz1DMRQuuC0IH_zfnj8xPjpEWV1jGVNpP0I4lqaOiMzy/exec?sheet=ECE";
      }
    } else if (selectedYear == "2nd Year") {
      return "https://api-url.com/2nd-year";
    } else if (selectedYear == "3rd Year") {
      return "https://api-url.com/3rd-year";
    } else {
      return "https://api-url.com/4th-year";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), backgroundColor: Colors.deepPurple[800]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Year", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedYear,
              onChanged: (value) {
                setState(() => selectedYear = value!);
              },
              items: years.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
            ),
            const SizedBox(height: 20),

            const Text("Select Branch", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedBranch,
              onChanged: (value) {
                setState(() {
                  selectedBranch = value!;
                  if (selectedBranch != "CSE") selectedSection = "None";
                });
              },
              items: branches.map((branch) => DropdownMenuItem(value: branch, child: Text(branch))).toList(),
            ),
            const SizedBox(height: 20),

            if (selectedYear == "1st Year" && selectedBranch == "CSE") ...[
              const Text("Select Section (CSE Only)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedSection,
                onChanged: (value) {
                  setState(() => selectedSection = value!);
                },
                items: sections.map((section) => DropdownMenuItem(value: section, child: Text(section))).toList(),
              ),
            ],

            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _savePreferences,
                child: const Text("Save Settings"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
