import 'package:flutter/material.dart';

class AdminInfoSection extends StatelessWidget {
  final String titulo;
  final List<Widget> hijos;

  const AdminInfoSection(this.titulo, this.hijos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFECE1DA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFF5900),
              ),
            ),
            const SizedBox(height: 8),
            ...hijos,
          ],
        ),
      ),
    );
  }
}

class AdminInfoRow extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const AdminInfoRow(this.etiqueta, this.valor, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF807671),
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminKpiCard extends StatelessWidget {
  final String titulo;
  final String valorPrincipal;
  final String subtitulo;
  final IconData icono;
  final Color color;

  const AdminKpiCard({
    super.key,
    required this.titulo,
    required this.valorPrincipal,
    required this.subtitulo,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE1DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF625B56),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            valorPrincipal,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitulo,
            style: const TextStyle(fontSize: 11, color: Color(0xFF807671)),
          ),
        ],
      ),
    );
  }
}

class AdminCountBar extends StatelessWidget {
  final String etiqueta;
  final int conteo;
  final int totalFamilias;
  final Color color;

  const AdminCountBar({
    super.key,
    required this.etiqueta,
    required this.conteo,
    required this.totalFamilias,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double proporcion = totalFamilias > 0
        ? (conteo / totalFamilias).clamp(0.0, 1.0)
        : 0.0;
    final porcentaje = (proporcion * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  etiqueta,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$conteo fam. ($porcentaje%)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF625B56),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: proporcion,
              minHeight: 8,
              color: color,
              backgroundColor: const Color(0xFFEDE7E3),
            ),
          ),
        ],
      ),
    );
  }
}
