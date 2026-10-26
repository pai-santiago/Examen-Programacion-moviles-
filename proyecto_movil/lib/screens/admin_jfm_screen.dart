import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../forms/jfm_questions.dart';
import '../main.dart';
import '../services/firestore_service.dart';

class AdminJfmScreen extends StatefulWidget {
  const AdminJfmScreen({super.key});

  @override
  State<AdminJfmScreen> createState() => _AdminJfmScreenState();
}

class _AdminJfmScreenState extends State<AdminJfmScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _sedeFiltro = 'Todas';
  String _comunidadFiltro = 'Todas';

  static const InputDecoration _decoracionCampo = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  static const List<String> _sacramentosCat = [
    'Bautizo',
    'Confirmación',
    'Primera comunión',
    'Unción de los enfermos',
    'Confesión',
    'Matrimonio',
  ];

  static const List<String> _problematicasCat = [
    'Discapacidad',
    'Enfermedad crónica',
    'Alcoholismo',
    'Drogadicción',
    'Diabetes',
    'Abuso sexual',
    'Abuso sexual infantil',
    'Migración',
    'Crimen organizado',
    'Salud mental',
    'Otro',
  ];

  static const List<String> _visitasCat = [
    'Visita sacerdotal',
    'Visita médica',
    'Visita misioneros',
    'Seguimiento sacramento',
    'Seguimiento vida parroquial',
    'Otro',
  ];

  Widget _etiquetaCampo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        texto,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  List<String> _obtenerOpcionesComunidad(List<Map<String, dynamic>> encuestas) {
    final Set<String> opciones = {'Todas'};
    if (_sedeFiltro != 'Todas') {
      final predefinidas = sedesComunidadesJfm[_sedeFiltro] ?? const [];
      for (final c in predefinidas) {
        if (c != 'Otra') opciones.add(c);
      }
    } else {
      for (final lista in sedesComunidadesJfm.values) {
        for (final c in lista) {
          if (c != 'Otra') opciones.add(c);
        }
      }
    }
    for (final doc in encuestas) {
      if (_sedeFiltro == 'Todas' || doc['sede'] == _sedeFiltro) {
        final com = (doc['comunidad'] ?? '').toString().trim();
        if (com.isNotEmpty && com != 'Otra') opciones.add(com);
      }
    }
    return opciones.toList();
  }

  Widget _panelFiltrosSuperiores({
    required List<String> sedesOpciones,
    required List<String> comunidadesOpciones,
    required String valorComunidadActual,
    required Color colorTema,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.filter_list, size: 18, color: colorTema),
              const SizedBox(width: 6),
              const Text(
                'FILTROS DE REPORTE COMUNITARIO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF625B56),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _etiquetaCampo('Sede'),
          DropdownButtonFormField<String>(
            key: ValueKey('admin_sede_$_sedeFiltro'),
            initialValue: _sedeFiltro,
            isExpanded: true,
            decoration: _decoracionCampo,
            items: sedesOpciones
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _sedeFiltro = v;
                _comunidadFiltro = 'Todas';
              });
            },
          ),
          const SizedBox(height: 12),
          _etiquetaCampo('Comunidad'),
          DropdownButtonFormField<String>(
            key: ValueKey('admin_com_${_sedeFiltro}_$valorComunidadActual'),
            initialValue: valorComunidadActual,
            isExpanded: true,
            decoration: _decoracionCampo,
            items: comunidadesOpciones
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _comunidadFiltro = v);
              }
            },
          ),
        ],
      ),
    );
  }

  void _mostrarFichaFamiliarJfm(
      BuildContext context, Map<String, dynamic> docData) {
    final respuestas =
        Map<String, dynamic>.from(docData['respuestas'] as Map? ?? {});
    final apellido = (respuestas['apellido_familia'] ?? '').toString().trim();
    final sede =
        (docData['sede'] ?? respuestas['sede'] ?? 'Sin sede').toString();
    final comunidad =
        (docData['comunidad'] ?? respuestas['comunidad'] ?? 'Sin comunidad')
            .toString();
    final estado = (docData['estado'] ?? 'borrador').toString();
    final referencias = respuestas['referencias_casa'] is Iterable
        ? List<String>.from(respuestas['referencias_casa']).join(', ')
        : '';
    final direccion = (respuestas['direccion_casa'] ?? '').toString().trim();
    final sacramentos = respuestas['lista_sacramentos'] is Iterable
        ? List<String>.from(respuestas['lista_sacramentos']).join(', ')
        : 'Ninguno';
    final actividades = respuestas['lista_actividades_parroquia'] is Iterable
        ? List<String>.from(respuestas['lista_actividades_parroquia']).join(', ')
        : 'Ninguna';
    final problematicas = respuestas['lista_problematicas'] is Iterable
        ? List<String>.from(respuestas['lista_problematicas']).join(', ')
        : 'Ninguna';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        maxChildSize: 0.94,
        minChildSize: 0.5,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFFF5900),
                  child: Icon(Icons.family_restroom, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apellido.isEmpty
                            ? 'Familia sin apellido registrado'
                            : 'Familia $apellido',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$sede · $comunidad',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF807671),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: estado == 'completado'
                        ? const Color(0xFFE7F4E8)
                        : const Color(0xFFFFF5E3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: estado == 'completado'
                          ? const Color(0xFF087C28)
                          : const Color(0xFFED6B00),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _seccionFicha('1. Ubicación y Misionero', [
              _filaFicha('Rama', '${respuestas['rama'] ?? '-'}'),
              _filaFicha(
                  'Misionero', '${respuestas['misionero_aplica'] ?? '-'}'),
              _filaFicha('Sede', sede),
              _filaFicha('Comunidad', comunidad),
              _filaFicha(
                'Fachada / Referencias',
                referencias.isEmpty ? 'Sin chips seleccionados' : referencias,
              ),
              _filaFicha(
                'Dirección adicional',
                direccion.isEmpty ? 'No especificada' : direccion,
              ),
            ]),
            _seccionFicha('2. Datos Demográficos', [
              _filaFicha('Apellido familia', apellido.isEmpty ? '-' : apellido),
              _filaFicha(
                  'Habitantes en casa', '${respuestas['num_habitantes'] ?? 1}'),
              _filaFicha('Oficio encargado',
                  '${respuestas['oficio_encargado'] ?? '-'}'),
              _filaFicha(
                  'Estado civil', '${respuestas['estado_civil'] ?? '-'}'),
            ]),
            _seccionFicha('3. Vida Espiritual y Parroquial', [
              _filaFicha(
                  '¿Hogar católico?', '${respuestas['hogar_catolico'] ?? '-'}'),
              _filaFicha('¿Sacramentos faltantes?',
                  '${respuestas['sacramentos_faltantes'] ?? 'No'}'),
              if (respuestas['sacramentos_faltantes'] == 'Si') ...[
                _filaFicha('Sacramentos', sacramentos),
                _filaFicha('Persona(s) que requiere(n)',
                    '${respuestas['persona_requiere_sacramento'] ?? '-'}'),
              ],
              _filaFicha('¿Interés parroquial?',
                  '${respuestas['interes_parroquia'] ?? 'No'}'),
              if (respuestas['interes_parroquia'] == 'Si') ...[
                _filaFicha('Actividades', actividades),
                _filaFicha('Interesado(a)',
                    '${respuestas['nombre_interesado'] ?? '-'}'),
                _filaFicha(
                    'Teléfono', '${respuestas['telefono_interesado'] ?? '-'}'),
              ],
            ]),
            _seccionFicha('4. Problemáticas Sociales', [
              _filaFicha('¿Existe problemática?',
                  '${respuestas['existe_problematica'] ?? 'No'}'),
              if (respuestas['existe_problematica'] == 'Si')
                _filaFicha('Problemáticas detectadas', problematicas),
            ]),
            _seccionFicha('5. Seguimiento y Observaciones', [
              _filaFicha('¿Requiere seguimiento?',
                  '${respuestas['existe_seguimiento'] ?? 'No'}'),
              if (respuestas['existe_seguimiento'] == 'Si')
                _filaFicha('Acción requerida',
                    '${respuestas['tipo_seguimiento'] ?? '-'}'),
              _filaFicha(
                'Comentarios del misionero',
                (respuestas['comentarios'] ?? '').toString().trim().isEmpty
                    ? 'Sin comentarios adicionales'
                    : '${respuestas['comentarios']}',
              ),
            ]),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar Ficha Familiar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFichaConeval(
      BuildContext context, Map<String, dynamic> docData) {
    final r = Map<String, dynamic>.from(docData['respuestas'] as Map? ?? {});
    final apellido = (r['apellido_familia'] ?? '').toString().trim();
    final sede = (docData['sede'] ?? r['sede'] ?? 'Sin sede').toString();
    final comunidad =
        (docData['comunidad'] ?? r['comunidad'] ?? 'Sin comunidad').toString();
    final estado = (docData['estado'] ?? 'borrador').toString();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.45,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: red,
                  child: Icon(Icons.analytics_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apellido.isEmpty
                            ? 'Hogar sin apellido registrado'
                            : 'Hogar $apellido',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'CONEVAL · $sede ($comunidad)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF807671),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: estado == 'completado'
                        ? const Color(0xFFE7F4E8)
                        : const Color(0xFFFFF5E3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: estado == 'completado'
                          ? const Color(0xFF087C28)
                          : const Color(0xFFED6B00),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _seccionFicha('Diagnóstico Socioeconómico CONEVAL', [
              _filaFicha('Encuestador', '${r['misionero_aplica'] ?? '-'}'),
              _filaFicha('Sede', sede),
              _filaFicha('Comunidad', comunidad),
              _filaFicha('Integrantes del hogar', '${r['num_habitantes'] ?? 1}'),
              _filaFicha(
                'Ingreso mensual estimado',
                (r['ingreso_mensual'] ?? '').toString().trim().isEmpty
                    ? 'No reportado'
                    : '\$${r['ingreso_mensual']} MXN',
              ),
              _filaFicha('Carencia alimentaria',
                  '${r['carencia_alimentaria'] ?? 'No'}'),
              _filaFicha(
                  'Servicios básicos', '${r['servicios_basicos'] ?? '-'}'),
              _filaFicha(
                'Observaciones',
                (r['comentarios'] ?? '').toString().trim().isEmpty
                    ? 'Sin observaciones'
                    : '${r['comentarios']}',
              ),
            ]),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar Ficha CONEVAL'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionFicha(String titulo, List<Widget> hijos) {
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

  Widget _filaFicha(String etiqueta, String valor) {
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required String titulo,
    required String valorPrincipal,
    required String subtitulo,
    required IconData icono,
    required Color color,
  }) {
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

  Widget _barraConteo({
    required String etiqueta,
    required int conteo,
    required int totalFamilias,
    required Color color,
  }) {
    final double proporcion =
        totalFamilias > 0 ? (conteo / totalFamilias).clamp(0.0, 1.0) : 0.0;
    final int porcentaje = (proporcion * 100).round();

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

  // PESTAÑA 1: FAMILIA MISIONERA
  Widget _construirTabJfm({
    required List<Map<String, dynamic>> todasJfm,
    required List<String> sedesFiltroOpciones,
  }) {
    final comunidadesOpciones = _obtenerOpcionesComunidad(todasJfm);
    final valorComunidadActual = comunidadesOpciones.contains(_comunidadFiltro)
        ? _comunidadFiltro
        : 'Todas';

    final filtradas = todasJfm.where((doc) {
      final respuestas =
          Map<String, dynamic>.from(doc['respuestas'] as Map? ?? {});
      final sedeDoc = (doc['sede'] ?? respuestas['sede'] ?? '').toString();
      final comDoc =
          (doc['comunidad'] ?? respuestas['comunidad'] ?? '').toString();

      final pasaSede = _sedeFiltro == 'Todas' || sedeDoc == _sedeFiltro;
      final pasaComunidad =
          valorComunidadActual == 'Todas' || comDoc == valorComunidadActual;
      return pasaSede && pasaComunidad;
    }).toList();

    final int totalFamilias = filtradas.length;
    int totalHabitantes = 0;
    int hogaresCatolicos = 0;
    int seguimientoUrgente = 0;

    final Map<String, int> conteoSacramentos = {
      for (final s in _sacramentosCat) s: 0,
    };
    final Map<String, int> conteoProblematicas = {
      for (final p in _problematicasCat) p: 0,
    };
    final Map<String, int> conteoVisitas = {
      for (final v in _visitasCat) v: 0,
    };
    final List<Map<String, String>> familiasConSeguimiento = [];

    for (final doc in filtradas) {
      final r = Map<String, dynamic>.from(doc['respuestas'] as Map? ?? {});
      final habRaw = r['num_habitantes'];
      final int hab =
          habRaw is int ? habRaw : (int.tryParse('$habRaw') ?? 1);
      totalHabitantes += hab;

      if (r['hogar_catolico'] == 'Si') {
        hogaresCatolicos++;
      }

      if (r['sacramentos_faltantes'] == 'Si' &&
          r['lista_sacramentos'] is Iterable) {
        for (final s in List<String>.from(r['lista_sacramentos'])) {
          conteoSacramentos[s] = (conteoSacramentos[s] ?? 0) + 1;
        }
      }

      if (r['existe_problematica'] == 'Si' &&
          r['lista_problematicas'] is Iterable) {
        for (final p in List<String>.from(r['lista_problematicas'])) {
          conteoProblematicas[p] = (conteoProblematicas[p] ?? 0) + 1;
        }
      }

      if (r['existe_seguimiento'] == 'Si') {
        seguimientoUrgente++;
        final tipoSeg =
            (r['tipo_seguimiento'] ?? 'Visita misioneros').toString();
        conteoVisitas[tipoSeg] = (conteoVisitas[tipoSeg] ?? 0) + 1;

        final apellido = (r['apellido_familia'] ?? '').toString().trim();
        final refs = r['referencias_casa'] is Iterable
            ? List<String>.from(r['referencias_casa']).join(', ')
            : '';
        final dir = (r['direccion_casa'] ?? '').toString().trim();
        final ubicacion = [
          if (refs.isNotEmpty) refs,
          if (dir.isNotEmpty) dir,
        ].join(' · ');
        final interesado =
            (r['nombre_interesado'] ?? r['persona_requiere_sacramento'] ?? '')
                .toString()
                .trim();
        final telefono = (r['telefono_interesado'] ?? '').toString().trim();

        familiasConSeguimiento.add({
          'apellido': apellido.isEmpty ? 'Sin apellido' : apellido,
          'accion': tipoSeg,
          'comunidad': (doc['comunidad'] ?? r['comunidad'] ?? '').toString(),
          'ubicacion':
              ubicacion.isEmpty ? 'Sin referencia registrada' : ubicacion,
          'contacto': [
            if (interesado.isNotEmpty) interesado,
            if (telefono.isNotEmpty) 'Tel: $telefono',
          ].join(' · '),
        });
      }
    }

    final int porcentajeCatolicos = totalFamilias > 0
        ? ((hogaresCatolicos / totalFamilias) * 100).round()
        : 0;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _panelFiltrosSuperiores(
          sedesOpciones: sedesFiltroOpciones,
          comunidadesOpciones: comunidadesOpciones,
          valorComunidadActual: valorComunidadActual,
          colorTema: const Color(0xFFFF5900),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                titulo: 'Familias Censadas',
                valorPrincipal: '$totalFamilias',
                subtitulo: '$totalHabitantes habitantes totales',
                icono: Icons.home_work_outlined,
                color: const Color(0xFFFF5900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _kpiCard(
                titulo: 'Hogares Católicos',
                valorPrincipal: '$porcentajeCatolicos%',
                subtitulo: '$hogaresCatolicos de $totalFamilias hogares',
                icono: Icons.church_outlined,
                color: const Color(0xFF087C28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _kpiCard(
          titulo: 'Acciones de Seguimiento Urgente',
          valorPrincipal: '$seguimientoUrgente familias',
          subtitulo:
              'Solicitan visita sacerdotal, médica, misionera o sacramental',
          icono: Icons.notification_important_outlined,
          color: red,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECE1DA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SACRAMENTOS FALTANTES EN LA COMUNIDAD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF625B56),
                ),
              ),
              const SizedBox(height: 8),
              ..._sacramentosCat.map(
                (s) => _barraConteo(
                  etiqueta: s,
                  conteo: conteoSacramentos[s] ?? 0,
                  totalFamilias: totalFamilias,
                  color: const Color(0xFFFF5900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECE1DA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROBLEMÁTICAS SOCIALES DETECTADAS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF625B56),
                ),
              ),
              const SizedBox(height: 8),
              ..._problematicasCat.map(
                (p) => _barraConteo(
                  etiqueta: p,
                  conteo: conteoProblematicas[p] ?? 0,
                  totalFamilias: totalFamilias,
                  color: red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECE1DA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VISITAS Y SEGUIMIENTO REQUERIDO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF625B56),
                ),
              ),
              const SizedBox(height: 8),
              ..._visitasCat.map(
                (v) => _barraConteo(
                  etiqueta: v,
                  conteo: conteoVisitas[v] ?? 0,
                  totalFamilias: totalFamilias,
                  color: const Color(0xFF087C28),
                ),
              ),
              if (familiasConSeguimiento.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Familias que solicitaron seguimiento:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ...familiasConSeguimiento.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFD8B8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Familia ${item['apellido']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5900),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['accion'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ubicación: ${item['ubicacion']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF625B56),
                          ),
                        ),
                        if ((item['contacto'] ?? '').isNotEmpty)
                          Text(
                            'Contacto: ${item['contacto']}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF087C28),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'LISTADO DE FAMILIAS FILTRADAS ($totalFamilias)',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF625B56),
          ),
        ),
        const SizedBox(height: 10),
        if (filtradas.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFECE1DA)),
            ),
            child: const Center(
              child: Text(
                'No hay encuestas JFM para los filtros seleccionados.',
                style: TextStyle(color: Color(0xFF807671), fontSize: 13),
              ),
            ),
          )
        else
          ...filtradas.map((doc) {
            final r =
                Map<String, dynamic>.from(doc['respuestas'] as Map? ?? {});
            final apellido = (r['apellido_familia'] ?? '').toString().trim();
            final com =
                (doc['comunidad'] ?? r['comunidad'] ?? 'Sin comunidad')
                    .toString();
            final sede = (doc['sede'] ?? r['sede'] ?? 'Sin sede').toString();
            final estado = (doc['estado'] ?? 'borrador').toString();
            final hab = r['num_habitantes'] ?? 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFECE1DA)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _mostrarFichaFamiliarJfm(context, doc),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFF5E3),
                          child: Icon(
                            Icons.people_alt_outlined,
                            color: Color(0xFFFF5900),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apellido.isEmpty
                                    ? 'Familia sin apellido'
                                    : 'Familia $apellido',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$com ($sede) · $hab hab.',
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
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: estado == 'completado'
                                ? const Color(0xFFE7F4E8)
                                : const Color(0xFFFFF5E3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            estado,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: estado == 'completado'
                                  ? const Color(0xFF087C28)
                                  : const Color(0xFFED6B00),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF807671)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  // PESTAÑA 2: DIAGNÓSTICO CONEVAL (Lista y preparada para gráficas de carencias/pobreza)
  Widget _construirTabConeval({
    required List<Map<String, dynamic>> todasConeval,
    required List<String> sedesFiltroOpciones,
  }) {
    final comunidadesOpciones = _obtenerOpcionesComunidad(todasConeval);
    final valorComunidadActual = comunidadesOpciones.contains(_comunidadFiltro)
        ? _comunidadFiltro
        : 'Todas';

    final filtradas = todasConeval.where((doc) {
      final r = Map<String, dynamic>.from(doc['respuestas'] as Map? ?? {});
      final sedeDoc = (doc['sede'] ?? r['sede'] ?? '').toString();
      final comDoc = (doc['comunidad'] ?? r['comunidad'] ?? '').toString();

      final pasaSede = _sedeFiltro == 'Todas' || sedeDoc == _sedeFiltro;
      final pasaComunidad =
          valorComunidadActual == 'Todas' || comDoc == valorComunidadActual;
      return pasaSede && pasaComunidad;
    }).toList();

    final int totalHogares = filtradas.length;
    int totalIntegrantes = 0;
    int conCarenciaAlimentaria = 0;
    int conServiciosIncompletos = 0;

    for (final doc in filtradas) {
      final r = Map<String, dynamic>.from(doc['respuestas'] as Map? ?? {});
      final habRaw = r['num_habitantes'];
      final int hab =
          habRaw is int ? habRaw : (int.tryParse('$habRaw') ?? 1);
      totalIntegrantes += hab;

      if (r['carencia_alimentaria'] == 'Si') {
        conCarenciaAlimentaria++;
      }
      if (r['servicios_basicos'] == 'Incompletos') {
        conServiciosIncompletos++;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _panelFiltrosSuperiores(
          sedesOpciones: sedesFiltroOpciones,
          comunidadesOpciones: comunidadesOpciones,
          valorComunidadActual: valorComunidadActual,
          colorTema: red,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                titulo: 'Hogares CONEVAL',
                valorPrincipal: '$totalHogares',
                subtitulo: '$totalIntegrantes integrantes evaluados',
                icono: Icons.analytics_outlined,
                color: red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _kpiCard(
                titulo: 'Carencia Alimentaria',
                valorPrincipal: '$conCarenciaAlimentaria',
                subtitulo: 'de $totalHogares hogares diagnosticados',
                icono: Icons.restaurant_outlined,
                color: const Color(0xFFFF5900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECE1DA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INDICADORES PRELIMINARES DE CARENCIAS (CONEVAL)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF625B56),
                ),
              ),
              const SizedBox(height: 10),
              _barraConteo(
                etiqueta: 'Carencia por acceso a la alimentación',
                conteo: conCarenciaAlimentaria,
                totalFamilias: totalHogares,
                color: red,
              ),
              _barraConteo(
                etiqueta: 'Vivienda con servicios básicos incompletos',
                conteo: conServiciosIncompletos,
                totalFamilias: totalHogares,
                color: const Color(0xFFFF5900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'HOGARES DIAGNOSTICADOS CONEVAL ($totalHogares)',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF625B56),
          ),
        ),
        const SizedBox(height: 10),
        if (filtradas.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFECE1DA)),
            ),
            child: const Center(
              child: Text(
                'Aún no hay diagnósticos CONEVAL para estos filtros.',
                style: TextStyle(color: Color(0xFF807671), fontSize: 13),
              ),
            ),
          )
        else
          ...filtradas.map((doc) {
            final r =
                Map<String, dynamic>.from(doc['respuestas'] as Map? ?? {});
            final apellido = (r['apellido_familia'] ?? '').toString().trim();
            final com =
                (doc['comunidad'] ?? r['comunidad'] ?? 'Sin comunidad')
                    .toString();
            final sede = (doc['sede'] ?? r['sede'] ?? 'Sin sede').toString();
            final estado = (doc['estado'] ?? 'borrador').toString();
            final hab = r['num_habitantes'] ?? 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFECE1DA)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _mostrarFichaConeval(context, doc),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFDF0F1),
                          child: Icon(
                            Icons.analytics_outlined,
                            color: red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apellido.isEmpty
                                    ? 'Hogar sin apellido'
                                    : 'Hogar $apellido',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$com ($sede) · $hab int.',
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
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: estado == 'completado'
                                ? const Color(0xFFE7F4E8)
                                : const Color(0xFFFFF5E3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            estado,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: estado == 'completado'
                                  ? const Color(0xFF087C28)
                                  : const Color(0xFFED6B00),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF807671)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sedesFiltroOpciones = ['Todas', ...sedesComunidadesJfm.keys];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel Administrador · Reportes'),
          backgroundColor: const Color(0xFFFF5900),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFFFD8B8),
            labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            tabs: [
              Tab(
                icon: Icon(Icons.family_restroom, size: 20),
                text: 'Familia Misionera',
              ),
              Tab(
                icon: Icon(Icons.analytics_outlined, size: 20),
                text: 'Diagnóstico CONEVAL',
              ),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.obtenerEncuestas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final rawDocs = snapshot.data?.docs ?? [];
            final List<Map<String, dynamic>> todasJfm = [];
            final List<Map<String, dynamic>> todasConeval = [];

            for (final doc in rawDocs) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final tipo =
                  (data['tipo_cuestionario'] ?? 'FAMILIA_MISIONERA').toString();
              if (tipo == 'CONEVAL') {
                todasConeval.add({...data, 'doc_id': doc.id});
              } else {
                todasJfm.add({...data, 'doc_id': doc.id});
              }
            }

            return TabBarView(
              children: [
                _construirTabJfm(
                  todasJfm: todasJfm,
                  sedesFiltroOpciones: sedesFiltroOpciones,
                ),
                _construirTabConeval(
                  todasConeval: todasConeval,
                  sedesFiltroOpciones: sedesFiltroOpciones,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
