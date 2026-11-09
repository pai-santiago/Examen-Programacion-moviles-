import 'package:flutter/material.dart';

String normalizarTextoBusqueda(String texto) => texto
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u');

class FormQuestionLabel extends StatelessWidget {
  final String titulo;

  const FormQuestionLabel({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String sugerencia;
  final InputDecoration decoracion;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.controller,
    required this.sugerencia,
    required this.decoracion,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: decoracion.copyWith(
          hintText: sugerencia,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar búsqueda',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class SearchableDropdownField extends StatelessWidget {
  final String titulo;
  final String sugerencia;
  final String valorActual;
  final List<String> opciones;
  final List<String> coincidencias;
  final TextEditingController controller;
  final InputDecoration decoracion;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSelected;
  final Key? dropdownKey;

  const SearchableDropdownField({
    super.key,
    required this.titulo,
    required this.sugerencia,
    required this.valorActual,
    required this.opciones,
    required this.coincidencias,
    required this.controller,
    required this.decoracion,
    required this.onSearchChanged,
    required this.onSelected,
    this.dropdownKey,
  });

  @override
  Widget build(BuildContext context) {
    final hayBusqueda = controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormQuestionLabel(titulo: titulo),
          SearchField(
            controller: controller,
            sugerencia: sugerencia,
            decoracion: decoracion,
            onChanged: onSearchChanged,
          ),
          if (hayBusqueda)
            if (coincidencias.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'No se encontraron opciones.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF807671)),
                ),
              )
            else
              ...coincidencias.map(
                (opcion) => _SearchSuggestion(
                  opcion: opcion,
                  seleccionado: valorActual == opcion,
                  onTap: () => onSelected(opcion),
                ),
              ),
          DropdownButtonFormField<String>(
            key: dropdownKey,
            initialValue: valorActual,
            isExpanded: true,
            decoration: decoracion,
            items: opciones
                .map(
                  (opcion) => DropdownMenuItem(
                    value: opcion,
                    child: Text(opcion, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (nuevoValor) {
              if (nuevoValor != null) onSelected(nuevoValor);
            },
          ),
        ],
      ),
    );
  }
}

class _SearchSuggestion extends StatelessWidget {
  final String opcion;
  final bool seleccionado;
  final VoidCallback onTap;

  const _SearchSuggestion({
    required this.opcion,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: seleccionado ? const Color(0xFFFF5900) : const Color(0xFFE5E0DD),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: seleccionado ? const Color(0xFFFFF3EC) : Colors.white,
        shape: forma,
        child: InkWell(
          customBorder: forma,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Text(opcion)),
                if (seleccionado)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFF5900),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SurveyProgressBar extends StatelessWidget {
  final int pasoActual;
  final int totalPasos;

  const SurveyProgressBar({
    super.key,
    required this.pasoActual,
    required this.totalPasos,
  });

  @override
  Widget build(BuildContext context) {
    final progreso = totalPasos > 0 ? (pasoActual + 1) / totalPasos : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de la encuesta',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                'Paso ${pasoActual + 1} de $totalPasos',
                style: const TextStyle(fontSize: 12, color: Color(0xFF625B56)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: progreso,
            minHeight: 6,
            backgroundColor: const Color(0xFFFFE1D2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5900)),
          ),
        ],
      ),
    );
  }
}
