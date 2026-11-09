import 'package:flutter/material.dart';

class ConnectionStatusBanner extends StatelessWidget {
  final bool sincronizadoEnNube;
  final bool guardando;

  const ConnectionStatusBanner({
    super.key,
    required this.sincronizadoEnNube,
    required this.guardando,
  });

  @override
  Widget build(BuildContext context) {
    final colorEstado = sincronizadoEnNube
        ? const Color(0xFF168321)
        : const Color(0xFFED6B00);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: sincronizadoEnNube
            ? const Color(0xFFEAF7EC)
            : const Color(0xFFFFF4E5),
        border: Border(
          bottom: BorderSide(
            color: sincronizadoEnNube
                ? const Color(0xFFB7E1CD)
                : const Color(0xFFFFCC80),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            sincronizadoEnNube ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: colorEstado,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sincronizadoEnNube
                  ? 'Conectado · Autoguardado en tiempo real (Local + Firestore)'
                  : 'Modo Local Offline · Se sincronizará al recuperar red',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: sincronizadoEnNube
                    ? const Color(0xFF168321)
                    : const Color(0xFF8C3B00),
              ),
            ),
          ),
          if (guardando)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class SurveyorInfoCard extends StatelessWidget {
  final String email;

  const SurveyorInfoCard({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF7900)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: Color(0xFFFF5900),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Encuestador activo: $email',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8C3B00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
