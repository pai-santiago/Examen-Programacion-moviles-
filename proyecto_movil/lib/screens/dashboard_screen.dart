import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import 'admin_jfm_screen.dart';
import 'coneval_screen.dart';
import 'familia_misionera_screen.dart';
import 'login_screen.dart';

class DashboardPage extends StatelessWidget {
  final String rol; // 'enumerator' o 'admin'
  final String? usuarioEmail;
  final String? usuarioUid;
  final String encuestasPermitidas; // 'AMBAS', 'SOLO_JFM', 'SOLO_CONEVAL'

  const DashboardPage({
    super.key,
    this.rol = 'enumerator',
    this.usuarioEmail,
    this.usuarioUid,
    this.encuestasPermitidas = 'AMBAS',
  });

  String get _emailActivo =>
      usuarioEmail ??
      FirebaseAuth.instance.currentUser?.email ??
      (rol == 'admin' ? 'admin@anahuac.mx' : 'misionero_demo@anahuac.mx');

  String get _uidActivo =>
      usuarioUid ??
      FirebaseAuth.instance.currentUser?.uid ??
      'encuestador_anonimo';

  bool get _permiteJfm =>
      encuestasPermitidas == 'AMBAS' || encuestasPermitidas == 'SOLO_JFM';

  bool get _permiteConeval =>
      encuestasPermitidas == 'AMBAS' || encuestasPermitidas == 'SOLO_CONEVAL';

