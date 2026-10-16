import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart'; // Imports the 'red' color
import 'dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final id = TextEditingController();
  @override
  void dispose() {
    id.dispose();
    super.dispose();
  }

  void login() {
    if (formKey.currentState!.validate()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        const SizedBox(height: 40),
                        const Text(
                          'JUVENTUD Y FAMILIA MISIONERA\nCONEVAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Plataforma de Encuestas Nacionales',
                          style: TextStyle(fontSize: 12, color: Color(0xFF655D58)),
                        ),
                        const SizedBox(height: 70),
                        Container(
                          padding: const EdgeInsets.all(25),
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
                                const SizedBox(height: 8),
                                const Text(
                                  'Ingresa tus credenciales de encuestador autorizado.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF807671),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 27),
                                const Text(
                                  'ID DE ENCUESTADOR',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: id,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => login(),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      size: 22,
                                    ),
                                    hintText: '9582 - _',
                                  ),
                                  validator: (value) =>
                                      value == null || value.length < 4
                                          ? 'Ingresa un ID de al menos 4 dígitos'
                                          : null,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: FilledButton.icon(
                                    onPressed: login,
                                    icon: const Icon(Icons.arrow_forward, size: 20),
                                    label: const Text(
                                      'Ingresar',
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
                                const SizedBox(height: 30),
                                const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Color(0xFFFF5700),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Contacta a tu coordinador de zona si no tienes ID asignado o si tienes problemas de acceso.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                          color: Color(0xFF807671),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                        const SizedBox(height: 40),
                        const Text(
                          'v2.4.1 (Compilación 102)',
                          style: TextStyle(fontSize: 10, color: Color(0xFFAAA29D)),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}