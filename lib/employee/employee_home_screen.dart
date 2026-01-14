import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'employee_timesheet_entry_screen.dart';
import 'employee_history_screen.dart';

class EmployeeHomeScreen extends StatelessWidget {
  final String token;
  final Map user;

  const EmployeeHomeScreen({
    super.key,
    required this.token,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFC62828);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Row(
          children: [
            // ✅ LOGO
            const Image(
              image: AssetImage("assets/logo.png"),
              height: 52,
            ),
            const SizedBox(width: 16),

            // ✅ APPBEEZ TEXT (APP = RED, BEEZ = GREY)
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "APP",
                    style: TextStyle(
                      color: primaryRed,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: "BEEZ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 WELCOME
            Text(
              "Welcome, ${user["name"]}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Employee Dashboard",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 👤 EMPLOYEE INFO CARD
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    primaryRed.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Employee Information",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: Colors.white54),

                    _info("Employee ID", user["emp_id"]),
                    _info("Name", user["name"]),
                    _info("Email", user["email"] ?? "-"),
                    _info("Department", user["department"] ?? "-"),
                    _info("Designation", user["designation"] ?? "-"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🚀 ACTION BUTTONS
            Row(
              children: [
                _actionCard(
                  context,
                  icon: Icons.edit_calendar,
                  title: "Timesheet",
                  subtitle: "Fill your work hours",
                  color: primaryRed,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmployeeTimesheetEntryScreen(
                          user: user,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _actionCard(
                  context,
                  icon: Icons.history,
                  title: "History",
                  subtitle: "View submissions",
                  color: Colors.black,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmployeeTimesheetHistoryScreen(
                          userId: user["id"],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🧾 INFO ROW
  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 🔘 ACTION CARD
  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 36, color: Colors.white),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
