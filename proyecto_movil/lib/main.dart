import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const red = Color(0xFFCF101B);
const background = Color(0xFFFAF8F6);
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Red Anáhuac · CONEVAL',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      fontFamily: 'Arial',
      colorScheme: ColorScheme.fromSeed(seedColor: red, primary: red),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE7DED9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE7DED9)),
        ),
      ),
    ),
    builder: (context, child) => ColoredBox(
      color: const Color(0xFFEDE9E5),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child!,
        ),
      ),
    ),
    home: const SplashPage(),
  );
}

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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  void showDetails(BuildContext context, bool saved) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  saved ? 'Encuestas guardadas' : 'Nueva Encuesta',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  saved
                      ? '12 encuestas completadas en este dispositivo.\n3 encuestas pendientes de sincronización.'
                      : 'La captura de encuestas estará disponible en la siguiente etapa del proyecto.',
                  style: const TextStyle(height: 1.6),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 21,
                  backgroundColor: red,
                  child: Text(
                    'MG',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, María García',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Encuestador Zona Sur',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF807671),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8EC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF24852C)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 7, color: Color(0xFF168321)),
                      SizedBox(width: 5),
                      Text(
                        'En línea',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF168321),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    constraints.maxHeight * .22,
                    22,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5E3),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFF7900)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.sync,
                              color: Color(0xFFFF7100),
                              size: 26,
                            ),
                            SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '3 encuestas pendientes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFED6B00),
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Se sincronizarán automáticamente al continuar en línea.',
                                    style: TextStyle(fontSize: 11, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 17),
                      Container(
                        decoration: BoxDecoration(
                          color: red,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: red.withValues(alpha: .2),
                              blurRadius: 18,
                              offset: const Offset(0, 9),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => showDetails(context, false),
                            child: const Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.add,
                                          color: red,
                                          size: 28,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Color(0xFFFF9C9F),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Nueva Encuesta',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Iniciar recolección de datos en campo.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFFFE3E3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'TU ACTIVIDAD RECIENTE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF625B56),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: Color(0xFFECE1DA)),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => showDetails(context, true),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7F4E8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Color(0xFF087C28),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Encuestas\nguardadas',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Registros locales\ntotales',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF807671),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7F4E8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '12 completadas',
                                    style: TextStyle(
                                      color: Color(0xFF006E18),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
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
          const Padding(
            padding: EdgeInsets.only(bottom: 30, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_outlined, size: 16, color: Color(0xFF807671)),
                SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'Última sincronización: hace 5 min',
                    style: TextStyle(fontSize: 11, color: Color(0xFF807671)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
