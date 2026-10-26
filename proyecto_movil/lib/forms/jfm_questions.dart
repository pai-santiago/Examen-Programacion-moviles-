class JfmQuestion {
  final String id;
  final String titulo;
  final String tipo; // 'dropdown', 'chips_multiples', 'texto', 'numero', 'si_no'
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

  const JfmStepConfig({
    required this.titulo,
    required this.preguntas,
  });
}

const Map<String, List<String>> sedesComunidadesJfm = {
  'Anáhuac Cancún': [
    'Leona Vicario',
    'Puerto Morelos',
    'Alfredo V. Bonfil',
    'Kantunilkín',
    'Ignacio Zaragoza',
    'Agua Azul',
    'Tres Reyes',
    'Otra',
  ],
  'Anáhuac México Norte': [
    'San Mateo Tlaltenango',
    'Santa Rosa Xochiac',
    'Jilotzingo',
    'Tlazala',
    'Otra',
  ],
  'Anáhuac México Sur': [
    'San Nicolás Totolapan',
    'Magdalena Petlacalco',
    'Santo Tomás Ajusco',
    'Parres El Guarda',
    'Otra',
  ],
  'Anáhuac Mayab': [
    'Komchén',
    'Cosgaya',
    'Suytunchén',
    'Sierra Papacal',
    'Otra',
  ],
  'Anáhuac Puebla': [
    'San Bernardino Tlaxcalancingo',
    'Santa María Tonantzintla',
    'San Francisco Acatepec',
    'Cuanalá',
    'Otra',
  ],
  'Anáhuac Querétaro': [
    'Chichimequillas',
    'Atongo',
    'San Miguel Amazcala',
    'Tlacote el Bajo',
    'Otra',
  ],
};

Map<String, dynamic> respuestasInicialesJfm(String misioneroEmail) => {
      'rama': 'Familia',
      'sede': 'Anáhuac Cancún',
      'comunidad': 'Leona Vicario',
      'comunidad_otra': '',
      'misionero_aplica': misioneroEmail,
      'referencias_casa': <String>[],
      'direccion_casa': '',
      'apellido_familia': '',
      'num_habitantes': 1,
      'oficio_encargado': 'Ama de casa',
      'estado_civil': 'Casado iglesia',
      'hogar_catolico': 'Si',
      'sacramentos_faltantes': 'No',
      'lista_sacramentos': <String>[],
      'persona_requiere_sacramento': '',
      'interes_parroquia': 'No',
      'lista_actividades_parroquia': <String>[],
      'nombre_interesado': '',
      'telefono_interesado': '',
      'existe_problematica': 'No',
      'lista_problematicas': <String>[],
      'existe_seguimiento': 'No',
      'tipo_seguimiento': 'Visita misioneros',
      'comentarios': '',
    };

