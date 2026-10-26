import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../forms/jfm_questions.dart';
import '../main.dart';
import '../services/firestore_service.dart';

class ConevalScreen extends StatefulWidget {
  final String? surveyIdExistente;
  final Map<String, dynamic>? respuestasExistentes;
  final String? usuarioEmail;

  const ConevalScreen({
    super.key,
    this.surveyIdExistente,
    this.respuestasExistentes,
    this.usuarioEmail,
  });

  @override
  State<ConevalScreen> createState() => _ConevalScreenState();
}

class _ConevalScreenState extends State<ConevalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late final String _surveyId;
  late final String _encuestadorEmail;
  bool _guardando = false;

  late String _sede;
  late String _comunidad;
  late String _carenciaAlimentaria;
  late String _serviciosBasicos;

  late final TextEditingController _apellidoCtrl;
  late final TextEditingController _habitantesCtrl;
  late final TextEditingController _ingresoCtrl;
  late final TextEditingController _observacionesCtrl;

  static const InputDecoration _decoracionCampo = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  );

  @override
  void initState() {
    super.initState();
    _surveyId = widget.surveyIdExistente ??
        'coneval_${DateTime.now().millisecondsSinceEpoch}';
    _encuestadorEmail = widget.usuarioEmail ??
        FirebaseAuth.instance.currentUser?.email ??
        'misionero_demo@anahuac.mx';

    final prev = widget.respuestasExistentes ?? {};
    final sedesDisponibles = sedesComunidadesJfm.keys.toList();
    final sedePrev = prev['sede']?.toString() ?? 'Anáhuac Cancún';
    _sede = sedesDisponibles.contains(sedePrev) ? sedePrev : sedesDisponibles.first;

    final comunidadesSede = sedesComunidadesJfm[_sede] ?? const ['Otra'];
    final comPrev = prev['comunidad']?.toString() ?? comunidadesSede.first;
    _comunidad = comunidadesSede.contains(comPrev) ? comPrev : comunidadesSede.first;

    _carenciaAlimentaria =
        ['Si', 'No'].contains(prev['carencia_alimentaria'])
            ? prev['carencia_alimentaria']
            : 'No';
    _serviciosBasicos =
        ['Completos', 'Incompletos'].contains(prev['servicios_basicos'])
            ? prev['servicios_basicos']
            : 'Completos';

    _apellidoCtrl = TextEditingController(
        text: prev['apellido_familia']?.toString() ?? '');
    _habitantesCtrl = TextEditingController(
        text: (prev['num_habitantes'] ?? '1').toString());
    _ingresoCtrl = TextEditingController(
        text: prev['ingreso_mensual']?.toString() ?? '');
    _observacionesCtrl = TextEditingController(
        text: prev['comentarios']?.toString() ?? '');
  }

  @override
  void dispose() {
    _apellidoCtrl.dispose();
    _habitantesCtrl.dispose();
    _ingresoCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _guardar({required String estado}) async {
    setState(() => _guardando = true);
    try {
      final respuestas = {
        'sede': _sede,
        'comunidad': _comunidad,
        'misionero_aplica': _encuestadorEmail,
        'apellido_familia': _apellidoCtrl.text.trim(),
        'num_habitantes': int.tryParse(_habitantesCtrl.text.trim()) ?? 1,
        'ingreso_mensual': _ingresoCtrl.text.trim(),
        'carencia_alimentaria': _carenciaAlimentaria,
        'servicios_basicos': _serviciosBasicos,
        'comentarios': _observacionesCtrl.text.trim(),
      };

      await _firestoreService.guardarEncuesta(
        surveyId: _surveyId,
        tipoCuestionario: 'CONEVAL',
        sede: _sede,
        comunidad: _comunidad,
        estado: estado,
        respuestas: respuestas,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(estado == 'completado'
              ? '¡Diagnóstico CONEVAL finalizado y enviado!'
              : 'Borrador CONEVAL autoguardado'),
          backgroundColor: Colors.green.shade700,
        ),
      );

      if (estado == 'completado') {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar CONEVAL: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comunidades = sedesComunidadesJfm[_sede] ?? const ['Otra'];
    final valorComunidad =
        comunidades.contains(_comunidad) ? _comunidad : comunidades.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico CONEVAL'),
        backgroundColor: red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Guardar borrador',
            onPressed:
                _guardando ? null : () => _guardar(estado: 'borrador'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0F1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cuestionario CONEVAL · Encuestador: $_encuestadorEmail',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _etiquetaPregunta('Sede'),
            DropdownButtonFormField<String>(
              key: ValueKey('coneval_sede_$_sede'),
              initialValue: _sede,
              isExpanded: true,
              decoration: _decoracionCampo,
              items: sedesComunidadesJfm.keys
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
                  _sede = v;
                  _comunidad =
                      (sedesComunidadesJfm[v] ?? const ['Otra']).first;
                });
              },
            ),
            const SizedBox(height: 16),

            _etiquetaPregunta('Comunidad'),
            DropdownButtonFormField<String>(
              key: ValueKey('coneval_com_${_sede}_$valorComunidad'),
              initialValue: valorComunidad,
              isExpanded: true,
              decoration: _decoracionCampo,
              items: comunidades
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _comunidad = v);
              },
            ),
            const SizedBox(height: 16),

            _etiquetaPregunta('Apellido de la familia encuestada'),
            TextFormField(
              controller: _apellidoCtrl,
              decoration: _decoracionCampo.copyWith(
                hintText: 'Ej. Hernández López',
              ),
            ),
            const SizedBox(height: 16),

            _etiquetaPregunta('Número de integrantes del hogar'),
            TextFormField(
              controller: _habitantesCtrl,
              keyboardType: TextInputType.number,
              decoration: _decoracionCampo,
            ),
            const SizedBox(height: 16),

            _etiquetaPregunta('Ingreso mensual estimado del hogar (\$ MXN)'),
            TextFormField(
              controller: _ingresoCtrl,
              keyboardType: TextInputType.number,
              decoration: _decoracionCampo.copyWith(
                hintText: 'Ej. 6500',
              ),
            ),
            const SizedBox(height: 16),

            _etiquetaPregunta(
                '¿Presenta carencia por acceso a la alimentación?'),
            DropdownButtonFormField<String>(
              key: ValueKey('coneval_alim_$_carenciaAlimentaria'),
              initialValue: _carenciaAlimentaria,
              isExpanded: true,
              decoration: _decoracionCampo,
              items: const ['Si', 'No']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _carenciaAlimentaria = v);
              },
            ),
            const SizedBox(height: 16),

            _etiquetaPregunta('Acceso a servicios básicos en la vivienda'),
            DropdownButtonFormField<String>(
              key: ValueKey('coneval_serv_$_serviciosBasicos'),
              initialValue: _serviciosBasicos,
              isExpanded: true,
              decoration: _decoracionCampo,
              items: const ['Completos', 'Incompletos']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _serviciosBasicos = v);
              },
            ),
            const SizedBox(height: 16),

            _etiquetaPregunta('Observaciones del diagnóstico comunitario'),
            TextFormField(
              controller: _observacionesCtrl,
              maxLines: 3,
              decoration: _decoracionCampo.copyWith(
                hintText: 'Comentarios adicionales...',
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _guardando
                        ? null
                        : () => _guardar(estado: 'borrador'),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar Borrador'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _guardando
                        ? null
                        : () => _guardar(estado: 'completado'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Finalizar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
