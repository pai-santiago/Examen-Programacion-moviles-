import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/coneval_form_data.dart';
import '../models/jfm_form_data.dart';
import '../services/firestore_service.dart';

class ConevalScreen extends StatefulWidget {
  final String? surveyIdExistente;
  final Map<String, dynamic>? respuestasExistentes;
  final List<Map<String, dynamic>>? integrantesExistentes;
  final String? usuarioEmail;
  final String? encuestadorUidExistente;
  final bool encuestaCompletada;

  const ConevalScreen({
    super.key,
    this.surveyIdExistente,
    this.respuestasExistentes,
    this.integrantesExistentes,
    this.usuarioEmail,
    this.encuestadorUidExistente,
    this.encuestaCompletada = false,
  });

  @override
  State<ConevalScreen> createState() => _ConevalScreenState();
}

class _ConevalScreenState extends State<ConevalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late final String _surveyId;
  late final String _encuestadorEmail;
  late final Map<String, dynamic> _respuestas;
  late final List<Map<String, dynamic>> _integrantes;
  int _paso = 0;
  int _siguienteIdLocal = 0;
  bool _guardando = false;

  static const _pasos = [
    'Ubicación y hogar',
    'Integrantes',
    'Educación y trabajo',
    'Salud e ingresos',
    'Economía y alimentación',
    'Características de la vivienda',
    'Servicios y equipamiento',
    'Comunidad y cierre',
  ];

  @override
  void initState() {
    super.initState();
    _surveyId =
        widget.surveyIdExistente ??
        'coneval_${DateTime.now().millisecondsSinceEpoch}';
    _respuestas = Map<String, dynamic>.from(widget.respuestasExistentes ?? {});
    final emailExistente = _respuestas['misionero_aplica']?.toString().trim();
    _encuestadorEmail = emailExistente?.isNotEmpty == true
        ? emailExistente!
        : widget.usuarioEmail ??
              FirebaseAuth.instance.currentUser?.email ??
              'Sin correo registrado';
    final sedes = sedesComunidadesJfm.keys.toList();
    final sede = _respuestas['sede']?.toString() ?? 'Anáhuac Cancún';
    _respuestas['sede'] = sedes.contains(sede) ? sede : sedes.first;
    _respuestas.putIfAbsent('comunidad', () => '');
    _respuestas.putIfAbsent(
      'fecha_entrevista',
      () =>
          widget.surveyIdExistente == null ? _formatoFecha(DateTime.now()) : '',
    );

    final integrantesPrevios =
        widget.integrantesExistentes ??
        (_respuestas['integrantes'] is List
            ? List<Map<String, dynamic>>.from(
                (_respuestas['integrantes'] as List).whereType<Map>().map(
                  (persona) => Map<String, dynamic>.from(persona),
                ),
              )
            : <Map<String, dynamic>>[]);
    _integrantes = integrantesPrevios.map(_prepararIntegrante).toList();
    if (_integrantes.isEmpty) _integrantes.add(_nuevoIntegrante());
  }

  static String _formatoFecha(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> _nuevoIntegrante() => {
    '_id_local': 'persona_${_siguienteIdLocal++}',
  };

  Map<String, dynamic> _prepararIntegrante(Map<String, dynamic> raw) {
    final persona = Map<String, dynamic>.from(raw);
    persona['_id_local'] = 'persona_${_siguienteIdLocal++}';
    return persona;
  }

  String _idPersona(Map<String, dynamic> persona) =>
      persona['_id_local']?.toString() ?? 'persona';

  bool _personaTieneDatos(Map<String, dynamic> persona) => persona.entries.any(
    (entry) =>
        entry.key != '_id_local' &&
        entry.value != null &&
        entry.value.toString().trim().isNotEmpty &&
        entry.value != false &&
        !(entry.value is List && (entry.value as List).isEmpty),
  );

  List<Map<String, dynamic>> _integrantesGuardables() => _integrantes
      .where(_personaTieneDatos)
      .map(
        (persona) => Map<String, dynamic>.fromEntries(
          persona.entries.where((entry) => entry.key != '_id_local'),
        ),
      )
      .toList();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _guardar({
    required String estado,
    bool cerrarAlGuardar = true,
  }) async {
    final integrantes = _integrantesGuardables();
    if (estado == 'completado' &&
        ((_respuestas['municipio'] ?? '').toString().trim().isEmpty ||
            (_respuestas['comunidad'] ?? '').toString().trim().isEmpty)) {
      setState(() => _paso = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el municipio y la comunidad para finalizar.'),
        ),
      );
      return;
    }
    if (estado == 'completado' &&
        _entero(_respuestas['num_habitantes']) == 0 &&
        !integrantes.any(
          (persona) =>
              (persona['nombre'] ?? '').toString().trim().isNotEmpty ||
              (persona['apellido_paterno'] ?? '').toString().trim().isNotEmpty,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Agrega al menos un integrante del hogar para finalizar.',
          ),
        ),
      );
      setState(() => _paso = 1);
      return;
    }

    setState(() => _guardando = true);
    try {
      final sede = (_respuestas['sede'] ?? '').toString();
      final comunidad = (_respuestas['comunidad'] ?? '').toString().trim();
      final respuestas = Map<String, dynamic>.from(_respuestas)
        ..remove('integrantes')
        ..['misionero_aplica'] = _encuestadorEmail
        ..['integrantes_count'] = integrantes.length
        ..['num_habitantes'] = integrantes.isNotEmpty
            ? integrantes.length
            : _entero(_respuestas['num_habitantes'], fallback: 0)
        ..['apellido_familia'] = _apellidoRepresentativo(integrantes)
        ..['carencia_alimentaria'] = _hayCarenciaAlimentaria()
        ..['servicios_basicos'] = _hayServiciosIncompletos()
        ..['fecha_entrevista'] = (_respuestas['fecha_entrevista'] ?? '')
            .toString();

      await _firestoreService.guardarEncuesta(
        surveyId: _surveyId,
        tipoCuestionario: 'CONEVAL',
        sede: sede,
        comunidad: comunidad.isEmpty ? 'Sin comunidad' : comunidad,
        estado: estado,
        respuestas: respuestas,
        integrantes: integrantes,
        encuestadorUid: widget.encuestadorUidExistente,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            estado == 'completado'
                ? widget.encuestaCompletada
                      ? cerrarAlGuardar
                            ? 'Cambios guardados correctamente.'
                            : 'Avance actualizado.'
                      : cerrarAlGuardar
                      ? 'Diagnóstico comunitario finalizado.'
                      : 'Avance guardado.'
                : 'Borrador guardado. Puedes continuar después.',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      if (estado == 'completado' && cerrarAlGuardar) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar. Revisa tu conexión e intenta guardar de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  int _entero(dynamic value, {int fallback = 0}) =>
      value is int ? value : int.tryParse('$value') ?? fallback;

  String _apellidoRepresentativo(List<Map<String, dynamic>> integrantes) {
    if (integrantes.isEmpty) {
      return (_respuestas['apellido_familia'] ?? '').toString();
    }
    final persona = integrantes.first;
    final apellidos = [persona['apellido_paterno'], persona['apellido_materno']]
        .where((value) => value != null && value.toString().trim().isNotEmpty)
        .join(' ');
    return apellidos.isEmpty
        ? (_respuestas['apellido_familia'] ?? '').toString()
        : apellidos;
  }

  String _hayCarenciaAlimentaria() {
    final campos = [
      'preocupo_comida_acabara',
      ...List.generate(7, (index) => 'menores_alimentacion_$index'),
      ...List.generate(7, (index) => 'adultos_alimentacion_$index'),
    ];
    final respondidos = campos.where(_respuestas.containsKey).toList();
    if (respondidos.isEmpty) return 'No evaluado';
    if (respondidos.any((id) => _respuestas[id] == 'Sí')) return 'Si';
    return respondidos.length == campos.length ? 'No' : 'Parcial';
  }

  String _hayServiciosIncompletos() {
    const campos = ['agua_fuente', 'energia_electrica', 'drenaje'];
    final respondidos = campos.where(_respuestas.containsKey).length;
    if (respondidos == 0) return 'No evaluado';
    final incompleto =
        _respuestas['energia_electrica'] == 'No' ||
        _respuestas['drenaje'] == 'No' ||
        _respuestas['agua_fuente'] == 'No cuenta con agua potable';
    if (incompleto) return 'Incompletos';
    return respondidos == campos.length ? 'Completos' : 'Parcial';
  }

  Widget _input(
    String id,
    String titulo, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return _campo(
      titulo,
      TextFormField(
        key: ValueKey('coneval_input_$id'),
        initialValue: _respuestas[id]?.toString() ?? '',
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
        onChanged: (value) => _respuestas[id] = value.trim(),
      ),
    );
  }

  Widget _fechaInput(
    String id,
    String titulo, {
    Map<String, dynamic>? persona,
  }) {
    final values = persona ?? _respuestas;
    final value = values[id]?.toString() ?? '';
    final fieldId = persona == null ? id : '${_idPersona(persona)}_$id';
    return _campo(
      titulo,
      TextFormField(
        key: ValueKey('coneval_date_${fieldId}_$value'),
        readOnly: true,
        initialValue: value,
        decoration: const InputDecoration(
          hintText: 'Selecciona la fecha',
          suffixIcon: Icon(Icons.calendar_today_outlined, size: 19),
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
        onTap: () async {
          final ahora = DateTime.now();
          final fechaActual = DateTime.tryParse(value) ?? ahora;
          final fechaMinima = DateTime(1900);
          final fechaInicial = fechaActual.isBefore(fechaMinima)
              ? fechaMinima
              : fechaActual.isAfter(ahora)
              ? ahora
              : fechaActual;
          final seleccionada = await showDatePicker(
            context: context,
            initialDate: fechaInicial,
            firstDate: fechaMinima,
            lastDate: ahora,
            helpText: titulo,
          );
          if (seleccionada != null && mounted) {
            setState(() => values[id] = _formatoFecha(seleccionada));
          }
        },
      ),
    );
  }

  Widget _horaInput(String id, String titulo) {
    final value = _respuestas[id]?.toString() ?? '';
    final parts = value.split(':');
    final hora = parts.length == 2 ? int.tryParse(parts[0]) : null;
    final minuto = parts.length == 2 ? int.tryParse(parts[1]) : null;
    final initial =
        hora != null &&
            minuto != null &&
            hora >= 0 &&
            hora < 24 &&
            minuto >= 0 &&
            minuto < 60
        ? TimeOfDay(hour: hora, minute: minuto)
        : TimeOfDay.now();
    return _campo(
      titulo,
      TextFormField(
        key: ValueKey('coneval_time_${id}_$value'),
        readOnly: true,
        initialValue: value,
        decoration: const InputDecoration(
          hintText: 'Selecciona la hora',
          suffixIcon: Icon(Icons.schedule_outlined, size: 19),
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
        onTap: () async {
          final seleccionada = await showTimePicker(
            context: context,
            initialTime: initial,
            helpText: titulo,
          );
          if (seleccionada != null && mounted) {
            final hora = seleccionada.hour.toString().padLeft(2, '0');
            final minuto = seleccionada.minute.toString().padLeft(2, '0');
            setState(() => _respuestas[id] = '$hora:$minuto');
          }
        },
      ),
    );
  }

  Widget _dropdown(String id, String titulo, List<String> opciones) {
    final valor = _respuestas[id]?.toString();
    return _campo(
      titulo,
      DropdownButtonFormField<String>(
        key: ValueKey('coneval_dropdown_$id'),
        initialValue: opciones.contains(valor) ? valor : null,
        isExpanded: true,
        decoration: const InputDecoration(
          hintText: 'Selecciona una opción',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
        items: opciones
            .map(
              (opcion) => DropdownMenuItem(
                value: opcion,
                child: Text(opcion, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _respuestas[id] = value),
      ),
    );
  }

  Widget _choice(String id, String titulo, List<String> opciones) {
    final valor = _respuestas[id]?.toString();
    return _campo(
      titulo,
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: opciones.map((opcion) {
          final seleccionado = valor == opcion;
          return ChoiceChip(
            label: Text(opcion),
            selected: seleccionado,
            onSelected: (_) => setState(() => _respuestas[id] = opcion),
            selectedColor: const Color(0xFFFFE4D5),
            labelStyle: TextStyle(
              color: seleccionado ? red : const Color(0xFF514A46),
              fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _multi(String id, String titulo, List<String> opciones) {
    final selected = (_respuestas[id] is Iterable)
        ? List<String>.from(_respuestas[id] as Iterable)
        : <String>[];
    return _campo(
      titulo,
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: opciones.map((opcion) {
          final activo = selected.contains(opcion);
          return FilterChip(
            label: Text(opcion),
            selected: activo,
            onSelected: (value) => setState(() {
              final values = List<String>.from(selected);
              value ? values.add(opcion) : values.remove(opcion);
              _respuestas[id] = values;
            }),
            selectedColor: const Color(0xFFFFE4D5),
          );
        }).toList(),
      ),
    );
  }

  Widget _campo(String titulo, Widget control) => Padding(
    padding: const EdgeInsets.only(bottom: 17),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3),
        ),
        const SizedBox(height: 7),
        control,
      ],
    ),
  );

  Widget _seccion(
    String titulo, {
    String? descripcion,
    required List<Widget> children,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFECE1DA)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        if (descripcion != null) ...[
          const SizedBox(height: 5),
          Text(
            descripcion,
            style: const TextStyle(
              color: Color(0xFF807671),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );

  Widget _miembroInput(
    Map<String, dynamic> persona,
    String id,
    String titulo, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) => _campo(
    titulo,
    TextFormField(
      key: ValueKey('${_idPersona(persona)}_$id'),
      initialValue: persona[id]?.toString() ?? '',
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
      onChanged: (value) => persona[id] = value.trim(),
    ),
  );

  Widget _miembroDropdown(
    Map<String, dynamic> persona,
    String id,
    String titulo,
    List<String> opciones,
  ) {
    final valor = persona[id]?.toString();
    return _campo(
      titulo,
      DropdownButtonFormField<String>(
        key: ValueKey('${_idPersona(persona)}_$id'),
        initialValue: opciones.contains(valor) ? valor : null,
        isExpanded: true,
        decoration: const InputDecoration(
          hintText: 'Selecciona una opción',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
        items: opciones
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => setState(() => persona[id] = value),
      ),
    );
  }

  Widget _miembroChoice(
    Map<String, dynamic> persona,
    String id,
    String titulo,
    List<String> opciones,
  ) {
    final valor = persona[id]?.toString();
    return _campo(
      titulo,
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: opciones
            .map(
              (opcion) => ChoiceChip(
                label: Text(opcion),
                selected: valor == opcion,
                onSelected: (_) => setState(() => persona[id] = opcion),
                selectedColor: const Color(0xFFFFE4D5),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _miembroMulti(
    Map<String, dynamic> persona,
    String id,
    String titulo,
    List<String> opciones,
  ) {
    final selected = persona[id] is Iterable
        ? List<String>.from(persona[id] as Iterable)
        : <String>[];
    return _campo(
      titulo,
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: opciones
            .map(
              (opcion) => FilterChip(
                label: Text(opcion),
                selected: selected.contains(opcion),
                onSelected: (value) => setState(() {
                  final values = List<String>.from(selected);
                  value ? values.add(opcion) : values.remove(opcion);
                  persona[id] = values;
                }),
                selectedColor: const Color(0xFFFFE4D5),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _tarjetaIntegrante(int index, List<Widget> fields) {
    final persona = _integrantes[index];
    final nombre = [persona['nombre'], persona['apellido_paterno']]
        .where((value) => value != null && value.toString().trim().isNotEmpty)
        .join(' ');
    final datosCapturados = persona.entries
        .where(
          (entry) =>
              entry.key != '_id_local' &&
              entry.value != null &&
              entry.value.toString().trim().isNotEmpty,
        )
        .length;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE1DA)),
      ),
      child: ExpansionTile(
        key: PageStorageKey('${_idPersona(persona)}_paso_$_paso'),
        initiallyExpanded: index == 0,
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        title: Text(
          nombre.isEmpty ? 'Integrante ${index + 1}' : nombre,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        subtitle: Text(
          datosCapturados == 0
              ? 'Toca para capturar sus datos'
              : '$datosCapturados datos capturados',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_integrantes.length > 1)
              IconButton(
                tooltip: 'Quitar integrante',
                onPressed: () => setState(() => _integrantes.removeAt(index)),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF9A3E35),
                ),
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [Column(children: fields)],
      ),
    );
  }

  Widget _buildUbicacion() => Column(
    children: [
      _seccion(
        'Ubicación del inmueble',
        descripcion: 'Estos datos ayudan a localizar el hogar y filtrar los reportes por sede y comunidad.',
        children: [
          _dropdown(
            'sede',
            'Sede universitaria responsable',
            sedesComunidadesJfm.keys.toList(),
          ),
          _dropdown('estado', 'Estado', estadosMexico),
          if (_respuestas['estado'] == 'Otro')
            _input('estado_otro', 'Especifica el estado'),
          _input('municipio', 'Municipio'),
          _input('comunidad', 'Nombre de la comunidad'),
          _input('ageb', 'AGEB (INEGI)'),
          _input('manzana', 'Manzana'),
          _input('domicilio', 'Domicilio', maxLines: 2),
          _input('religion_hogar', '¿Qué religión profesan en el hogar?'),
        ],
      ),
      _seccion(
        'Situación del predio',
        children: [
          _choice(
            'comunidad_indigena',
            '¿La vivienda está en una comunidad reconocida como indígena?',
            opcionesSiNo,
          ),
          _choice(
            'predio_habitado',
            '¿El predio se usa como vivienda y está habitado?',
            opcionesSiNo,
          ),
          _input(
            'uso_predio_detalle',
            'Describe el uso del predio (si aplica)',
            maxLines: 2,
          ),
          _choice(
            'papeles_propiedad',
            '¿Los habitantes cuentan con papeles de propiedad?',
            opcionesSiNo,
          ),
          _input(
            'situacion_legal_inmueble',
            'Describe la situación legal del inmueble (si aplica)',
            maxLines: 3,
          ),
        ],
      ),
    ],
  );

  Widget _buildIntegrantes() => Column(
    children: [
      _seccion(
        'Integrantes del hogar',
        descripcion: 'Agrega a cada persona que vive habitualmente en la vivienda. Los campos se guardan en un perfil independiente.',
        children: [
          ...List.generate(_integrantes.length, (index) {
            final persona = _integrantes[index];
            return _tarjetaIntegrante(index, [
              _miembroInput(persona, 'nombre', 'Nombre'),
              _miembroInput(persona, 'apellido_paterno', 'Apellido paterno'),
              _miembroInput(persona, 'apellido_materno', 'Apellido materno'),
              _miembroDropdown(
                persona,
                'parentesco',
                'Parentesco',
                parentescosHogar,
              ),
              if (persona['parentesco'] == 'Otro')
                _miembroInput(
                  persona,
                  'parentesco_otro',
                  'Especifica el parentesco',
                ),
              _miembroInput(persona, 'curp', 'CURP', hint: '18 caracteres'),
              _miembroDropdown(persona, 'sexo', 'Sexo', [
                'Mujer',
                'Hombre',
                'No respondió',
              ]),
              _fechaInput(
                'fecha_nacimiento',
                'Fecha de nacimiento',
                persona: persona,
              ),
              _miembroDropdown(
                persona,
                'estado_nacimiento',
                'Estado de nacimiento',
                estadosMexico,
              ),
              if (persona['estado_nacimiento'] == 'Otro')
                _miembroInput(
                  persona,
                  'estado_nacimiento_otro',
                  'Especifica el estado',
                ),
              _miembroDropdown(persona, 'estado_civil', 'Estado civil', [
                'Soltero(a)',
                'Casado(a)',
                'Unión libre',
                'Separado(a)',
                'Divorciado(a)',
                'Viudo(a)',
                'No respondió',
              ]),
              _miembroChoice(
                persona,
                'habla_lengua_indigena',
                '¿Habla alguna lengua indígena?',
                opcionesSiNo,
              ),
              if (persona['habla_lengua_indigena'] == 'Sí')
                _miembroInput(persona, 'lengua_indigena', '¿Cuál lengua?'),
            ]);
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () =>
                  setState(() => _integrantes.add(_nuevoIntegrante())),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Agregar integrante'),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildEducacionTrabajo() => Column(
    children: [
      _seccion(
        'Educación y trabajo por integrante',
        descripcion: 'Completa esta información para cada persona. Si no trabaja, selecciona el motivo correspondiente.',
        children: [
          ...List.generate(_integrantes.length, (index) {
            final persona = _integrantes[index];
            return _tarjetaIntegrante(index, [
              _miembroChoice(
                persona,
                'asiste_escuela',
                '¿Actualmente asiste a la escuela?',
                opcionesSiNo,
              ),
              _miembroDropdown(
                persona,
                'ultimo_grado_estudios',
                '¿Cuál es el último grado de estudios?',
                gradosEstudio,
              ),
              _miembroChoice(
                persona,
                'trabaja',
                '¿Actualmente trabaja?',
                opcionesSiNo,
              ),
              if (persona['trabaja'] == 'Sí') ...[
                _miembroInput(
                  persona,
                  'actividad_trabajo',
                  '¿Qué actividad realiza?',
                ),
                _miembroDropdown(
                  persona,
                  'posicion_trabajo',
                  'En su trabajo, ¿es dueño(a) o empleado(a)?',
                  ['Dueño(a)', 'Empleado(a)', 'Trabajador(a) sin pago', 'Otro'],
                ),
                _miembroInput(
                  persona,
                  'salario_mensual',
                  '¿Cuánto recibe mensualmente de salario? (MXN)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ] else if (persona['trabaja'] == 'No')
                _miembroDropdown(
                  persona,
                  'motivo_no_trabaja',
                  'Situación actual',
                  motivosNoTrabajo,
                ),
              _miembroChoice(
                persona,
                'servicio_medico',
                '¿Cuenta con servicio médico?',
                opcionesSiNo,
              ),
              if (persona['servicio_medico'] == 'Sí') ...[
                _miembroDropdown(
                  persona,
                  'tipo_servicio_medico',
                  '¿Con qué tipo de servicio médico cuenta?',
                  serviciosMedicos,
                ),
                _miembroDropdown(
                  persona,
                  'proveedor_servicio_medico',
                  '¿Quién le proporciona el servicio médico?',
                  proveedorServicioMedico,
                ),
              ],
              _miembroChoice(
                persona,
                'afore',
                '¿Cuenta con AFORE?',
                opcionesSiNo,
              ),
              _miembroChoice(
                persona,
                'pago_incapacidad',
                '¿Recibe pago por incapacidad médica?',
                opcionesSiNo,
              ),
            ]);
          }),
        ],
      ),
    ],
  );

  Widget _buildSaludIngresos() => Column(
    children: [
      _seccion(
        'Salud e ingresos por integrante',
        children: [
          ...List.generate(_integrantes.length, (index) {
            final persona = _integrantes[index];
            return _tarjetaIntegrante(index, [
              _miembroChoice(
                persona,
                'discapacidad',
                '¿Tiene alguna discapacidad?',
                opcionesSiNo,
              ),
              if (persona['discapacidad'] == 'Sí')
                _miembroMulti(
                  persona,
                  'tipos_discapacidad',
                  '¿Qué discapacidad tiene?',
                  tiposDiscapacidad,
                ),
              if ((persona['tipos_discapacidad'] as List?)?.contains('Otra') ==
                  true)
                _miembroInput(
                  persona,
                  'discapacidad_otra',
                  'Especifica la discapacidad',
                ),
              _miembroChoice(
                persona,
                'padecimiento',
                '¿Tiene algún padecimiento o enfermedad?',
                opcionesSiNo,
              ),
              if (persona['padecimiento'] == 'Sí')
                _miembroMulti(
                  persona,
                  'tipos_padecimiento',
                  '¿Qué tipo de padecimiento o enfermedad tiene?',
                  padecimientos,
                ),
              if ((persona['tipos_padecimiento'] as List?)?.contains('Otro') ==
                  true)
                _miembroInput(
                  persona,
                  'padecimiento_otro',
                  'Especifica el padecimiento',
                ),
              _miembroChoice(
                persona,
                'ingresos_adicionales',
                '¿Cuenta con ingresos adicionales al salario?',
                opcionesSiNo,
              ),
              if (persona['ingresos_adicionales'] == 'Sí') ...[
                _miembroMulti(
                  persona,
                  'fuentes_ingreso_adicional',
                  'Selecciona las fuentes de ingreso',
                  fuentesIngresoAdicional,
                ),
                if ((persona['fuentes_ingreso_adicional'] as List?)?.contains(
                      'Otro',
                    ) ==
                    true)
                  _miembroInput(
                    persona,
                    'fuente_ingreso_otra',
                    'Especifica el otro ingreso',
                  ),
                _miembroInput(
                  persona,
                  'monto_ingresos_adicionales',
                  'Monto mensual aproximado (MXN)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
              _miembroChoice(
                persona,
                'beneficiario_programa_social',
                '¿Es beneficiario(a) de algún programa social?',
                opcionesSiNo,
              ),
              if (persona['beneficiario_programa_social'] == 'Sí') ...[
                _miembroInput(
                  persona,
                  'cantidad_apoyos',
                  '¿Cuántos apoyos recibe?',
                  keyboardType: TextInputType.number,
                ),
                _miembroInput(
                  persona,
                  'programas_sociales',
                  '¿De cuáles programas es beneficiario(a)?',
                  hint: 'Puedes anotar varios',
                  maxLines: 2,
                ),
                _miembroInput(
                  persona,
                  'monto_programas_mensual',
                  'Monto mensual percibido (MXN)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ]);
          }),
        ],
      ),
    ],
  );

  Widget _buildEconomiaAlimentacion() => Column(
    children: [
      _seccion(
        'Gasto mensual del hogar',
        children: [
          for (final entry in const {
            'gasto_alimentacion': 'Alimentación',
            'gasto_luz': 'Luz',
            'gasto_agua': 'Agua',
            'gasto_vivienda': 'Vivienda',
            'gasto_educacion': 'Educación',
            'gasto_salud': 'Salud',
            'gasto_otro': 'Otro',
          }.entries)
            _input(
              entry.key,
              '¿Cuánto destinan al mes a ${entry.value}? (MXN)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
        ],
      ),
      _seccion(
        'Acceso a la alimentación',
        descripcion: 'Responde según lo que ocurrió en los últimos meses por falta de recursos.',
        children: [
          _input(
            'comidas_dia',
            '¿Cuántas comidas al día acostumbran consumir en este hogar?',
            keyboardType: TextInputType.number,
          ),
          _choice(
            'preocupo_comida_acabara',
            '¿Le preocupó que la comida se acabara?',
            opcionesSiNo,
          ),
          const SizedBox(height: 4),
          const Text(
            'Menores de 18 años',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            preguntasAlimentacion.length,
            (index) => _choice(
              'menores_alimentacion_$index',
              preguntasAlimentacion[index],
              opcionesSiNo,
            ),
          ),
          const Divider(height: 32),
          const Text(
            'Personas adultas de 18 años en adelante',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            preguntasAlimentacion.length,
            (index) => _choice(
              'adultos_alimentacion_$index',
              preguntasAlimentacion[index],
              opcionesSiNo,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildVivienda() => Column(
    children: [
      _seccion(
        'Características de la vivienda',
        children: [
          _dropdown(
            'clase_vivienda',
            'Clase de vivienda particular',
            clasesVivienda,
          ),
          if (_respuestas['clase_vivienda'] == 'Otro')
            _input('clase_vivienda_otra', 'Especifica la clase de vivienda'),
          _dropdown(
            'tenencia_vivienda',
            'La vivienda que habita es',
            tenenciaVivienda,
          ),
          _dropdown(
            'material_paredes',
            '¿De qué material es la mayor parte de la vivienda?',
            materialesPared,
          ),
          if (_respuestas['material_paredes'] == 'Otro')
            _input(
              'material_paredes_otro',
              'Especifica el material de las paredes',
            ),
          _dropdown(
            'material_techo',
            '¿De qué material es el techo de la vivienda?',
            materialesTecho,
          ),
          if (_respuestas['material_techo'] == 'Otro')
            _input('material_techo_otro', 'Especifica el material del techo'),
        ],
      ),
    ],
  );

  Widget _buildServicios() => Column(
    children: [
      _seccion(
        'Servicios de la vivienda',
        children: [
          _dropdown(
            'agua_fuente',
            '¿Cómo obtiene principalmente el agua potable?',
            fuentesAgua,
          ),
          if (_respuestas['agua_fuente'] == 'Otro')
            _input('agua_fuente_otra', 'Especifica la fuente de agua'),
          _choice(
            'energia_electrica',
            '¿La vivienda cuenta con energía eléctrica?',
            opcionesSiNo,
          ),
          _input(
            'cantidad_focos',
            '¿Cuántos focos tiene la vivienda?',
            keyboardType: TextInputType.number,
          ),
          _choice('drenaje', '¿Cuenta con drenaje?', opcionesSiNo),
          if (_respuestas['drenaje'] == 'Sí')
            _dropdown(
              'conexion_drenaje',
              '¿A qué está conectado principalmente?',
              conexionesDrenaje,
            ),
          _input(
            'habitaciones_vivienda',
            '¿Con cuántas habitaciones cuenta la vivienda?',
            keyboardType: TextInputType.number,
          ),
          if (_integrantesGuardables().isNotEmpty &&
              _entero(_respuestas['habitaciones_vivienda']) > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _integrantesGuardables().length >
                        _entero(_respuestas['habitaciones_vivienda'])
                    ? 'Hay más integrantes que habitaciones; revisa la posible condición de hacinamiento.'
                    : 'Integrantes y habitaciones: ${_integrantesGuardables().length} / ${_entero(_respuestas['habitaciones_vivienda'])}.',
                style: TextStyle(
                  color:
                      _integrantesGuardables().length >
                          _entero(_respuestas['habitaciones_vivienda'])
                      ? const Color(0xFF9A3E35)
                      : const Color(0xFF625B56),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          _input(
            'cantidad_banos',
            '¿Con cuántos baños cuenta la vivienda?',
            keyboardType: TextInputType.number,
          ),
          _choice(
            'letrina',
            '¿Cuentan con letrina en la vivienda?',
            opcionesSiNo,
          ),
        ],
      ),
      _seccion(
        'Equipamiento y actividades',
        children: [
          _multi(
            'equipamiento',
            '¿Con qué equipamiento cuenta la vivienda?',
            equipamientoVivienda,
          ),
          _choice('vehiculo', '¿Cuenta con vehículo?', opcionesSiNo),
          if (_respuestas['vehiculo'] == 'Sí')
            _input(
              'cantidad_vehiculos',
              '¿Con cuántos vehículos cuenta?',
              keyboardType: TextInputType.number,
            ),
          _dropdown(
            'combustible_cocina',
            '¿Qué utiliza principalmente para cocinar?',
            ['Gas', 'Leña o carbón', 'Parrilla eléctrica', 'Otro'],
          ),
          if (_respuestas['combustible_cocina'] == 'Otro')
            _input('combustible_cocina_otro', 'Especifica el combustible'),
          _choice('chimenea', '¿Tiene chimenea?', opcionesSiNo),
          _choice(
            'huerto_familiar',
            '¿Cuenta con un huerto familiar?',
            opcionesSiNo,
          ),
        ],
      ),
      _seccion(
        'Facilidad para resolver necesidades',
        descripcion: 'Selecciona una opción: 1 Imposible · 2 Muy difícil · 3 Difícil · 4 Regular · 5 Fácil · 6 Muy fácil.',
        children: [
          ...List.generate(
            necesidadesVivienda.length,
            (index) => _dropdown(
              'facilidad_$index',
              necesidadesVivienda[index],
              escalasFacilidad,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildComunidad() => Column(
    children: [
      _seccion(
        'Violencia y observaciones',
        children: [
          _choice(
            'violencia_familiar',
            '¿Usted o un miembro de la familia ha sufrido violencia?',
            opcionesSiNoNoRespondio,
          ),
          if (_respuestas['violencia_familiar'] == 'Sí') ...[
            _multi(
              'personas_afectadas',
              '¿Quién fue afectado?',
              parentescosAfectados,
            ),
            if ((_respuestas['personas_afectadas'] as List?)?.contains(
                  'Otros',
                ) ==
                true)
              _input('persona_afectada_otra', 'Especifica quién fue afectado'),
            _multi('tipos_violencia', '¿Qué tipo de violencia sufrió?', [
              'Verbal',
              'Física',
              'Psicológica',
              'Otra',
            ]),
            if ((_respuestas['tipos_violencia'] as List?)?.contains('Otra') ==
                true)
              _input('tipo_violencia_otro', 'Especifica el tipo de violencia'),
            _multi(
              'lugares_violencia',
              '¿En qué lugar ocurrió el incidente?',
              lugaresViolencia,
            ),
            if ((_respuestas['lugares_violencia'] as List?)?.contains('Otro') ==
                true)
              _input('lugar_violencia_otro', 'Especifica el lugar'),
            _multi(
              'actores_violencia',
              '¿Quién fue el autor del incidente?',
              actoresViolencia,
            ),
            if ((_respuestas['actores_violencia'] as List?)?.contains('Otro') ==
                true)
              _input('actor_violencia_otro', 'Especifica quién fue'),
            _choice(
              'denuncia_violencia',
              '¿Realizaron la denuncia?',
              opcionesDenuncia,
            ),
          ],
          _input(
            'observaciones_entrevistador',
            'Observaciones generales del entrevistador',
            maxLines: 4,
          ),
        ],
      ),
      _seccion(
        'Acceso a servicios básicos',
        children: [
          _dropdown(
            'distancia_centro_salud',
            '¿A qué distancia está el centro de salud más cercano?',
            distanciaServicios,
          ),
          _dropdown(
            'distancia_escuela',
            '¿A qué distancia está la escuela más cercana?',
            distanciaServicios,
          ),
          _multi(
            'niveles_escuela',
            '¿Con qué niveles educativos cuenta la escuela más cercana?',
            nivelesEducativosEscuela,
          ),
        ],
      ),
      _seccion(
        'Cohesión social comunitaria',
        children: [
          _dropdown(
            'confianza_comunidad',
            '¿Qué tanto confía en las personas de su comunidad?',
            opcionesConfianza,
          ),
          _dropdown(
            'ayuda_comunidad',
            '¿Las personas suelen ayudarse en momentos de necesidad?',
            opcionesAyuda,
          ),
          _choice(
            'participacion_comunitaria',
            '¿Usted o alguien de su familia participa en grupos o actividades comunitarias?',
            opcionesSiNo,
          ),
          _dropdown(
            'respeto_comunidad',
            '¿En su comunidad se respetan aunque piensen diferente?',
            opcionesRespeto,
          ),
          _dropdown(
            'unidad_comunidad',
            '¿La comunidad trabaja unida para resolver problemas comunes?',
            opcionesUnidad,
          ),
        ],
      ),
      _seccion(
        'Ficha técnica de la entrevista',
        children: [
          _fechaInput('fecha_entrevista', 'Fecha de la entrevista'),
          _horaInput('hora_entrevista', 'Hora'),
          _input(
            'numero_visita',
            'Número de visita',
            keyboardType: TextInputType.number,
          ),
          _input('nombre_entrevistado', 'Nombre del entrevistado(a)'),
          _firma('firma_entrevistado', 'Firma del entrevistado(a)'),
          _input(
            'nombre_entrevistador',
            'Nombre del entrevistador(a)',
            hint: _encuestadorEmail,
          ),
          _firma('firma_entrevistador', 'Firma del entrevistador(a)'),
        ],
      ),
    ],
  );

  Widget _firma(String id, String titulo) {
    final inicial = _respuestas[id] is List
        ? List<List<Map<String, dynamic>>>.from(
            (_respuestas[id] as List).map(
              (stroke) => List<Map<String, dynamic>>.from(
                (stroke as List).map(
                  (point) => Map<String, dynamic>.from(point as Map),
                ),
              ),
            ),
          )
        : <List<Map<String, dynamic>>>[];
    return _campo(
      titulo,
      SignaturePad(
        key: ValueKey('signature_$id'),
        initialStrokes: inicial,
        onChanged: (value) => _respuestas[id] = value,
      ),
    );
  }

  Widget _contenidoPaso() {
    switch (_paso) {
      case 0:
        return _buildUbicacion();
      case 1:
        return _buildIntegrantes();
      case 2:
        return _buildEducacionTrabajo();
      case 3:
        return _buildSaludIngresos();
      case 4:
        return _buildEconomiaAlimentacion();
      case 5:
        return _buildVivienda();
      case 6:
        return _buildServicios();
      default:
        return _buildComunidad();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progreso = (_paso + 1) / _pasos.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.encuestaCompletada
              ? 'Editar diagnóstico comunitario'
              : 'Diagnóstico comunitario',
        ),
        backgroundColor: red,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _guardando
                ? null
                : () => _guardar(
                    estado: widget.encuestaCompletada
                        ? 'completado'
                        : 'borrador',
                  ),
            icon: const Icon(Icons.save_outlined, color: Colors.white),
            label: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFFFF8F4),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _pasos[_paso],
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '${_paso + 1} de ${_pasos.length}',
                      style: const TextStyle(
                        color: Color(0xFF625B56),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 6,
                    color: red,
                    backgroundColor: const Color(0xFFFFE1D2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Encuestador: $_encuestadorEmail',
                  style: const TextStyle(
                    color: Color(0xFF807671),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: _contenidoPaso(),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFECE1DA))),
              ),
              child: Row(
                children: [
                  if (_paso > 0)
                    OutlinedButton.icon(
                      onPressed: _guardando
                          ? null
                          : () => setState(() => _paso--),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                    ),
                  const Spacer(),
                  if (_paso < _pasos.length - 1)
                    FilledButton.icon(
                      onPressed: _guardando
                          ? null
                          : () {
                              setState(() => _paso++);
                              _guardar(
                                estado: widget.encuestaCompletada
                                    ? 'completado'
                                    : 'borrador',
                                cerrarAlGuardar: false,
                              );
                            },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Guardar y continuar'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _guardando
                          ? null
                          : () => _guardar(estado: 'completado'),
                      icon: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        widget.encuestaCompletada
                            ? 'Guardar cambios'
                            : 'Finalizar encuesta',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignaturePad extends StatefulWidget {
  final List<List<Map<String, dynamic>>> initialStrokes;
  final ValueChanged<List<List<Map<String, dynamic>>>> onChanged;

  const SignaturePad({
    super.key,
    required this.initialStrokes,
    required this.onChanged,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  late List<List<Offset>> _strokes;

  @override
  void initState() {
    super.initState();
    _strokes = widget.initialStrokes
        .map(
          (stroke) => stroke
              .map(
                (point) => Offset(
                  (point['x'] as num?)?.toDouble() ?? 0,
                  (point['y'] as num?)?.toDouble() ?? 0,
                ),
              )
              .toList(),
        )
        .toList();
  }

  void _notify() => widget.onChanged(
    _strokes
        .map(
          (stroke) =>
              stroke.map((point) => {'x': point.dx, 'y': point.dy}).toList(),
        )
        .toList(),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCDC5BF)),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFFCFBFA),
        ),
        child: Semantics(
          label: 'Área de firma. Dibuja con el dedo o con el mouse.',
          hint: 'Usa Limpiar firma para borrar y volver a intentarlo.',
          child: GestureDetector(
            onPanStart: (details) => setState(() {
              _strokes.add([details.localPosition]);
              _notify();
            }),
            onPanUpdate: (details) => setState(() {
              if (_strokes.isNotEmpty) _strokes.last.add(details.localPosition);
              _notify();
            }),
            child: CustomPaint(
              painter: _SignaturePainter(_strokes),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: _strokes.isEmpty
              ? null
              : () => setState(() {
                  _strokes.clear();
                  _notify();
                }),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Limpiar firma'),
        ),
      ),
    ],
  );
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF292521)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.2, paint..style = PaintingStyle.fill);
      }
      if (stroke.length > 1) {
        final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
        for (final point in stroke.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawPath(path, paint..style = PaintingStyle.stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
