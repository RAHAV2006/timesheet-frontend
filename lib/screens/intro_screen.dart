import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1, curve: Curves.easeIn),
      ),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    // ⏭ Navigate to login after animation
    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 LOGO
            ScaleTransition(
              scale: _logoScale,
              child: Image.asset(
                "assets/logo.png", // ✅ your logo
                width: 120,
                height: 120,
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 APPBEEZ TEXT
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _slideUp,
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "APP",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          letterSpacing: 2,
                        ),
                      ),
                      TextSpan(
                        text: "BEEZ",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 TAGLINE
            FadeTransition(
              opacity: _textOpacity,
              child: const Text(
                "Smart Timesheet Management",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
