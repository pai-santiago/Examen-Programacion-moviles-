import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/jfm_form_data.dart';
import '../models/coneval_form_data.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../widgets/admin_dashboard_widgets.dart';
import '../widgets/form_question_widgets.dart';

class AdminJfmScreen extends StatefulWidget {
  const AdminJfmScreen({super.key});

  @override
  State<AdminJfmScreen> createState() => _AdminJfmScreenState();
}

class _AdminJfmScreenState extends State<AdminJfmScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _sedeFiltro = 'Todas';
  String _comunidadFiltro = 'Todas';
  String _busquedaFiltro = '';
  final TextEditingController _busquedaCtrl = TextEditingController();

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

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
    final filtrosActivos = _sedeFiltro != 'Todas' ||
        _comunidadFiltro != 'Todas' ||
        _busquedaFiltro.isNotEmpty;
    final campoSedeYComunidad = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiquetaCampo('Sede'),
        DropdownButtonFormField<String>(
          key: ValueKey('admin_sede_$_sedeFiltro'),
          initialValue: _sedeFiltro,
          isExpanded: true,
          decoration: _decoracionCampo,
          items: sedesOpciones
              .map(
                (sede) => DropdownMenuItem(
                  value: sede,
                  child: Text(sede, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _sedeFiltro = value;
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
                (comunidad) => DropdownMenuItem(
                  value: comunidad,
                  child: Text(comunidad, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _comunidadFiltro = value);
          },
        ),
      ],
    );
    final campoBusqueda = TextField(
      controller: _busquedaCtrl,
      decoration: _decoracionCampo.copyWith(
        labelText: 'Buscar hogar, persona o localidad',
        prefixIcon: const Icon(Icons.search, size: 19),
        suffixIcon: _busquedaFiltro.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar búsqueda',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _busquedaCtrl.clear();
                  setState(() => _busquedaFiltro = '');
                },
              ),
      ),
      onChanged: (value) => setState(() => _busquedaFiltro = value),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final esAmplio = constraints.maxWidth >= 840;
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
              if (esAmplio)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: campoSedeYComunidad),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 26),
                        child: campoBusqueda,
                      ),
                    ),
                  ],
                )
              else ...[
                campoSedeYComunidad,
                const SizedBox(height: 12),
                campoBusqueda,
              ],
              if (filtrosActivos)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      _busquedaCtrl.clear();
                      setState(() {
                        _sedeFiltro = 'Todas';
                        _comunidadFiltro = 'Todas';
                        _busquedaFiltro = '';
                      });
                    },
                    icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                    label: const Text('Limpiar filtros'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarFichaFamiliarJfm(
    BuildContext context,
    Map<String, dynamic> docData,
  ) {
    final respuestas = Map<String, dynamic>.from(
      docData['respuestas'] as Map? ?? {},
    );
    final apellido = (respuestas['apellido_familia'] ?? '').toString().trim();
    final sede = (docData['sede'] ?? respuestas['sede'] ?? 'Sin sede')
        .toString();
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
        ? List<String>.from(respuestas['lista_actividades_parroquia'])
              .join(', ')
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
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
            AdminInfoSection('1. Ubicación y Misionero', [
              AdminInfoRow('Rama', '${respuestas['rama'] ?? '-'}'),
              AdminInfoRow(
                'Misionero',
                '${respuestas['misionero_aplica'] ?? '-'}',
              ),
              AdminInfoRow('Sede', sede),
              AdminInfoRow('Comunidad', comunidad),
              AdminInfoRow(
                'Fecha del censo',
                '${respuestas['fecha_censo'] ?? 'No registrada'}',
              ),
              AdminInfoRow(
                'Fachada / Referencias',
                referencias.isEmpty ? 'Sin chips seleccionados' : referencias,
              ),
              AdminInfoRow(
                'Dirección adicional',
                direccion.isEmpty ? 'No especificada' : direccion,
              ),
            ]),
            AdminInfoSection('2. Datos Demográficos', [
              AdminInfoRow(
                'Apellido familia',
                apellido.isEmpty ? '-' : apellido,
              ),
              AdminInfoRow(
                'Habitantes en casa',
                '${respuestas['num_habitantes'] ?? 1}',
              ),
              AdminInfoRow(
                'Oficio encargado',
                '${respuestas['oficio_encargado'] ?? '-'}',
              ),
              AdminInfoRow(
                'Estado civil',
                '${respuestas['estado_civil'] ?? '-'}',
              ),
            ]),
            AdminInfoSection('3. Vida Espiritual y Parroquial', [
              AdminInfoRow(
                '¿Hogar católico?',
                '${respuestas['hogar_catolico'] ?? '-'}',
              ),
              AdminInfoRow(
                '¿Sacramentos faltantes?',
                '${respuestas['sacramentos_faltantes'] ?? 'No'}',
              ),
              if (respuestas['sacramentos_faltantes'] == 'Si') ...[
                AdminInfoRow('Sacramentos', sacramentos),
                AdminInfoRow(
                  'Persona(s) que requiere(n)',
                  '${respuestas['persona_requiere_sacramento'] ?? '-'}',
                ),
              ],
              AdminInfoRow(
                '¿Interés parroquial?',
                '${respuestas['interes_parroquia'] ?? 'No'}',
              ),
              if (respuestas['interes_parroquia'] == 'Si') ...[
                AdminInfoRow('Actividades', actividades),
                AdminInfoRow(
                  'Interesado(a)',
                  '${respuestas['nombre_interesado'] ?? '-'}',
                ),
                AdminInfoRow(
                  'Teléfono',
                  '${respuestas['telefono_interesado'] ?? '-'}',
                ),
              ],
            ]),
            AdminInfoSection('4. Problemáticas Sociales', [
              AdminInfoRow(
                '¿Existe problemática?',
                '${respuestas['existe_problematica'] ?? 'No'}',
              ),
              if (respuestas['existe_problematica'] == 'Si')
                AdminInfoRow('Problemáticas detectadas', problematicas),
            ]),
            AdminInfoSection('5. Seguimiento y Observaciones', [
              AdminInfoRow(
                '¿Requiere seguimiento?',
                '${respuestas['existe_seguimiento'] ?? 'No'}',
              ),
              if (respuestas['existe_seguimiento'] == 'Si')
                AdminInfoRow(
                  'Acción requerida',
                  '${respuestas['tipo_seguimiento'] ?? '-'}',
                ),
              AdminInfoRow(
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
    BuildContext context,
    Map<String, dynamic> docData,
  ) {
    final r = Map<String, dynamic>.from(docData['respuestas'] as Map? ?? {});
    final apellido = (r['apellido_familia'] ?? '').toString().trim();
    final sede = (docData['sede'] ?? r['sede'] ?? 'Sin sede').toString();
    final comunidad =
        (docData['comunidad'] ?? r['comunidad'] ?? 'Sin comunidad').toString();
    final estado = (docData['estado'] ?? 'borrador').toString();
    final rawIntegrantes = docData['integrantes'] ?? r['integrantes'];
    final integrantes = rawIntegrantes is Iterable
        ? rawIntegrantes
              .whereType<Map>()
              .map((persona) => Map<String, dynamic>.from(persona))
              .toList()
        : <Map<String, dynamic>>[];
    String mostrar(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) {
        return 'No registrado';
      }
      if (value is Iterable) return value.join(', ');
      return value.toString();
    }

    Widget seccion(String title, Map<String, String> fields) {
      final rows = fields.entries
          .where((entry) => r.containsKey(entry.key))
          .map((entry) => AdminInfoRow(entry.value, mostrar(r[entry.key])))
          .toList();
      return rows.isEmpty
          ? const SizedBox.shrink()
          : AdminInfoSection(title, rows);
    }

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
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
            AdminInfoSection('Ubicación y situación del predio', [
              AdminInfoRow('Encuestador', mostrar(r['misionero_aplica'])),
              AdminInfoRow('Sede', sede),
              AdminInfoRow(
                'Estado / municipio',
                '${mostrar(r['estado'] == 'Otro' ? r['estado_otro'] : r['estado'])} / ${mostrar(r['municipio'])}',
              ),
              AdminInfoRow('Comunidad', comunidad),
              AdminInfoRow(
                'AGEB / manzana',
                '${mostrar(r['ageb'])} / ${mostrar(r['manzana'])}',
              ),
              AdminInfoRow('Domicilio', mostrar(r['domicilio'])),
              AdminInfoRow('Religión', mostrar(r['religion_hogar'])),
              AdminInfoRow(
                'Comunidad indígena',
                mostrar(r['comunidad_indigena']),
              ),
              AdminInfoRow('Predio habitado', mostrar(r['predio_habitado'])),
              AdminInfoRow('Uso del predio', mostrar(r['uso_predio_detalle'])),
              AdminInfoRow(
                'Papeles de propiedad',
                mostrar(r['papeles_propiedad']),
              ),
              AdminInfoRow(
                'Situación legal',
                mostrar(r['situacion_legal_inmueble']),
              ),
              AdminInfoRow(
                'Integrantes registrados',
                '${integrantes.isNotEmpty ? integrantes.length : r['num_habitantes'] ?? 0}',
              ),
            ]),
            if (integrantes.isNotEmpty)
              AdminInfoSection('Personas que integran el hogar', [
                for (var i = 0; i < integrantes.length; i++) ...[
                  AdminInfoRow(
                    'Persona ${i + 1}',
                    [
                          integrantes[i]['nombre'],
                          integrantes[i]['apellido_paterno'],
                          integrantes[i]['apellido_materno'],
                        ]
                        .where(
                          (value) =>
                              value != null &&
                              value.toString().trim().isNotEmpty,
                        )
                        .join(' '),
                  ),
                  AdminInfoRow(
                    'Parentesco / CURP',
                    '${mostrar(integrantes[i]['parentesco'])} / ${mostrar(integrantes[i]['curp'])}',
                  ),
                  AdminInfoRow(
                    'Sexo / nacimiento',
                    '${mostrar(integrantes[i]['sexo'])} / ${mostrar(integrantes[i]['fecha_nacimiento'])}',
                  ),
                  AdminInfoRow(
                    'Estado / civil / lengua',
                    '${mostrar(integrantes[i]['estado_nacimiento'] == 'Otro' ? integrantes[i]['estado_nacimiento_otro'] : integrantes[i]['estado_nacimiento'])} / ${mostrar(integrantes[i]['estado_civil'])} / ${mostrar(integrantes[i]['lengua_indigena'] ?? integrantes[i]['habla_lengua_indigena'])}',
                  ),
                  AdminInfoRow(
                    'Escolaridad / escuela',
                    '${mostrar(integrantes[i]['ultimo_grado_estudios'])} / ${mostrar(integrantes[i]['asiste_escuela'])}',
                  ),
                  AdminInfoRow(
                    'Trabajo / actividad',
                    '${mostrar(integrantes[i]['trabaja'])} / ${mostrar(integrantes[i]['actividad_trabajo'] ?? integrantes[i]['motivo_no_trabaja'])}',
                  ),
                  AdminInfoRow(
                    'Posición / salario',
                    '${mostrar(integrantes[i]['posicion_trabajo'])} / ${mostrar(integrantes[i]['salario_mensual'])}',
                  ),
                  AdminInfoRow(
                    'Servicio médico',
                    '${mostrar(integrantes[i]['servicio_medico'])} / ${mostrar(integrantes[i]['tipo_servicio_medico'])} / ${mostrar(integrantes[i]['proveedor_servicio_medico'])}',
                  ),
                  AdminInfoRow(
                    'AFORE / incapacidad',
                    '${mostrar(integrantes[i]['afore'])} / ${mostrar(integrantes[i]['pago_incapacidad'])}',
                  ),
                  AdminInfoRow(
                    'Discapacidad / padecimiento',
                    '${mostrar(integrantes[i]['tipos_discapacidad'])} / ${mostrar(integrantes[i]['tipos_padecimiento'])}',
                  ),
                  AdminInfoRow(
                    'Ingresos adicionales',
                    '${mostrar(integrantes[i]['fuentes_ingreso_adicional'])} / ${mostrar(integrantes[i]['monto_ingresos_adicionales'])}',
                  ),
                  AdminInfoRow(
                    'Programas / monto mensual',
                    '${mostrar(integrantes[i]['programas_sociales'])} / ${mostrar(integrantes[i]['monto_programas_mensual'])}',
                  ),
                ],
              ]),
            seccion('Economía y alimentación', {
              'ingreso_mensual': 'Ingreso mensual estimado (registro previo)',
              'carencia_alimentaria': 'Resumen de alimentación',
              'servicios_basicos': 'Resumen de servicios básicos',
              'comentarios': 'Observaciones (registro previo)',
              'gasto_alimentacion': 'Gasto mensual en alimentación',
              'gasto_luz': 'Gasto mensual en luz',
              'gasto_agua': 'Gasto mensual en agua',
              'gasto_vivienda': 'Gasto mensual en vivienda',
              'gasto_educacion': 'Gasto mensual en educación',
              'gasto_salud': 'Gasto mensual en salud',
              'gasto_otro': 'Otros gastos mensuales',
              'comidas_dia': 'Comidas por día',
              'preocupo_comida_acabara': 'Preocupación por falta de comida',
              ...{
                for (var i = 0; i < preguntasAlimentacion.length; i++)
                  'menores_alimentacion_$i':
                      'Menores · ${preguntasAlimentacion[i]}',
                for (var i = 0; i < preguntasAlimentacion.length; i++)
                  'adultos_alimentacion_$i':
                      'Adultos · ${preguntasAlimentacion[i]}',
              },
            }),
            seccion('Características de la vivienda', {
              'clase_vivienda': 'Tipo de vivienda',
              'clase_vivienda_otra': 'Otro tipo de vivienda',
              'tenencia_vivienda': 'Tenencia',
              'material_paredes': 'Material de las paredes',
              'material_paredes_otro': 'Otro material de paredes',
              'material_techo': 'Material del techo',
              'material_techo_otro': 'Otro material de techo',
              'habitaciones_vivienda': 'Habitaciones',
              'cantidad_banos': 'Baños',
              'cantidad_focos': 'Focos',
              'energia_electrica': 'Energía eléctrica',
              'agua_fuente': 'Fuente de agua',
              'drenaje': 'Drenaje',
              'conexion_drenaje': 'Conexión de drenaje',
              'letrina': 'Letrina',
              'equipamiento': 'Equipamiento',
              'vehiculo': 'Vehículo',
              'cantidad_vehiculos': 'Cantidad de vehículos',
              'combustible_cocina': 'Combustible para cocinar',
              'chimenea': 'Chimenea',
              'huerto_familiar': 'Huerto familiar',
              ...{
                for (var i = 0; i < 6; i++)
                  'facilidad_$i': 'Facilidad · ${necesidadesVivienda[i]}',
              },
            }),
            seccion('Violencia, acceso y cohesión social', {
              'violencia_familiar': 'Violencia en el hogar',
              'personas_afectadas': 'Personas afectadas',
              'persona_afectada_otra': 'Otra persona afectada',
              'tipos_violencia': 'Tipos de violencia',
              'tipo_violencia_otro': 'Otro tipo de violencia',
              'lugares_violencia': 'Lugar del incidente',
              'lugar_violencia_otro': 'Otro lugar del incidente',
              'actores_violencia': 'Presuntas personas responsables',
              'actor_violencia_otro': 'Otro presunto responsable',
              'denuncia_violencia': 'Denuncia',
              'observaciones_entrevistador': 'Observaciones del entrevistador',
              'distancia_centro_salud': 'Distancia al centro de salud',
              'distancia_escuela': 'Distancia a la escuela',
              'niveles_escuela': 'Niveles educativos cercanos',
              'confianza_comunidad': 'Confianza en la comunidad',
              'ayuda_comunidad': 'Apoyo entre vecinos',
              'participacion_comunitaria': 'Participación comunitaria',
              'respeto_comunidad': 'Respeto a las diferencias',
              'unidad_comunidad': 'Trabajo conjunto de la comunidad',
            }),
            seccion('Ficha técnica de entrevista', {
              'fecha_entrevista': 'Fecha',
              'hora_entrevista': 'Hora',
              'numero_visita': 'Número de visita',
              'nombre_entrevistado': 'Entrevistado(a)',
              'nombre_entrevistador': 'Entrevistador(a)',
            }),
            AdminInfoSection('Firmas', [
              AdminInfoRow(
                'Entrevistado(a)',
                r['firma_entrevistado'] is List &&
                        (r['firma_entrevistado'] as List).isNotEmpty
                    ? 'Registrada'
                    : 'No registrada',
              ),
              AdminInfoRow(
                'Entrevistador(a)',
                r['firma_entrevistador'] is List &&
                        (r['firma_entrevistador'] as List).isNotEmpty
                    ? 'Registrada'
                    : 'No registrada',
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
      final respuestas = Map<String, dynamic>.from(
        doc['respuestas'] as Map? ?? {},
      );
      final sedeDoc = (doc['sede'] ?? respuestas['sede'] ?? '').toString();
      final comDoc = (doc['comunidad'] ?? respuestas['comunidad'] ?? '')
          .toString();

      final pasaSede = _sedeFiltro == 'Todas' || sedeDoc == _sedeFiltro;
      final pasaComunidad =
          valorComunidadActual == 'Todas' || comDoc == valorComunidadActual;
      final busqueda = normalizarTextoBusqueda(_busquedaFiltro.trim());
      final texto = normalizarTextoBusqueda([
        respuestas['apellido_familia'],
        respuestas['misionero_aplica'],
        doc['sede'],
        doc['comunidad'],
      ].whereType<Object>().join(' '));
      return pasaSede &&
          pasaComunidad &&
          (busqueda.isEmpty || texto.contains(busqueda));
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
    final Map<String, int> conteoVisitas = {for (final v in _visitasCat) v: 0};
    final List<Map<String, String>> familiasConSeguimiento = [];

    for (final doc in filtradas) {
      final r = Map<String, dynamic>.from(doc['respuestas'] as Map? ?? {});
      final habRaw = r['num_habitantes'];
      final int hab = habRaw is int ? habRaw : (int.tryParse('$habRaw') ?? 1);
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
        final tipoSeg = (r['tipo_seguimiento'] ?? 'Visita misioneros')
            .toString();
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
          'ubicacion': ubicacion.isEmpty
              ? 'Sin referencia registrada'
              : ubicacion,
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
              child: AdminKpiCard(
                titulo: 'Familias Censadas',
                valorPrincipal: '$totalFamilias',
                subtitulo: '$totalHabitantes habitantes totales',
                icono: Icons.home_work_outlined,
                color: const Color(0xFFFF5900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminKpiCard(
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
        AdminKpiCard(
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
                (s) => AdminCountBar(
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
                (p) => AdminCountBar(
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
                (v) => AdminCountBar(
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
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
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
            final r = Map<String, dynamic>.from(
              doc['respuestas'] as Map? ?? {},
            );
            final apellido = (r['apellido_familia'] ?? '').toString().trim();
            final com = (doc['comunidad'] ?? r['comunidad'] ?? 'Sin comunidad')
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
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF807671),
                        ),
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
      final busqueda = normalizarTextoBusqueda(_busquedaFiltro.trim());
      final texto = normalizarTextoBusqueda([
        r['apellido_familia'],
        r['misionero_aplica'],
        r['municipio'],
        r['estado'],
        sedeDoc,
        comDoc,
      ].whereType<Object>().join(' '));
      return pasaSede &&
          pasaComunidad &&
          (busqueda.isEmpty || texto.contains(busqueda));
    }).toList();

    final int totalHogares = filtradas.length;
    int totalIntegrantes = 0;
    int conCarenciaAlimentaria = 0;
    int conServiciosIncompletos = 0;
    int sinElectricidad = 0;
    int sinDrenaje = 0;
    int conPosibleHacinamiento = 0;
    int hogaresConViolenciaReportada = 0;
    int personasConDiscapacidad = 0;

    for (final doc in filtradas) {
      final r = Map<String, dynamic>.from(doc['respuestas'] as Map? ?? {});
      final rawIntegrantes = doc['integrantes'] ?? r['integrantes'];
      final integrantes = rawIntegrantes is Iterable
          ? rawIntegrantes.whereType<Map>().toList()
          : const <Map>[];
      final habRaw = r['num_habitantes'];
      final int hab = integrantes.isNotEmpty
          ? integrantes.length
          : (habRaw is int ? habRaw : (int.tryParse('$habRaw') ?? 0));
      totalIntegrantes += hab;

      if (r['carencia_alimentaria'] == 'Si') {
        conCarenciaAlimentaria++;
      }
      if (r['servicios_basicos'] == 'Incompletos') {
        conServiciosIncompletos++;
      }
      if (r['energia_electrica'] == 'No') sinElectricidad++;
      if (r['drenaje'] == 'No') sinDrenaje++;
      final habitaciones = int.tryParse('${r['habitaciones_vivienda']}') ?? 0;
      if (habitaciones > 0 && hab > habitaciones) conPosibleHacinamiento++;
      if (r['violencia_familiar'] == 'Sí') hogaresConViolenciaReportada++;
      personasConDiscapacidad += integrantes
          .where((persona) => persona['discapacidad'] == 'Sí')
          .length;
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
              child: AdminKpiCard(
                titulo: 'Hogares CONEVAL',
                valorPrincipal: '$totalHogares',
                subtitulo: '$totalIntegrantes integrantes evaluados',
                icono: Icons.analytics_outlined,
                color: red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminKpiCard(
                titulo: 'Alerta de alimentación',
                valorPrincipal: '$conCarenciaAlimentaria',
                subtitulo: 'de $totalHogares hogares diagnosticados',
                icono: Icons.restaurant_outlined,
                color: const Color(0xFFFF5900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AdminKpiCard(
                titulo: 'Personas con discapacidad',
                valorPrincipal: '$personasConDiscapacidad',
                subtitulo: 'registros de integrantes',
                icono: Icons.accessible_outlined,
                color: const Color(0xFF426C8B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminKpiCard(
                titulo: 'Hogares con violencia reportada',
                valorPrincipal: '$hogaresConViolenciaReportada',
                subtitulo: 'de $totalHogares hogares',
                icono: Icons.health_and_safety_outlined,
                color: const Color(0xFF9A3E35),
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
                'RESUMEN DE CONDICIONES REPORTADAS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF625B56),
                ),
              ),
              const SizedBox(height: 10),
              AdminCountBar(
                etiqueta: 'Hogares que reportan dificultades de alimentación',
                conteo: conCarenciaAlimentaria,
                totalFamilias: totalHogares,
                color: red,
              ),
              AdminCountBar(
                etiqueta: 'Vivienda con servicios básicos incompletos',
                conteo: conServiciosIncompletos,
                totalFamilias: totalHogares,
                color: const Color(0xFFFF5900),
              ),
              AdminCountBar(
                etiqueta: 'Hogares sin energía eléctrica',
                conteo: sinElectricidad,
                totalFamilias: totalHogares,
                color: const Color(0xFF426C8B),
              ),
              AdminCountBar(
                etiqueta: 'Hogares sin drenaje',
                conteo: sinDrenaje,
                totalFamilias: totalHogares,
                color: const Color(0xFF8B6E3F),
              ),
              AdminCountBar(
                etiqueta: 'Hogares con posible hacinamiento',
                conteo: conPosibleHacinamiento,
                totalFamilias: totalHogares,
                color: const Color(0xFF8A4D7B),
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
            final r = Map<String, dynamic>.from(
              doc['respuestas'] as Map? ?? {},
            );
            final apellido = (r['apellido_familia'] ?? '').toString().trim();
            final com = (doc['comunidad'] ?? r['comunidad'] ?? 'Sin comunidad')
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
                          child: Icon(Icons.analytics_outlined, color: red),
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
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF807671),
                        ),
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
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.obtenerEncuestas(),
              builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Cargando reportes…'),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 42,
                        color: Color(0xFF9A3E35),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No se pudieron cargar los reportes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Verifica tu conexión y que tu cuenta tenga permisos de administración.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF625B56),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const AdminJfmScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Volver a cargar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final rawDocs = snapshot.data?.docs ?? [];
            final List<Map<String, dynamic>> todasJfm = [];
            final List<Map<String, dynamic>> todasConeval = [];

            for (final doc in rawDocs) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final tipo = (data['tipo_cuestionario'] ?? 'FAMILIA_MISIONERA')
                  .toString();
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
        ),
      ),
    );
  }
}
