import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 3), openLogin);
  }

  void openLogin() {
    if (!mounted) return;
    timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onTap: openLogin,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Color(0xFFFF6806), Color(0xFFC80020)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 4),
                  Image.asset(
                    'assets/anahuac-orange.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(flex: 3),
                  const Text(
                    'Red Anáhuac',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'JUVENTUD Y FAMILIA MISIONERA\nCONEVAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(flex: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: i == 0 ? 1 : .45),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Inicializando ...',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(
                    width: 136,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: Color(0xFFFFC28D),
                      backgroundColor: Color(0x55FFFFFF),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      );
}