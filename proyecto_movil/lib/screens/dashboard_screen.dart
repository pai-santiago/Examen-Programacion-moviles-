import 'package:flutter/material.dart';
import '../main.dart'; // Imports the 'red' color

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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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