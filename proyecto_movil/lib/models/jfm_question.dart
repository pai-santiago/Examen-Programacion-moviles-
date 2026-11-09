class JfmQuestion {
  final String id;
  final String titulo;
  final String tipo; // dropdown, chips_multiples, texto, numero o si_no
  final List<String> opciones;
  final String? dependeDe;
  final dynamic valorEsperado;
  final int maxLines;
  final bool esTelefono;

  const JfmQuestion({
    required this.id,
    required this.titulo,
    required this.tipo,
    this.opciones = const [],
    this.dependeDe,
    this.valorEsperado,
    this.maxLines = 1,
    this.esTelefono = false,
  });
}

class JfmStepConfig {
  final String titulo;
  final List<JfmQuestion> preguntas;

  const JfmStepConfig({required this.titulo, required this.preguntas});
}
