// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullNameCtl = TextEditingController();
  final TextEditingController emailCtl = TextEditingController();
  final TextEditingController passwordCtl = TextEditingController();
  final TextEditingController adminSecretCtl = TextEditingController();

  bool loading = false;
  final Color primaryRed = const Color(0xFFE53935);

  Future<void> _registerAdmin() async {
    setState(() => loading = true);

    final res = await ApiService.register(
      fullNameCtl.text.trim(),
      emailCtl.text.trim(),
      passwordCtl.text.trim(),
      role: "admin",
      secret: adminSecretCtl.text.trim(),
    );

    setState(() => loading = false);

    if (res.containsKey("error")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["error"])));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin account created")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.grey.shade100],
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
                      height: 75,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      "Register Admin",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryRed,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: Text(
                      "Admin-only registration",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  TextField(
                    controller: fullNameCtl,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      prefixIcon:
                          Icon(Icons.person, color: primaryRed),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: emailCtl,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon:
                          Icon(Icons.email, color: primaryRed),
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
                      prefixIcon:
                          Icon(Icons.lock, color: primaryRed),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: adminSecretCtl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Admin Secret Key",
                      prefixIcon:
                          Icon(Icons.vpn_key, color: primaryRed),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  ElevatedButton(
                    onPressed: loading ? null : _registerAdmin,
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
                            "CREATE ADMIN ACCOUNT",
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 1,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        "Already have an account? Login",
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
