import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000";

  // ---------- AUTH ----------
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(res.body);
  }

  // ---------- ADMIN ----------
  



  // ---------- EXPORT (ADMIN VIEW) ----------

static Future<void> exportExcel(int timesheetId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/export/excel/$timesheetId'),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to export Excel");
  }
}

static Future<void> exportPdf(int timesheetId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/export/pdf/$timesheetId'),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to export PDF");
  }
}
static const Map<String, String> headers = {
  "Content-Type": "application/json",
};



// ---------- ADMIN USERS ----------
static Future<List> getAdminUsers() async {
  final res = await http.get(Uri.parse("$baseUrl/admin/users"));
  return jsonDecode(res.body);
}

static Future<void> createAdminUser(Map data) async {
  await http.post(
    Uri.parse("$baseUrl/admin/users"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );
}

static Future<void> updateAdminUser(int id, Map data) async {
  await http.put(
    Uri.parse("$baseUrl/admin/users/$id"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );
}

static Future<void> toggleAdminUser(int id) async {
  await http.put(
    Uri.parse("$baseUrl/admin/users/$id/toggle"),
  );
}

  

  // ---------- EMPLOYEE ----------
 static Future<List> getProjects() async {
  final res = await http.get(
    Uri.parse('$baseUrl/employee/projects'),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load projects");
  }

  return jsonDecode(res.body);
}


static Future<Map<String, dynamic>> createOrGetTimesheet(
  int userId,
  int month,
  int year,
) async {
  final res = await http.post(
    Uri.parse("$baseUrl/employee/timesheet"),
    headers: headers,
    body: jsonEncode({
      "user_id": userId,
      "month": month,
      "year": year,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to create timesheet");
  }

  return jsonDecode(res.body);
}


  static Future<void> saveTimesheet(
      int timesheetId, List entries) async {
    await http.post(
      Uri.parse("$baseUrl/employee/timesheet/save"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "timesheet_id": timesheetId,
        "entries": entries,
      }),
    );
  }


static Future<Map<String, dynamic>> createNewTimesheet(
  int userId,
  int month,
  int year,
) async {
  final res = await http.post(
    Uri.parse("$baseUrl/employee/timesheet/new"),
    headers: headers,
    body: jsonEncode({
      "user_id": userId,
      "month": month,
      "year": year,
    }),
  );

  final data = jsonDecode(res.body);

  if (res.statusCode != 200) {
    throw Exception(data["error"]);
  }

  return data;
}



// ---------- ADMIN PROJECTS ----------
static Future<List> getProjectsAdmin() async {
  final res =
      await http.get(Uri.parse("$baseUrl/admin/projects"));
  return jsonDecode(res.body);
}

static Future<void> createProject(Map data) async {
  await http.post(
    Uri.parse("$baseUrl/admin/create-project"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );
}

static Future<void> toggleProject(int projectId) async {
  await http.put(
    Uri.parse("$baseUrl/admin/toggle-project/$projectId"),
  );
}

// ---------- ADMIN TIMESHEETS ----------
static Future<List> getAdminTimesheets() async {
  final res =
      await http.get(Uri.parse("$baseUrl/admin/timesheets"));
  return jsonDecode(res.body);
}

static Future<void> sendToDraft(int timesheetId) async {
  await http.put(
    Uri.parse(
        "$baseUrl/admin/timesheet/send-to-draft/$timesheetId"),
  );
}


static Future<Map<String, dynamic>> register(
  String name,
  String email,
  String password, {
  required String role,
  required String secret,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/auth/register"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      "role": role,
      "secret": secret,
    }),
  );

  return jsonDecode(res.body);
}



static Future<void> createEmployee(Map data) async {
  await http.post(
    Uri.parse("$baseUrl/admin/create-user"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );
}


static Future<List> getTimesheetEntries(int tsId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/timesheet/$tsId/entries'),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load timesheet entries");
  }

  return jsonDecode(res.body);
}



static Future<List> adminTimesheetEmployees() async {
  final res = await http.get(
    Uri.parse('$baseUrl/admin/timesheet/employees'),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load employees");
  }
  return jsonDecode(res.body);
}

static Future<List> adminEmployeeMonths(int userId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/admin/timesheet/$userId/months'),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load months");
  }
  return jsonDecode(res.body);
}

static Future<void> sendTimesheetToDraft(int tsId) async {
  final res = await http.put(
    Uri.parse('$baseUrl/admin/timesheet/$tsId/draft'),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to send to draft");
  }
}




  static Future<void> submitTimesheet(int timesheetId) async {
    await http.put(Uri.parse(
        "$baseUrl/employee/timesheet/submit/$timesheetId"));
  }

  static Future<List> history(int userId) async {
    final res = await http.get(Uri.parse(
        "$baseUrl/employee/timesheet/history/$userId"));
    return jsonDecode(res.body);
  }
}
