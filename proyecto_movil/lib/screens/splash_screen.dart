import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late Future<UserModel?> _sesion;

  @override
  void initState() {
    super.initState();
    _sesion = _resolverSesion();
  }

  Future<UserModel?> _resolverSesion() async {
    final usuarioAuth = await FirebaseAuth.instance.authStateChanges().first;
    if (usuarioAuth == null) return null;
    return FirestoreService().obtenerPerfilUsuarioActual();
  }

  void _reintentar() {
    setState(() => _sesion = _resolverSesion());
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    setState(() => _sesion = _resolverSesion());
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<UserModel?>(
    future: _sesion,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _estadoInicial(
          mensaje: 'Preparando tu espacio de trabajo…',
          contenido: const SizedBox(
            width: 160,
            child: LinearProgressIndicator(
              minHeight: 3,
              color: Color(0xFFFFC28D),
              backgroundColor: Color(0x55FFFFFF),
            ),
          ),
        );
      }

      if (snapshot.hasError) {
        return _estadoInicial(
          mensaje: 'No pudimos cargar tu perfil. Revisa tu conexión o el acceso de tu cuenta.',
          contenido: Column(
            children: [
              FilledButton.icon(
                onPressed: _reintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _cerrarSesion,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        );
      }

      final usuario = snapshot.data;
      return usuario == null
          ? const LoginPage()
          : DashboardPage(usuario: usuario);
    },
  );

  Widget _estadoInicial({required String mensaje, required Widget contenido}) =>
      Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xFFFF6806), Color(0xFFC80020)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/anahuac-orange.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      semanticLabel: 'Red Anáhuac',
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Red Anáhuac',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'JUVENTUD Y FAMILIA MISIONERA · CONEVAL',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    contenido,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
