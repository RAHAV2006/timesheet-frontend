import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_timesheet_view_screen.dart';


class AdminTimesheetsScreen extends StatefulWidget {
  const AdminTimesheetsScreen({super.key});

  @override
  State<AdminTimesheetsScreen> createState() =>
      _AdminTimesheetsScreenState();
}

class _AdminTimesheetsScreenState
    extends State<AdminTimesheetsScreen> {
  List sheets = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadTimesheets();
  }

 Future<void> loadTimesheets() async {
  setState(() => loading = true);

  final all = await ApiService.getAdminTimesheets();

  // ✅ SAFETY FILTER (even if backend changes later)
  sheets = all.where((s) => s["status"] == "submitted").toList();

  setState(() => loading = false);
}


  Future<void> sendToDraft(int id) async {
    await ApiService.sendToDraft(id);
    loadTimesheets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Timesheet Review")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : sheets.isEmpty
              ? const Center(child: Text("No timesheets found"))
              : ListView.builder(
                  itemCount: sheets.length,
                  itemBuilder: (_, i) {
                    final s = sheets[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          "Emp ID: ${s['user_id']}  |  ${s['month']}/${s['year']}",
                        ),
                        subtitle: Text("Status: ${s['status']}"),
                        trailing: Wrap(
                          spacing: 10,
                          children: [
                            IconButton(
  tooltip: "Export Excel",
  icon: const Icon(Icons.table_view),
  onPressed: () async {
    try {
      await ApiService.exportExcel(s['id']); // ✅ timesheet_id
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Excel exported successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to export Excel")),
      );
    }
  },
),
IconButton(
  tooltip: "Export PDF",
  icon: const Icon(Icons.picture_as_pdf),
  onPressed: () async {
    try {
      await ApiService.exportPdf(s['id']); // ✅ timesheet_id
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF exported successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to export PDF")),
      );
    }
  },
),

                            IconButton(
  tooltip: "View Timesheet",
  icon: const Icon(Icons.visibility),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminTimesheetViewScreen(
          timesheet: s,
          userId: s['user_id'], // ✅ FIXED
        ),
      ),
    );
  },
),


                            if (s['status'] == "submitted")
                              IconButton(
                                tooltip: "Send to Draft",
                                icon: const Icon(
                                  Icons.undo,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    sendToDraft(s['id']),
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
