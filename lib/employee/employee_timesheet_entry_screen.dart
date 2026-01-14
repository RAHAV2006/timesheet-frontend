import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EmployeeTimesheetEntryScreen extends StatefulWidget {
  final Map user;
  final Map? existingTimesheet;

  const EmployeeTimesheetEntryScreen({
    super.key,
    required this.user,
    this.existingTimesheet,
  });

  @override
  State<EmployeeTimesheetEntryScreen> createState() =>
      _EmployeeTimesheetEntryScreenState();
}

class _EmployeeTimesheetEntryScreenState
    extends State<EmployeeTimesheetEntryScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  int? timesheetId;
  String status = "draft";
  bool get locked => status == "submitted";

  List projects = [];
  List<Map<String, dynamic>> rows = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    // ✅ FIX 1: SET MONTH & YEAR WHEN EDITING DRAFT
    if (widget.existingTimesheet != null) {
      selectedMonth = widget.existingTimesheet!["month"];
      selectedYear = widget.existingTimesheet!["year"];
    }

    _loadTimesheet();
  }

  int daysInMonth(int m, int y) => DateTime(y, m + 1, 0).day;

  // ---------------- ADD ROW ----------------
  void _addRow() {
    rows.add({
      "project_id": null,
      "hours": <int, TextEditingController>{},
    });
    setState(() {});
  }


  Future<void> _handleExit() async {
  bool hasData = false;

  for (var row in rows) {
    if (row["project_id"] != null) {
      hasData = true;
      break;
    }
    for (var ctl in row["hours"].values) {
      if (ctl.text.trim().isNotEmpty &&
          ctl.text.trim() != "00:00") {
        hasData = true;
        break;
      }
    }
  }

  // ❌ nothing entered → exit silently
  if (!hasData) {
    Navigator.pop(context);
    return;
  }

  final action = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Exit Timesheet"),
      content: const Text(
        "Do you want to save this timesheet as draft before exiting?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, "discard"),
          child: const Text("Discard"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, "save"),
          child: const Text("Save Draft"),
        ),
      ],
    ),
  );

  if (action == "save") {
    await _saveDraft();
  }

  Navigator.pop(context);
}



  // ---------------- SAVE DRAFT ----------------
  Future<void> _saveDraft() async {
    if (status == "submitted") return;

    List payload = [];

    for (var row in rows) {
      final pid = row["project_id"];
      if (pid == null) continue;

      row["hours"].forEach((day, ctl) {
        if (ctl.text.trim().isNotEmpty) {
          payload.add({
            "project_id": pid,
            "day": day,
            "hours": ctl.text.trim(),
          });
        }
      });
    }

    // ⛔ Do nothing if empty
if (payload.isEmpty) return;

// ✅ Create timesheet lazily
if (timesheetId == null) {
  final ts = await ApiService.createNewTimesheet(
    widget.user["id"],
    selectedMonth,
    selectedYear,
  );
  timesheetId = ts["id"];
}


    await ApiService.saveTimesheet(timesheetId!, payload);
  }


  


  
  // ---------------- LOAD TIMESHEET ----------------
  Future<void> _loadTimesheet() async {
    try {
      setState(() => loading = true);

      projects = await ApiService.getProjects();
      rows.clear();

      // CASE 1: EDIT EXISTING
      if (widget.existingTimesheet != null) {
        timesheetId = widget.existingTimesheet!["id"];
        status = widget.existingTimesheet!["status"];

        final entries =
            await ApiService.getTimesheetEntries(timesheetId!);

        if (entries.isEmpty) {
          _addRow();
        } else {
          final grouped = <int, Map<int, String>>{};
          for (var e in entries) {
            grouped.putIfAbsent(e["project_id"], () => {});
            grouped[e["project_id"]]![e["day"]] = e["hours"];
          }

          grouped.forEach((pid, data) {
            rows.add({
              "project_id": pid,
              "hours": {
                for (var d in data.keys)
                  d: TextEditingController(text: data[d])
              }
            });
          });
        }
      }

      // CASE 2: NEW TIMESHEET
      else {
       _addRow(); // UI only — no backend call

      }

      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  Future<void> _submit() async {
    await _saveDraft();
    await ApiService.submitTimesheet(timesheetId!);
    Navigator.pop(context); // ✅ ONLY EXIT POINT
  }

  // ======================= UI =======================
  @override
  Widget build(BuildContext context) {
    final days = daysInMonth(selectedMonth, selectedYear);

    return WillPopScope(
      // ✅ FIX 2: BLOCK SWIPE / BACK
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
  title: const Text("Timesheet Entry"),
  automaticallyImplyLeading: false,
  actions: [
    IconButton(
      tooltip: "Close",
      icon: const Icon(Icons.close),
      onPressed: () async {
        await _handleExit();
      },
    )
  ],
),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _header(),

                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            _tableHeader(days),
                            ...List.generate(
                              rows.length,
                              (i) => _rowWidget(i, days),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  _footer(),
                ],
              ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          DropdownButton<int>(
            value: selectedMonth,
            items: List.generate(
              12,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text([
                  "January","February","March","April","May","June",
                  "July","August","September","October","November","December"
                ][i]),
              ),
            ),
            onChanged: locked
                ? null
                : (v) {
                    selectedMonth = v!;
                    _loadTimesheet();
                  },
          ),
          const SizedBox(width: 20),
          DropdownButton<int>(
            value: selectedYear,
            items: List.generate(
              5,
              (i) => DropdownMenuItem(
                value: DateTime.now().year - i,
                child: Text("${DateTime.now().year - i}"),
              ),
            ),
            onChanged: locked
                ? null
                : (v) {
                    selectedYear = v!;
                    _loadTimesheet();
                  },
          ),
        ],
      ),
    );
  }

  // ---------------- TABLE HEADER ----------------
  Widget _tableHeader(int days) {
    return Container(
      color: Colors.grey.shade200,
      child: Row(
        children: [
          _cell("S.No", 60, bold: true),
          _cell("Project", 160, bold: true),
          ...List.generate(
            days,
            (d) => _cell("${d + 1}", 90, bold: true),
          ),
        ],
      ),
    );
  }

  // ---------------- UNIQUE PROJECT ROW ----------------
  Widget _rowWidget(int index, int days) {
    final row = rows[index];

    final selectedInOtherRows = rows
        .where((r) => r != row && r["project_id"] != null)
        .map((r) => r["project_id"])
        .toSet();

    final availableProjects = projects.where((p) {
      return !selectedInOtherRows.contains(p["id"]) ||
          p["id"] == row["project_id"];
    }).toList();

    final availableIds =
        availableProjects.map((p) => p["id"]).toSet();
    final selectedValue =
        availableIds.contains(row["project_id"])
            ? row["project_id"]
            : null;

    return Row(
      children: [
        _cell("${index + 1}", 60),
        SizedBox(
          width: 160,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: DropdownButtonFormField<int>(
              value: selectedValue,
              items: availableProjects
                  .map((p) => DropdownMenuItem<int>(
                        value: p["id"],
                        child: Text(p["name"]),
                      ))
                  .toList(),
              onChanged: locked
                  ? null
                  : (v) => setState(() => row["project_id"] = v),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
        ...List.generate(days, (d) {
          row["hours"].putIfAbsent(
            d + 1,
            () => TextEditingController(text: "00:00"),
          );
          return SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: TextField(
                controller: row["hours"][d + 1],
                enabled: !locked,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ---------------- FOOTER ----------------
  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: locked ? null : _addRow,
            icon: const Icon(Icons.add),
            label: const Text("Add Row"),
          ),
          const Spacer(),
          OutlinedButton(
  onPressed: locked
      ? null
      : () async {
          await _saveDraft();
          Navigator.pop(context); // ✅ EXIT AFTER SAVE
        },
  child: const Text("Save as Draft"),
),

          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: locked ? null : _submit,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, double width, {bool bold = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ),
    );
  }
}