  void _mostrarSelectorCuestionario(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleccionar Cuestionario',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Instrumentos habilitados para tu perfil ($encuestasPermitidas).',
                style: const TextStyle(fontSize: 13, color: Color(0xFF807671)),
              ),
              const SizedBox(height: 18),
              if (_permiteJfm) ...[
                _tarjetaSelector(
                  context: sheetCtx,
                  titulo: 'Censo Juventud y Familia Misionera',
                  subtitulo:
                      'Datos demográficos, sacramentos, vida parroquial, problemáticas y seguimiento.',
                  etiqueta: 'FAMILIA_MISIONERA',
                  color: const Color(0xFFFF5900),
                  icono: Icons.family_restroom,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FamiliaMisioneraScreen(
                          usuarioEmail: _emailActivo,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
              ],
              if (_permiteConeval)
                _tarjetaSelector(
                  context: sheetCtx,
                  titulo: 'Diagnóstico Comunitario (CONEVAL)',
                  subtitulo:
                      'Indicadores socioeconómicos, carencias sociales y servicios básicos del hogar.',
                  etiqueta: 'CONEVAL',
                  color: red,
                  icono: Icons.analytics_outlined,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConevalScreen(
                          usuarioEmail: _emailActivo,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaSelector({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    required String etiqueta,
    required Color color,
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withValues(alpha: 0.45), width: 1.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icono, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        etiqueta,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF625B56),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleSoloLectura(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final respuestas =
        Map<String, dynamic>.from(data['respuestas'] as Map? ?? {});
    final tipo = (data['tipo_cuestionario'] ?? 'FAMILIA_MISIONERA').toString();
    final sede = (data['sede'] ?? respuestas['sede'] ?? 'Sin sede').toString();
    final comunidad =
        (data['comunidad'] ?? respuestas['comunidad'] ?? 'Sin comunidad')
            .toString();
    final apellido = (respuestas['apellido_familia'] ?? '').toString().trim();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.45,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 30),
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F4E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'COMPLETADA · $tipo',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF087C28),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              apellido.isEmpty
                  ? 'Familia sin apellido registrado'
                  : 'Familia $apellido',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$sede · $comunidad (ID: $docId)',
              style: const TextStyle(fontSize: 12, color: Color(0xFF807671)),
            ),
            const Divider(height: 26),
            ...respuestas.entries.map((entry) {
              final val = entry.value is Iterable
                  ? List<String>.from(entry.value).join(', ')
                  : '${entry.value ?? ''}';
              if (val.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF807671),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        val,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar vista de lectura'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminarBorrador(
    BuildContext context,
    FirestoreService service,
    String docId,
    String apellido,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar borrador'),
        content: Text(
          '¿Seguro que deseas eliminar el borrador de la familia "${apellido.isEmpty ? 'Sin apellido' : apellido}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await service.eliminarEncuesta(docId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Borrador eliminado correctamente')),
      );
    }
  }

  bool _perteneceAUsuarioActual(Map<String, dynamic> data) {
    // El administrador puede supervisar todas, pero un encuestador solo ve las suyas
    if (rol == 'admin') return true;

    final encuestadorIdDoc = (data['encuestador_id'] ?? '').toString();
    final respuestas =
        Map<String, dynamic>.from(data['respuestas'] as Map? ?? {});
    final misioneroEmailDoc =
        (respuestas['misionero_aplica'] ?? '').toString().trim().toLowerCase();

    if (encuestadorIdDoc.isNotEmpty && encuestadorIdDoc == _uidActivo) {
      return true;
    }
    if (misioneroEmailDoc.isNotEmpty &&
        misioneroEmailDoc == _emailActivo.trim().toLowerCase()) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final esAdmin = rol == 'admin';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER DE USUARIO Y ROL
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: esAdmin ? const Color(0xFFFF5900) : red,
                    child: Text(
                      esAdmin ? 'AD' : 'EN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          esAdmin ? 'Administrador JFM' : 'Encuestador Activo',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _emailActivo,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
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
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    icon: const Icon(Icons.logout, size: 20),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // PESTAÑA / ACCESO EXCLUSIVO PARA ADMINISTRADOR
            if (esAdmin)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 4),
                child: Material(
                  color: const Color(0xFFFF5900),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminJfmScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(Icons.bar_chart_rounded,
                              color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Panel Administrador (Reportes)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'KPIs, sacramentos, problemáticas y seguimiento JFM / CONEVAL',
                                  style: TextStyle(
                                    color: Color(0xFFFFE3D3),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.white, size: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // CONTENIDO CON STREAMBUILDER EN TIEMPO REAL
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.obtenerEncuestas(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final borradores = <QueryDocumentSnapshot>[];
                  final completadas = <QueryDocumentSnapshot>[];

                  for (final doc in docs) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    // Filtrar para que cada encuestador vea sus propias encuestas
                    if (!_perteneceAUsuarioActual(data)) continue;

                    if (data['estado'] == 'completado') {
                      completadas.add(doc);
                    } else {
                      borradores.add(doc);
                    }
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BANNER DE SINCRONIZACIÓN Y BORRADORES
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5E3),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFF7900)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.sync,
                                color: Color(0xFFFF7100),
                                size: 26,
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${borradores.length} borradores pendientes · ${completadas.length} completadas',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFED6B00),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      esAdmin
                                          ? 'Vista global de encuestas sincronizadas.'
                                          : 'Mostrando únicamente las encuestas de tu cuenta.',
                                      style: const TextStyle(
                                          fontSize: 11, height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // BOTÓN PRINCIPAL: NUEVA ENCUESTA
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
                              onTap: () =>
                                  _mostrarSelectorCuestionario(context),
                              child: const Padding(
                                padding: EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.add,
                                            color: red,
                                            size: 26,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFFFF9C9F),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Nueva Encuesta',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Elegir entre Censo Familia Misionera o Diagnóstico CONEVAL.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFFE3E3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // SECCIÓN 1: BORRADORES PENDIENTES
                        Text(
                          'MIS BORRADORES PENDIENTES (${borradores.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF625B56),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (borradores.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFECE1DA)),
                            ),
                            child: const Text(
                              'No tienes borradores pendientes en este momento.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF807671),
                              ),
                            ),
                          )
                        else
                          ...borradores.map((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>? ?? {};
                            final r = Map<String, dynamic>.from(
                                data['respuestas'] as Map? ?? {});
                            final apellido = (r['apellido_familia'] ?? '')
                                .toString()
                                .trim();
                            final com = (data['comunidad'] ??
                                    r['comunidad'] ??
                                    'Sin comunidad')
                                .toString();
                            final tipo = (data['tipo_cuestionario'] ??
                                    'FAMILIA_MISIONERA')
                                .toString();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                      color: Color(0xFFFFD8B8)),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    if (tipo == 'CONEVAL') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ConevalScreen(
                                            surveyIdExistente: doc.id,
                                            respuestasExistentes: r,
                                            usuarioEmail: _emailActivo,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              FamiliaMisioneraScreen(
                                            surveyIdExistente: doc.id,
                                            respuestasExistentes: r,
                                            usuarioEmail: _emailActivo,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF5E3),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.edit_note,
                                            color: Color(0xFFFF5900),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 7,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: tipo == 'CONEVAL'
                                                      ? const Color(0xFFFDF0F1)
                                                      : const Color(0xFFFFF5E3),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  tipo,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    color: tipo == 'CONEVAL'
                                                        ? red
                                                        : const Color(
                                                            0xFFFF5900),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                apellido.isEmpty
                                                    ? 'Familia (sin apellido aún)'
                                                    : 'Familia $apellido',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Comunidad: $com · Toca para continuar',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF807671),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Eliminar borrador',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: red,
                                          ),
                                          onPressed: () =>
                                              _confirmarEliminarBorrador(
                                            context,
                                            firestoreService,
                                            doc.id,
                                            apellido,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                        const SizedBox(height: 18),

                        // SECCIÓN 2: ENCUESTAS COMPLETADAS
                        Text(
                          'MIS ENCUESTAS COMPLETADAS (${completadas.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF625B56),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (completadas.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFECE1DA)),
                            ),
                            child: const Text(
                              'Aún no tienes encuestas finalizadas.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF807671),
                              ),
                            ),
                          )
                        else
                          ...completadas.map((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>? ?? {};
                            final r = Map<String, dynamic>.from(
                                data['respuestas'] as Map? ?? {});
                            final apellido = (r['apellido_familia'] ?? '')
                                .toString()
                                .trim();
                            final com = (data['comunidad'] ??
                                    r['comunidad'] ??
                                    'Sin comunidad')
                                .toString();
                            final tipo = (data['tipo_cuestionario'] ??
                                    'FAMILIA_MISIONERA')
                                .toString();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                      color: Color(0xFFECE1DA)),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _mostrarDetalleSoloLectura(
                                      context, doc.id, data),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE7F4E8),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Color(0xFF087C28),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                apellido.isEmpty
                                                    ? 'Familia registrada'
                                                    : 'Familia $apellido',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$com · $tipo',
                                                style: const TextStyle(
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
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE7F4E8),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Ver ficha',
                                            style: TextStyle(
                                              color: Color(0xFF006E18),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
