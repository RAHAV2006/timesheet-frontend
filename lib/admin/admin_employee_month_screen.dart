import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_timesheet_view_screen.dart';

class AdminEmployeeMonthScreen extends StatefulWidget {
  final Map employee;

  const AdminEmployeeMonthScreen({
    super.key,
    required this.employee,
  });

  @override
  State<AdminEmployeeMonthScreen> createState() =>
      _AdminEmployeeMonthScreenState();
}

class _AdminEmployeeMonthScreenState
    extends State<AdminEmployeeMonthScreen> {
  bool loading = true;
  List months = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    months =
        await ApiService.adminEmployeeMonths(widget.employee["id"]);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee["name"]),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: months.length,
              itemBuilder: (c, i) {
                final m = months[i];
                return Card(
                  child: ListTile(
                    title: Text("${m["month"]}/${m["year"]}"),
                    subtitle: Text("Status: ${m["status"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminTimesheetViewScreen(
                                  timesheet: m,
                                  userId:
                                      widget.employee["id"],
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: () =>
                              confirmDraft(m["id"]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void confirmDraft(int tsId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Send to Draft"),
        content: const Text(
            "Are you sure you want to send this timesheet back to draft?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.sendTimesheetToDraft(tsId);
              Navigator.pop(context);
              load();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
