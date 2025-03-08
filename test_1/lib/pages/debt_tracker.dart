import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const DebtTrackerApp());
}

class DebtTrackerApp extends StatelessWidget {
  const DebtTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const DebtTrackerPage(),
    );
  }
}

class Debt {
  String name;
  String type;
  double amount;

  Debt({required this.name, required this.type, required this.amount});

  // Convert a Debt object to a Map (for JSON storage)
  Map<String, dynamic> toJson() {
    return {"name": name, "type": type, "amount": amount};
  }

  // Create a Debt object from a Map (for loading from JSON)
  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      name: json["name"],
      type: json["type"],
      amount: json["amount"].toDouble(),
    );
  }
}

class DebtTrackerPage extends StatefulWidget {
  const DebtTrackerPage({super.key});

  @override
  State<DebtTrackerPage> createState() => _DebtTrackerPageState();
}

class _DebtTrackerPageState extends State<DebtTrackerPage> {
  List<Debt> debts = [];

  @override
  void initState() {
    super.initState();
    _loadDebts(); // Load saved debts when app starts
  }

  // Save debts to SharedPreferences
  Future<void> _saveDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = jsonEncode(debts.map((d) => d.toJson()).toList());
    await prefs.setString('debts', debtsJson);
  }

  // Load debts from SharedPreferences
  Future<void> _loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = prefs.getString('debts');
    if (debtsJson != null) {
      final List<dynamic> decoded = jsonDecode(debtsJson);
      setState(() {
        debts = decoded.map((d) => Debt.fromJson(d)).toList();
      });
    }
  }

  void _addDebt() {
    String name = "";
    String type = "I owe";
    double amount = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 62, 78, 75),
          title: const Text("Add Debt", style: TextStyle(color: const Color(0xFFE0E2DB))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: const Color(0xFFE0E2DB)),
                decoration: const InputDecoration(labelText: "Name", labelStyle: TextStyle(color: const Color(0xFFE0E2DB))),
                onChanged: (value) => name = value,
              ),
              DropdownButtonFormField<String>(
                style: const TextStyle(color: const Color(0xFFE0E2DB)), dropdownColor: const Color.fromARGB(255, 122, 133, 133),
                decoration: const InputDecoration(labelText: "Type", labelStyle: TextStyle(color: const Color(0xFFE0E2DB))),
                value: type,
                items: ["I owe", "Owes me"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => type = value!,
              ),
              TextField(
                style: const TextStyle(color: const Color(0xFFE0E2DB)),
                decoration: const InputDecoration(labelText: "Amount", labelStyle: TextStyle(color: const Color(0xFFE0E2DB))),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(const Color(0xFFE0E2DB)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 122, 133, 133)),
              ),
              onPressed: () {
                if (name.isNotEmpty && amount > 0) {
                  setState(() {
                    debts.add(Debt(name: name, type: type, amount: amount));
                    _saveDebts(); // Save debts after adding
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add", style: TextStyle(color: const Color(0xFFE0E2DB))),
            ),
          ],
        );
      },
    );
  }

  void _deleteDebt(int index) {
    setState(() {
      debts.removeAt(index);
      _saveDebts(); // Save debts after deleting
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Debt Tracker',
          style: TextStyle(
            color: const Color(0xFFE0E2DB),
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),



      backgroundColor: const Color.fromARGB(255, 62, 78, 75),
          body: debts.isEmpty
          ? const Center(child: Text("No debts added yet!", style: TextStyle(color: const Color(0xFFE0E2DB), fontSize: 30))
          )
          : ListView.builder(
              itemCount: debts.length,
              itemBuilder: (context, index) {
                final debt = debts[index];
                return Dismissible(
                  key: Key(debt.name + debt.amount.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deleteDebt(index),
                  background: Container(
                    color: const Color.fromARGB(255, 232, 76, 65),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    color: const Color.fromARGB(255, 122, 133, 133),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5),
                    child: ListTile(
                      title: Text(debt.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFFE0E2DB))),
                      subtitle:
                          Text("${debt.type} ₹${debt.amount.toStringAsFixed(2)}", style: TextStyle(color: const Color(0xFFE0E2DB))),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: const Color(0xFFE0E2DB)),
                        onPressed: () => _deleteDebt(index),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 122, 133, 133),
        onPressed: _addDebt,
        child: const Icon(Icons.add, color: const Color(0xFFE0E2DB)),
      ),
    );
  }
}
