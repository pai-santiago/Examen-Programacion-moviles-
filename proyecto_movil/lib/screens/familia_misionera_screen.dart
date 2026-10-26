import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../forms/jfm_questions.dart';
import '../services/firestore_service.dart';

class FamiliaMisioneraScreen extends StatefulWidget {
  final String? surveyIdExistente;
  final Map<String, dynamic>? respuestasExistentes;
  final String? usuarioEmail;

  const FamiliaMisioneraScreen({
    super.key,
    this.surveyIdExistente,
    this.respuestasExistentes,
    this.usuarioEmail,
  });

  @override
  State<FamiliaMisioneraScreen> createState() => _FamiliaMisioneraScreenState();
}

class _FamiliaMisioneraScreenState extends State<FamiliaMisioneraScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late final String _surveyId;
  late final String _misioneroEmail;
  late final Map<String, dynamic> _respuestas;
  final Map<String, TextEditingController> _controllers = {};
  int _pasoActual = 0;
  bool _guardando = false;
  bool _sincronizadoEnNube = true;

  static const List<String> _clavesListas = [
    'referencias_casa',
    'lista_sacramentos',
    'lista_actividades_parroquia',
    'lista_problematicas',
  ];

  @override
  void initState() {
    super.initState();
    _surveyId = widget.surveyIdExistente ??
        'jfm_${DateTime.now().millisecondsSinceEpoch}';
    _misioneroEmail = widget.usuarioEmail ??
        FirebaseAuth.instance.currentUser?.email ??
        'misionero_demo@anahuac.mx';

    _respuestas = respuestasInicialesJfm(_misioneroEmail);

    // Si venimos de un borrador existente, hidratamos todas las respuestas previas
    if (widget.respuestasExistentes != null) {
      final prev = widget.respuestasExistentes!;
      for (final entry in prev.entries) {
        if (_clavesListas.contains(entry.key)) {
          final rawList = entry.value;
          _respuestas[entry.key] =
              rawList is Iterable ? List<String>.from(rawList) : <String>[];
        } else if (entry.key == 'num_habitantes') {
          final val = entry.value;
          final parsed = val is int ? val : int.tryParse('$val') ?? 1;
          _respuestas['num_habitantes'] = parsed.clamp(1, 10);
        } else if (entry.value != null) {
          _respuestas[entry.key] = entry.value;
        }
      }

      // Validar fallback seguro de Sede y Comunidad
      final sedesValidas = sedesComunidadesJfm.keys.toList();
      final sedeGuardada = _respuestas['sede']?.toString() ?? '';
      if (!sedesValidas.contains(sedeGuardada)) {
        _respuestas['sede'] = sedesValidas.first;
      }

      final comunidadesSede =
          sedesComunidadesJfm[_respuestas['sede']] ?? const ['Otra'];
      final comGuardada = _respuestas['comunidad']?.toString() ?? '';
      if (!comunidadesSede.contains(comGuardada)) {
        if (comGuardada.isNotEmpty) {
          _respuestas['comunidad'] = 'Otra';
          _respuestas['comunidad_otra'] = comGuardada;
        } else {
          _respuestas['comunidad'] = comunidadesSede.first;
        }
      }
    }

    // Inicializar TextEditingControllers para todos los campos de texto
    for (final paso in pasosJfm) {
      for (final p in paso.preguntas) {
        if (p.tipo == 'texto') {
          final textoInicial = (_respuestas[p.id] ?? '').toString();
          final ctrl = TextEditingController(text: textoInicial);
          ctrl.addListener(() {
            _respuestas[p.id] = ctrl.text;
          });
          _controllers[p.id] = ctrl;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _guardarEnFirebase({required String estado}) async {
    setState(() => _guardando = true);
    try {
      for (final entry in _controllers.entries) {
        _respuestas[entry.key] = entry.value.text.trim();
      }

      final String sedeSeleccionada =
          (_respuestas['sede'] ?? 'Anáhuac Cancún').toString();
      final String comunidadBase =
          (_respuestas['comunidad'] ?? 'Sin comunidad').toString();
      final String comunidadOtra =
          (_respuestas['comunidad_otra'] ?? '').toString().trim();
      final String comunidadFinal =
          (comunidadBase == 'Otra' && comunidadOtra.isNotEmpty)
              ? comunidadOtra
              : comunidadBase;

      _respuestas['misionero_aplica'] = _misioneroEmail;

      await _firestoreService.guardarEncuesta(
        surveyId: _surveyId,
        tipoCuestionario: 'FAMILIA_MISIONERA',
        sede: sedeSeleccionada,
        comunidad: comunidadFinal,
        estado: estado,
        respuestas: _respuestas,
      );

      if (!mounted) return;
      setState(() => _sincronizadoEnNube = true);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                estado == 'completado'
                    ? Icons.check_circle_outline
                    : Icons.cloud_done_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  estado == 'completado'
                      ? '¡Encuesta completada y guardada con éxito!'
                      : 'Borrador autoguardado (Paso ${_pasoActual + 1} de ${pasosJfm.length})',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );

      if (estado == 'completado') {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sincronizadoEnNube = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guardado en modo local / sin red: $e'),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _barraEstadoConexion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _sincronizadoEnNube
            ? const Color(0xFFEAF7EC)
            : const Color(0xFFFFF4E5),
        border: Border(
          bottom: BorderSide(
            color: _sincronizadoEnNube
                ? const Color(0xFFB7E1CD)
                : const Color(0xFFFFCC80),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _sincronizadoEnNube ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: _sincronizadoEnNube
                ? const Color(0xFF168321)
                : const Color(0xFFED6B00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _sincronizadoEnNube
                  ? 'Conectado · Autoguardado en tiempo real (Local + Firestore)'
                  : 'Modo Local Offline · Se sincronizará al recuperar red',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _sincronizadoEnNube
                    ? const Color(0xFF168321)
                    : const Color(0xFF8C3B00),
              ),
            ),
          ),
          if (_guardando)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _tarjetaEncuestadorActivo() {
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
          const Icon(Icons.verified_user_outlined,
              color: Color(0xFFFF5900), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Encuestador activo: $_misioneroEmail',
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

  // Etiqueta superior limpia y multi-línea para evitar recortes en el borde del InputDecoration
  Widget _etiquetaPregunta(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
          height: 1.3,
        ),
      ),
    );
  }

  static const InputDecoration _decoracionCampo = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  );

  Widget _construirPregunta(JfmQuestion p) {
    if (p.dependeDe != null && _respuestas[p.dependeDe] != p.valorEsperado) {
      return const SizedBox.shrink();
    }

    switch (p.tipo) {
      case 'dropdown':
      case 'si_no':
        final List<String> opciones = p.tipo == 'si_no'
            ? const ['Si', 'No']
            : (p.id == 'comunidad'
                ? (sedesComunidadesJfm[_respuestas['sede']] ?? const ['Otra'])
                : p.opciones);

        final String rawVal = (_respuestas[p.id] ?? '').toString();
        final String valorActual =
            opciones.contains(rawVal) ? rawVal : opciones.first;
        if (_respuestas[p.id] != valorActual) {
          _respuestas[p.id] = valorActual;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _etiquetaPregunta(p.titulo),
              DropdownButtonFormField<String>(
                key: ValueKey('${p.id}_${_respuestas['sede']}_$valorActual'),
                initialValue: valorActual,
                isExpanded: true,
                decoration: _decoracionCampo,
                items: opciones
                    .map(
                      (op) => DropdownMenuItem(
                        value: op,
                        child: Text(
                          op,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (nuevoValor) {
                  if (nuevoValor == null) return;
                  setState(() {
                    _respuestas[p.id] = nuevoValor;
                    if (p.id == 'sede') {
                      final nuevasComunidades =
                          sedesComunidadesJfm[nuevoValor] ?? const ['Otra'];
                      _respuestas['comunidad'] = nuevasComunidades.first;
                      _respuestas['comunidad_otra'] = '';
                      _controllers['comunidad_otra']?.clear();
                    }
                  });
                },
              ),
            ],
          ),
        );

      case 'numero':
        final opcionesNum = List.generate(10, (i) => i + 1);
        final rawNum = _respuestas[p.id];
        final int parsedNum =
            rawNum is int ? rawNum : (int.tryParse('$rawNum') ?? 1);
        final int valorActual =
            opcionesNum.contains(parsedNum) ? parsedNum : opcionesNum.first;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _etiquetaPregunta(p.titulo),
              DropdownButtonFormField<int>(
                key: ValueKey('${p.id}_$valorActual'),
                initialValue: valorActual,
                isExpanded: true,
                decoration: _decoracionCampo,
                items: opcionesNum
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _respuestas[p.id] = v);
                },
              ),
            ],
          ),
        );

      case 'chips_multiples':
        final rawList = _respuestas[p.id];
        final List<String> seleccionados =
            rawList is Iterable ? List<String>.from(rawList) : <String>[];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _etiquetaPregunta(p.titulo),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: p.opciones.map((opcion) {
                  final estaSeleccionado = seleccionados.contains(opcion);
                  return FilterChip(
                    label: Text(opcion),
                    selected: estaSeleccionado,
                    onSelected: (bool valor) {
                      setState(() {
                        if (valor) {
                          seleccionados.add(opcion);
                        } else {
                          seleccionados.remove(opcion);
                        }
                        _respuestas[p.id] = seleccionados;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );

      case 'texto':
      default:
        final ctrl = _controllers[p.id];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _etiquetaPregunta(p.titulo),
              TextFormField(
                controller: ctrl,
                maxLines: p.maxLines,
                keyboardType:
                    p.esTelefono ? TextInputType.phone : TextInputType.text,
                decoration: _decoracionCampo.copyWith(
                  hintText: 'Escribe aquí...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E948E),
                  ),
                ),
                onChanged: (v) => _respuestas[p.id] = v,
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicionBorrador = widget.surveyIdExistente != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          esEdicionBorrador
              ? 'Continuar Borrador JFM'
              : 'Censo Familia Misionera',
        ),
        backgroundColor: const Color(0xFFFF5900),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Guardar borrador',
            onPressed: _guardando
                ? null
                : () => _guardarEnFirebase(estado: 'borrador'),
          ),
        ],
      ),
      body: Column(
        children: [
          _barraEstadoConexion(),
          Expanded(
            child: Stepper(
              currentStep: _pasoActual,
              onStepTapped: (step) => setState(() => _pasoActual = step),
              onStepContinue: () {
                if (_pasoActual < pasosJfm.length - 1) {
                  setState(() => _pasoActual += 1);
                  _guardarEnFirebase(estado: 'borrador');
                } else {
                  _guardarEnFirebase(estado: 'completado');
                }
              },
              onStepCancel: () {
                if (_pasoActual > 0) {
                  setState(() => _pasoActual -= 1);
                }
              },
              controlsBuilder: (context, details) {
                final esUltimoPaso = _pasoActual == pasosJfm.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5900),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _guardando ? null : details.onStepContinue,
                        child: Text(
                            esUltimoPaso ? 'FINALIZAR Y ENVIAR' : 'CONTINUAR'),
                      ),
                      const SizedBox(width: 12),
                      if (_pasoActual > 0)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('ANTERIOR'),
                        ),
                    ],
                  ),
                );
              },
              steps: List.generate(pasosJfm.length, (index) {
                final paso = pasosJfm[index];
                return Step(
                  title: Text(
                    paso.titulo,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  isActive: _pasoActual >= index,
                  content: Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0) _tarjetaEncuestadorActivo(),
                        ...paso.preguntas.map(_construirPregunta),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
