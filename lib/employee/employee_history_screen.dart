import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'employee_timesheet_entry_screen.dart';
import 'employee_timesheet_view_screen.dart';

class EmployeeTimesheetHistoryScreen extends StatefulWidget {
  final int userId;

  const EmployeeTimesheetHistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<EmployeeTimesheetHistoryScreen> createState() =>
      _EmployeeTimesheetHistoryScreenState();
}

class _EmployeeTimesheetHistoryScreenState
    extends State<EmployeeTimesheetHistoryScreen> {
  bool loading = true;
  List sheets = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    sheets = await ApiService.history(widget.userId);
    setState(() => loading = false);
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
          : sheets.isEmpty
              ? const Center(
                  child: Text(
                    "No timesheets found",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sheets.length,
                  itemBuilder: (_, i) {
                    final s = sheets[i];
                    final isDraft = s["status"] == "draft";

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Month / Year
                            Text(
                              "Month: ${s["month"]} / ${s["year"]}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Status badge
                            Row(
                              children: [
                                const Text(
                                  "Status: ",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDraft
                                        ? Colors.orange.shade100
                                        : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    s["status"].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDraft
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // VIEW
                                IconButton(
                                  tooltip: "View",
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EmployeeTimesheetViewScreen(
                                          timesheet: s,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // EDIT (Draft only)
                                if (isDraft)
                                  IconButton(
                                    tooltip: "Edit Draft",
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EmployeeTimesheetEntryScreen(
                                            user: {"id": widget.userId},
                                            existingTimesheet: s,
                                          ),
                                        ),
                                      ).then((_) => load());
                                    },
                                  ),

                                // SUBMIT (Draft only)
                                
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void confirmSubmit(int tsId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Submit Timesheet"),
        content: const Text(
          "Are you sure you want to submit this timesheet?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.submitTimesheet(tsId);
              Navigator.pop(context);
              load();
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
