import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminProjectsScreen extends StatefulWidget {
  const AdminProjectsScreen({super.key});

  @override
  State<AdminProjectsScreen> createState() =>
      _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen> {
  List projects = [];
  List filteredProjects = [];
  bool loading = false;

  final TextEditingController nameCtl = TextEditingController();
  final TextEditingController clientCtl = TextEditingController();
  final TextEditingController startDateCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  // ---------------- LOAD PROJECTS ----------------
  Future<void> loadProjects() async {
    setState(() => loading = true);
    projects = await ApiService.getProjectsAdmin();
    _sortProjects();
    setState(() => loading = false);
  }

  // ---------------- SORT ACTIVE FIRST ----------------
  void _sortProjects() {
    projects.sort((a, b) {
      if (a["active"] == b["active"]) return 0;
      return a["active"] ? -1 : 1;
    });
    filterProjects(searchCtrl.text);
  }

  // ---------------- SEARCH ----------------
  void filterProjects(String q) {
    setState(() {
      filteredProjects = projects.where((p) {
        final name = (p["name"] ?? "").toLowerCase();
        final client = (p["client"] ?? "").toLowerCase();
        return name.contains(q.toLowerCase()) ||
            client.contains(q.toLowerCase());
      }).toList();
    });
  }

  // ---------------- CREATE PROJECT ----------------
  Future<void> createProject() async {
    await ApiService.createProject({
      "name": nameCtl.text.trim(),
      "client": clientCtl.text.trim(),
      "start_date":
          startDateCtrl.text.isEmpty ? null : startDateCtrl.text,
      "end_date":
          endDateCtrl.text.isEmpty ? null : endDateCtrl.text,
    });

    nameCtl.clear();
    clientCtl.clear();
    startDateCtrl.clear();
    endDateCtrl.clear();

    Navigator.pop(context);
    loadProjects();
  }

  // ---------------- TOGGLE ACTIVE (NO REFRESH JUMP) ----------------
  Future<void> toggleProject(int id) async {
    await ApiService.toggleProject(id);

    final index = projects.indexWhere((p) => p["id"] == id);
    if (index != -1) {
      projects[index]["active"] = !projects[index]["active"];
    }
    _sortProjects();
  }

  // ---------------- CREATE DIALOG ----------------
  void openCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Project"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                decoration:
                    const InputDecoration(labelText: "Project Name"),
              ),
              TextField(
                controller: clientCtl,
                decoration:
                    const InputDecoration(labelText: "Client"),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: startDateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Start Date (optional)",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (d != null) {
                    startDateCtrl.text =
                        d.toIso8601String().substring(0, 10);
                  }
                },
              ),

              TextField(
                controller: endDateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "End Date (optional)",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (d != null) {
                    endDateCtrl.text =
                        d.toIso8601String().substring(0, 10);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: createProject,
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Management")),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      labelText: "Search Project / Client",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filterProjects,
                  ),
                ),
                Expanded(
                  child: PaginatedDataTable(
                    header: const Text("Projects"),
                    rowsPerPage: 5,
                    columns: const [
                      DataColumn(label: Text("Project")),
                      DataColumn(label: Text("Client")),
                      DataColumn(label: Text("Start Date")),
                      DataColumn(label: Text("End Date")),
                      DataColumn(label: Text("Active")),
                    ],
                    source: _ProjectDataSource(
                      filteredProjects,
                      toggleProject,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------- DATASOURCE ----------------
class _ProjectDataSource extends DataTableSource {
  final List data;
  final Function(int) onToggle;

  _ProjectDataSource(this.data, this.onToggle);

  @override
  DataRow getRow(int index) {
    final p = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(p["name"] ?? "-")),
        DataCell(Text(p["client"] ?? "-")),
        DataCell(Text(p["start_date"] ?? "-")),
        DataCell(Text(p["end_date"] ?? "-")),
        DataCell(
          Switch(
            value: p["active"],
            onChanged: (_) => onToggle(p["id"]),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
