import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_employee_month_screen.dart';

class AdminTimesheetHistoryScreen extends StatefulWidget {
  @override
  State<AdminTimesheetHistoryScreen> createState() =>
      _AdminTimesheetHistoryScreenState();
}

class _AdminTimesheetHistoryScreenState
    extends State<AdminTimesheetHistoryScreen> {
  bool loading = true;
  List employees = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      debugPrint("ADMIN HISTORY → loading employees...");
      employees = await ApiService.adminTimesheetEmployees();
      debugPrint(
          "ADMIN HISTORY → loaded ${employees.length} employees");
    } catch (e) {
      debugPrint("ADMIN HISTORY ERROR: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timesheet History"),
        elevation: 2,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : employees.isEmpty
              ? const Center(
                  child: Text(
                    "No submitted timesheets found",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: employees.length,
                  itemBuilder: (c, i) {
                    final e = employees[i];

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        // 👤 Avatar
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              Colors.red.shade100,
                          child: Text(
                            e["name"]
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        // 👤 Name
                        title: Text(
                          e["name"],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        // 🆔 Emp ID
                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(top: 4),
                          child: Text(
                            "Employee ID: ${e["emp_id"] ?? '-'}",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),

                        // ➡️ Arrow
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),

                        // 👉 Navigate
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminEmployeeMonthScreen(
                                employee: e,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
