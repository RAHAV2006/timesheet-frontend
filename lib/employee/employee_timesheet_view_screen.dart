import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EmployeeTimesheetViewScreen extends StatefulWidget {
  final Map timesheet;

  const EmployeeTimesheetViewScreen({
    super.key,
    required this.timesheet,
  });

  @override
  State<EmployeeTimesheetViewScreen> createState() =>
      _EmployeeTimesheetViewScreenState();
}

class _EmployeeTimesheetViewScreenState
    extends State<EmployeeTimesheetViewScreen> {
  bool loading = true;
  List entries = [];
  List projects = [];

  bool get isSubmitted => widget.timesheet["status"] == "submitted";

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    projects = await ApiService.getProjects();
    entries =
        await ApiService.getTimesheetEntries(widget.timesheet["id"]);
    setState(() => loading = false);
  }

  int daysInMonth(int m, int y) => DateTime(y, m + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final m = widget.timesheet["month"];
    final y = widget.timesheet["year"];
    final days = daysInMonth(m, y);

    return Scaffold(
      appBar: AppBar(
        title: Text("Timesheet • $m / $y"),
        elevation: 2,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      _header(days, m, y),
                      ..._rows(days, m, y),
                      if (isSubmitted) _totalRow(days),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ================= HEADER =================
  Widget _header(int days, int month, int year) {
    return Container(
      color: Colors.grey.shade200,
      child: Row(
        children: [
          _cell("Project", bold: true),
          ...List.generate(days, (i) {
            final date = DateTime(year, month, i + 1);
            final isWeekend =
                date.weekday == DateTime.saturday ||
                date.weekday == DateTime.sunday;

            return _cell(
              "${i + 1}",
              bold: true,
              bg: isSubmitted && isWeekend
                  ? Colors.grey.shade300
                  : null,
            );
          }),
        ],
      ),
    );
  }

  // ================= ROWS =================
  List<Widget> _rows(int days, int month, int year) {
    final Map<int, Map<int, String>> grouped = {};

    for (var e in entries) {
      grouped.putIfAbsent(e["project_id"], () => {});
      grouped[e["project_id"]]![e["day"]] = e["hours"];
    }

    return grouped.entries.map((row) {
      final project = projects.firstWhere(
        (p) => p["id"] == row.key,
        orElse: () => {"name": "Unknown"},
      );

      return Row(
        children: [
          _cell(project["name"]),
          ...List.generate(days, (d) {
            final value = row.value[d + 1] ?? "-";
            final date = DateTime(year, month, d + 1);

            Color? bg;
            if (isSubmitted) {
              if (value.toLowerCase() == "p" ||
                  value.toLowerCase() == "c") {
                bg = Colors.grey.shade300;
              } else if (date.weekday ==
                      DateTime.saturday ||
                  date.weekday == DateTime.sunday) {
                bg = Colors.grey.shade300;
              }
            }

            return _cell(value, bg: bg);
          }),
        ],
      );
    }).toList();
  }

  // ================= TOTAL ROW =================
  Widget _totalRow(int days) {
    final List<String> totals = List.filled(days, "00:00");

    for (int d = 1; d <= days; d++) {
      final dayEntries =
          entries.where((e) => e["day"] == d).toList();

      if (dayEntries.isEmpty) continue;

      final values = dayEntries.map((e) => e["hours"]).toList();

      if (values.every((v) => v.toLowerCase() == "p")) {
        totals[d - 1] = "P";
        continue;
      }
      if (values.every((v) => v.toLowerCase() == "c")) {
        totals[d - 1] = "C";
        continue;
      }

      int minutes = 0;
      for (var v in values) {
        if (v.contains(":")) {
          final parts = v.split(":");
          minutes +=
              int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }
      }

      totals[d - 1] =
          "${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}";
    }

    return Container(
      color: Colors.grey.shade100,
      child: Row(
        children: [
          _cell("TOTAL", bold: true),
          ...totals.map(
            (t) => _cell(
              t,
              bold: true,
              bg: (t == "P" || t == "C")
                  ? Colors.grey.shade300
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ================= CELL =================
  Widget _cell(
    String text, {
    bool bold = false,
    Color? bg,
  }) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      color: bg,
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: bold
            ? const TextStyle(fontWeight: FontWeight.bold)
            : null,
      ),
    );
  }
}
