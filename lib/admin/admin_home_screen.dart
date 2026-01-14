import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'admin_users_screen.dart';
import 'admin_projects_screen.dart';
import 'admin_timesheet_history_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final String token;
  final Map user;

  const AdminHomeScreen({
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

            // ✅ APPBEEZ TEXT
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 WELCOME
            Text(
              "Welcome, ${user['name']}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Admin Dashboard",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // 📊 DASHBOARD GRID
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _dashboardCard(
                  context,
                  title: "Users",
                  icon: Icons.people,
                  color: primaryRed,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminUsersScreen(),
                      ),
                    );
                  },
                ),
                _dashboardCard(
                  context,
                  title: "Projects",
                  icon: Icons.work_outline,
                  color: Colors.black,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminProjectsScreen(),
                      ),
                    );
                  },
                ),
                _dashboardCard(
                  context,
                  title: "Timesheets",
                  icon: Icons.table_chart,
                  color: Colors.grey.shade800,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminTimesheetHistoryScreen(),
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

  // 🧱 DASHBOARD CARD
  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 46, color: Colors.white),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
