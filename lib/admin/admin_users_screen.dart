import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool loading = false;
  List users = [];
  List filteredUsers = [];

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => loading = true);
    users = await ApiService.getAdminUsers();
    filteredUsers = users;
    setState(() => loading = false);
  }

  // ---------------- SEARCH ----------------
  void filterUsers(String q) {
    setState(() {
      filteredUsers = users.where((u) {
        return (u["name"] ?? "")
                .toLowerCase()
                .contains(q.toLowerCase()) ||
            (u["email"] ?? "")
                .toLowerCase()
                .contains(q.toLowerCase()) ||
            (u["emp_id"] ?? "")
                .toLowerCase()
                .contains(q.toLowerCase()) ||
            (u["role"] ?? "")
                .toLowerCase()
                .contains(q.toLowerCase());
      }).toList();
    });
  }

  // ---------------- CREATE / EDIT DIALOG ----------------
  void openUserDialog({Map? user}) {
    final nameCtl = TextEditingController(text: user?["name"]);
    final emailCtl = TextEditingController(text: user?["email"]);
    final empIdCtl = TextEditingController(text: user?["emp_id"]);
    final deptCtl = TextEditingController(text: user?["department"]);
    final desigCtl = TextEditingController(text: user?["designation"]);
    final passwordCtl = TextEditingController();
    String role = user?["role"] ?? "employee";
    bool active = user?["active"] ?? true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user == null ? "Create User" : "Edit User"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field(nameCtl, "Name"),
              _field(emailCtl, "Email"),
              _field(empIdCtl, "Emp ID"),
              _field(deptCtl, "Department"),
              _field(desigCtl, "Designation"),
              _field(passwordCtl, "Password (optional)", obscure: true),
              DropdownButtonFormField(
                value: role,
                items: const [
                  DropdownMenuItem(value: "admin", child: Text("Admin")),
                  DropdownMenuItem(value: "manager", child: Text("Manager")),
                  DropdownMenuItem(
                      value: "employee", child: Text("Employee")),
                ],
                onChanged: (v) => role = v!,
                decoration: const InputDecoration(labelText: "Role"),
              ),
              SwitchListTile(
                title: const Text("Active"),
                value: active,
                onChanged: (v) => active = v,
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
            child: const Text("Save"),
            onPressed: () async {
              Navigator.pop(context);
              if (user == null) {
                await ApiService.createAdminUser({
                  "name": nameCtl.text,
                  "email": emailCtl.text,
                  "emp_id": empIdCtl.text,
                  "department": deptCtl.text,
                  "designation": desigCtl.text,
                  "password": passwordCtl.text,
                  "role": role,
                });
              } else {
                await ApiService.updateAdminUser(
                  user["id"],
                  {
                    "name": nameCtl.text,
                    "email": emailCtl.text,
                    "emp_id": empIdCtl.text,
                    "department": deptCtl.text,
                    "designation": desigCtl.text,
                    "password":
                        passwordCtl.text.isEmpty ? null : passwordCtl.text,
                    "role": role,
                    "active": active,
                  },
                );
              }
              fetchUsers();
            },
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openUserDialog(),
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
                      labelText: "Search Name / Email / Emp ID / Role",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filterUsers,
                  ),
                ),
                Expanded(
                  child: PaginatedDataTable(
                    header: const Text("Users"),
                    rowsPerPage: 5,
                    columns: const [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Email")),
                      DataColumn(label: Text("Emp ID")),
                      DataColumn(label: Text("Role")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Action")),
                    ],
                    source: _UserDataSource(
                      filteredUsers,
                      openUserDialog,
                      fetchUsers,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------- DATASOURCE ----------------
class _UserDataSource extends DataTableSource {
  final List data;
  final Function({Map? user}) openUserDialog;
  final Function refresh;

  _UserDataSource(this.data, this.openUserDialog, this.refresh);

  @override
  DataRow getRow(int index) {
    final u = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(u["name"])),
        DataCell(Text(u["email"])),
        DataCell(Text(u["emp_id"] ?? "-")),
        DataCell(Text(u["role"])),
        DataCell(
          Text(
            u["active"] ? "Active" : "Inactive",
            style: TextStyle(
              color: u["active"] ? Colors.green : Colors.red,
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => openUserDialog(user: u),
              ),
              IconButton(
                icon: Icon(
                  u["active"] ? Icons.block : Icons.check_circle,
                  color: u["active"] ? Colors.red : Colors.green,
                ),
                onPressed: () async {
                  await ApiService.toggleAdminUser(u["id"]);
                  refresh();
                },
              ),
            ],
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
