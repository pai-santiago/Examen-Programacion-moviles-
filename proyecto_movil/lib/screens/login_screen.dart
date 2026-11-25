import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _cargando = false;
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _navegarADashboard(UserModel usuario) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => DashboardPage(usuario: usuario)),
    );
  }

  String _mensajeErrorAmigable(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe ninguna cuenta registrada con ese correo en Firebase Auth.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos. Verifica tus datos e intenta de nuevo.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta de usuario ha sido deshabilitada por el administrador.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Espera unos minutos antes de volver a intentar.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Revisa tu red e intenta de nuevo.';
      default:
        return 'No se pudo iniciar sesión. Verifica tus datos e intenta de nuevo.';
    }
  }

  Future<void> _login() async {
    if (!formKey.currentState!.validate()) return;

    final firestoreService = FirestoreService();
    final correoNormalizado = UserModel.normalizarCorreo(_usuarioCtrl.text);
    final password = _passwordCtrl.text;

    setState(() => _cargando = true);
    try {
      final UserModel usuario = await firestoreService
          .iniciarSesionYObtenerPerfil(
            email: correoNormalizado,
            password: password,
          );

      _navegarADashboard(usuario);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(_mensajeErrorAmigable(e.code))),
            ],
          ),
        ),
      );
    } on FirebaseException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          content: const Text(
            'No pudimos cargar tu perfil. Revisa tu conexión o los permisos de tu cuenta.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocurrió un problema. Intenta iniciar sesión de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        const SizedBox(height: 24),
                        const Text(
                          'JUVENTUD Y FAMILIA MISIONERA\nCONEVAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: red,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Plataforma de Encuestas Nacionales',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF655D58),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 24,
                                offset: Offset(0, 9),
                              ),
                            ],
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Ingresa tu usuario o correo institucional (si escribes solo tu ID se agregará @anahuac.mx automáticamente).',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF807671),
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'CORREO O ID DE USUARIO',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _usuarioCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      size: 22,
                                    ),
                                    hintText:
                                        'ej. misionero1 o admin@anahuac.mx',
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().length < 3
                                      ? 'Ingresa tu usuario o correo institucional'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'CONTRASEÑA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _ocultarPassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _login(),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      size: 20,
                                    ),
                                    hintText: '••••••••',
                                    suffixIcon: IconButton(
                                      tooltip: _ocultarPassword
                                          ? 'Mostrar contraseña'
                                          : 'Ocultar contraseña',
                                      icon: Icon(
                                        _ocultarPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _ocultarPassword = !_ocultarPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) =>
                                      value == null || value.length < 6
                                      ? 'Ingresa tu contraseña (mínimo 6 caracteres)'
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: FilledButton.icon(
                                    onPressed: _cargando ? null : _login,
                                    icon: _cargando
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.arrow_forward,
                                            size: 20,
                                          ),
                                    label: const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      elevation: 4,
                                      shadowColor: red.withValues(alpha: .35),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  '¿No tienes acceso? Solicita tu cuenta al administrador de la plataforma.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: Color(0xFF625B56),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                        const SizedBox(height: 24),
                        const Text(
                          'Red Anáhuac · Acceso institucional',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFAAA29D),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