const List<JfmStepConfig> pasosJfm = [
  // PASO 1: ENCUESTADOR Y UBICACIÓN
  JfmStepConfig(
    titulo: '1. Encuestador y Ubicación',
    preguntas: [
      JfmQuestion(
        id: 'rama',
        titulo: 'Rama',
        tipo: 'dropdown',
        opciones: [
          'Juventud Femenina',
          'Juventud Masculina',
          'Color',
          'Fuego',
          'Familia',
        ],
      ),
      JfmQuestion(
        id: 'sede',
        titulo: 'Sede',
        tipo: 'dropdown',
        opciones: [
          'Anáhuac Cancún',
          'Anáhuac México Norte',
          'Anáhuac México Sur',
          'Anáhuac Mayab',
          'Anáhuac Puebla',
          'Anáhuac Querétaro',
        ],
      ),
      JfmQuestion(
        id: 'comunidad',
        titulo: 'Comunidad',
        tipo: 'dropdown',
      ),
      JfmQuestion(
        id: 'comunidad_otra',
        titulo: 'Especifica el nombre de la comunidad',
        tipo: 'texto',
        dependeDe: 'comunidad',
        valorEsperado: 'Otra',
      ),
      JfmQuestion(
        id: 'referencias_casa',
        titulo: 'Fachada / Referencias rápidas de la casa',
        tipo: 'chips_multiples',
        opciones: [
          'Casa de block',
          'Casa de madera',
          'Techo de lámina',
          'Color llamativo',
          'Portón/Reja',
          'Cerca de iglesia/escuela',
          'Esquina',
        ],
      ),
      JfmQuestion(
        id: 'direccion_casa',
        titulo: 'Calle, número o referencia adicional (opcional)',
        tipo: 'texto',
      ),
    ],
  ),

  // PASO 2: DEMOGRÁFICOS
  JfmStepConfig(
    titulo: '2. Datos Demográficos',
    preguntas: [
      JfmQuestion(
        id: 'apellido_familia',
        titulo: 'Apellido de la familia encuestada',
        tipo: 'texto',
      ),
      JfmQuestion(
        id: 'num_habitantes',
        titulo: 'Número de habitantes en la casa',
        tipo: 'numero',
      ),
      JfmQuestion(
        id: 'oficio_encargado',
        titulo: 'Oficio de la persona a cargo',
        tipo: 'dropdown',
        opciones: [
          'Ama de casa',
          'Campesino',
          'Comerciante',
          'Servicio doméstico',
          'Albañil',
          'Carpintero',
          'Mecánico',
          'Negocio propio',
          'Otros',
        ],
      ),
      JfmQuestion(
        id: 'estado_civil',
        titulo: 'Estado civil de la persona encuestada',
        tipo: 'dropdown',
        opciones: [
          'Casada civil',
          'Casado iglesia',
          'Viudo',
          'Soltero',
          'Unión libre',
          'Divorciado',
        ],
      ),
    ],
  ),

  // PASO 3: VIDA ESPIRITUAL Y PARROQUIAL
  JfmStepConfig(
    titulo: '3. Vida Espiritual y Parroquial',
    preguntas: [
      JfmQuestion(
        id: 'hogar_catolico',
        titulo: '¿El hogar es católico?',
        tipo: 'si_no',
      ),
      JfmQuestion(
        id: 'sacramentos_faltantes',
        titulo: '¿Tienen sacramentos faltantes?',
        tipo: 'si_no',
      ),
      JfmQuestion(
        id: 'lista_sacramentos',
        titulo: '¿Cuáles sacramentos faltan?',
        tipo: 'chips_multiples',
        dependeDe: 'sacramentos_faltantes',
        valorEsperado: 'Si',
        opciones: [
          'Bautizo',
          'Confirmación',
          'Primera comunión',
          'Unción de los enfermos',
          'Confesión',
          'Matrimonio',
        ],
      ),
      JfmQuestion(
        id: 'persona_requiere_sacramento',
        titulo: 'Persona(s) que requiere(n) el sacramento',
        tipo: 'texto',
        dependeDe: 'sacramentos_faltantes',
        valorEsperado: 'Si',
      ),
      JfmQuestion(
        id: 'interes_parroquia',
        titulo: '¿Interés en participar en la parroquia?',
        tipo: 'si_no',
      ),
      JfmQuestion(
        id: 'lista_actividades_parroquia',
        titulo: '¿En cuáles actividades?',
        tipo: 'chips_multiples',
        dependeDe: 'interes_parroquia',
        valorEsperado: 'Si',
        opciones: [
          'Pastoral familiar',
          'Pastoral Juvenil',
          'Evangelizador de tiempo completo',
          'Aguilas guadalupanas',
          'Catequista',
          'Ministro de la eucaristía',
          'Retiro',
          'CEFAS',
          'Coro',
          'Otro',
        ],
      ),
      JfmQuestion(
        id: 'nombre_interesado',
        titulo: 'Nombre de la persona interesada',
        tipo: 'texto',
        dependeDe: 'interes_parroquia',
        valorEsperado: 'Si',
      ),
      JfmQuestion(
        id: 'telefono_interesado',
        titulo: 'Teléfono',
        tipo: 'texto',
        esTelefono: true,
        dependeDe: 'interes_parroquia',
        valorEsperado: 'Si',
      ),
    ],
  ),

  // PASO 4: PROBLEMÁTICAS SOCIALES
  JfmStepConfig(
    titulo: '4. Problemáticas Sociales',
    preguntas: [
      JfmQuestion(
        id: 'existe_problematica',
        titulo: '¿Existe alguna problemática social en la familia?',
        tipo: 'si_no',
      ),
      JfmQuestion(
        id: 'lista_problematicas',
        titulo: '¿Cuál(es)? (Puedes seleccionar varias)',
        tipo: 'chips_multiples',
        dependeDe: 'existe_problematica',
        valorEsperado: 'Si',
        opciones: [
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
        ],
      ),
    ],
  ),

  // PASO 5: SEGUIMIENTO Y COMENTARIOS
  JfmStepConfig(
    titulo: '5. Seguimiento',
    preguntas: [
      JfmQuestion(
        id: 'existe_seguimiento',
        titulo: '¿Existen acciones para dar seguimiento?',
        tipo: 'si_no',
      ),
      JfmQuestion(
        id: 'tipo_seguimiento',
        titulo: '¿Cuál acción?',
        tipo: 'dropdown',
        dependeDe: 'existe_seguimiento',
        valorEsperado: 'Si',
        opciones: [
          'Visita sacerdotal',
          'Visita médica',
          'Visita misioneros',
          'Seguimiento sacramento',
          'Seguimiento vida parroquial',
          'Otro',
        ],
      ),
      JfmQuestion(
        id: 'comentarios',
        titulo: 'Comentarios u observaciones',
        tipo: 'texto',
        maxLines: 3,
      ),
    ],
  ),
];
