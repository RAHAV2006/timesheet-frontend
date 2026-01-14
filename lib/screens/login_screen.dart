// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../admin/admin_home_screen.dart';
import '../employee/employee_home_screen.dart';
import '../services/api_service.dart';
import 'register_screen.dart';

// ✅ Correct screens



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtl = TextEditingController();
  final TextEditingController passwordCtl = TextEditingController();
  bool loading = false;

  final Color primaryRed = const Color(0xFFE53935);

  Future<void> _login() async {
    setState(() => loading = true);

    final res = await ApiService.login(
      emailCtl.text.trim(),
      passwordCtl.text.trim(),
    );

    setState(() => loading = false);

    if (res.containsKey("error")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["error"])));
      return;
    }

    final String token = res["token"];
    final Map<String, dynamic> user = res["user"];
    final String role = user["role"];

    if (role == "admin" || role == "manager") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminHomeScreen(
            token: token,
            user: user,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeeHomeScreen(
            token: token,
            user: user,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade200,
              Colors.grey.shade100,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      "assets/logo.png",
                      height: 80,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: "APP",
                            style: TextStyle(color: Color(0xFFE10600)),
                          ),
                          TextSpan(
                            text: "BEEZ",
                            style: TextStyle(color: Color(0xFFBDBDBD)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: Text(
                      "Timesheet Management System",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 22),

                  TextField(
                    controller: emailCtl,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email, color: primaryRed),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: passwordCtl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock, color: primaryRed),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  ElevatedButton(
                    onPressed: loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 1,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        "Register Admin",
                        style: TextStyle(
                          color: primaryRed,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
