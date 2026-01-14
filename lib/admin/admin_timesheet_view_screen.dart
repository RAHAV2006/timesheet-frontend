import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminTimesheetViewScreen extends StatefulWidget {
  final Map timesheet;
  final int userId;

  const AdminTimesheetViewScreen({
    Key? key,
    required this.timesheet,
    required this.userId,
  }) : super(key: key);

  @override
  State<AdminTimesheetViewScreen> createState() =>
      _AdminTimesheetViewScreenState();
}

class _AdminTimesheetViewScreenState
    extends State<AdminTimesheetViewScreen> {
  bool loading = true;
  List projects = [];
  List entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ApiService.getProjects();
      final e =
          await ApiService.getTimesheetEntries(widget.timesheet["id"]);

      setState(() {
        projects = p;
        entries = e;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load timesheet")),
      );
    }
  }

  int daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  bool _isWeekend(int day) {
    final date = DateTime(
      widget.timesheet["year"],
      widget.timesheet["month"],
      day,
    );
    return date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
  }

  @override
  Widget build(BuildContext context) {
    final int month = widget.timesheet["month"];
    final int year = widget.timesheet["year"];
    final int days = daysInMonth(month, year);

    return Scaffold(
      appBar: AppBar(
        title: Text("Emp ID: ${widget.userId} | $month/$year"),
        actions: [
          IconButton(
            tooltip: "Export Excel",
            icon: const Icon(Icons.table_view),
            onPressed: () {
              final url =
                  "http://127.0.0.1:5000/export/excel/${widget.timesheet["id"]}";
              html.window.open(url, "_blank");
            },
          ),
          IconButton(
            tooltip: "Export PDF",
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              final url =
                  "http://127.0.0.1:5000/export/pdf/${widget.timesheet["id"]}";
              html.window.open(url, "_blank");
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  _header(days),
                  ..._rows(days),
                  _totalRow(days),
                ],
              ),
            ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(int days) {
    return Container(
      color: Colors.grey.shade300,
      child: Row(
        children: [
          _cell("Project", 200, bold: true),
          ...List.generate(days, (d) {
            return Container(
              color: _isWeekend(d + 1)
                  ? Colors.grey.shade400
                  : Colors.grey.shade300,
              child: _cell("${d + 1}", 80, bold: true),
            );
          }),
        ],
      ),
    );
  }

  // ---------------- ROWS ----------------
  List<Widget> _rows(int days) {
    final Map<int, Map<int, String>> grouped = {};

    for (var e in entries) {
      final int day = e["day"];

      // ✅ SAFETY GUARD (FIXES RANGE ERROR)
      if (day < 1 || day > days) continue;

      grouped.putIfAbsent(e["project_id"], () => {});
      grouped[e["project_id"]]![day] = e["hours"];
    }

    return grouped.entries.map((entry) {
      final project = projects.firstWhere(
        (p) => p["id"] == entry.key,
        orElse: () => {"name": "Unknown"},
      );

      return Row(
        children: [
          _cell(project["name"], 200),
          ...List.generate(days, (d) {
            final val = entry.value[d + 1] ?? "00:00";
            final isLeave =
                val.toUpperCase() == "P" || val.toUpperCase() == "C";

            return Container(
              color: (_isWeekend(d + 1) || isLeave)
                  ? Colors.grey.shade300
                  : null,
              child: _cell(val, 80),
            );
          }),
        ],
      );
    }).toList();
  }

  // ---------------- TOTAL ROW ----------------
  Widget _totalRow(int days) {
    final List<int> totalMinutes = List.filled(days, 0);
    final Map<int, String> leaveTypeByDay = {};

    for (var e in entries) {
      final int dayIndex = e["day"] - 1;

      // ✅ SAFETY GUARD (FIXES RANGE ERROR)
      if (dayIndex < 0 || dayIndex >= days) continue;

      final val = e["hours"].toUpperCase();

      if (val == "P" || val == "C") {
        leaveTypeByDay[dayIndex] = val;
        continue;
      }

      if (val.contains(":")) {
        final parts = val.split(":");
        totalMinutes[dayIndex] +=
            int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
    }

    return Container(
      color: Colors.grey.shade200,
      child: Row(
        children: [
          _cell("TOTAL", 200, bold: true),
          ...List.generate(days, (d) {
            if (leaveTypeByDay.containsKey(d)) {
              return Container(
                color: Colors.grey.shade300,
                child: _cell(
                  leaveTypeByDay[d]!,
                  80,
                  bold: true,
                ),
              );
            }

            final h = totalMinutes[d] ~/ 60;
            final m = totalMinutes[d] % 60;

            return Container(
              color: _isWeekend(d + 1)
                  ? Colors.grey.shade300
                  : null,
              child: _cell(
                "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
                80,
                bold: true,
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------- CELL ----------------
  Widget _cell(String text, double width, {bool bold = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: bold
              ? const TextStyle(fontWeight: FontWeight.bold)
              : null,
        ),
      ),
    );
  }
}
