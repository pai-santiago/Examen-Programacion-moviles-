/// Modelo de datos que representa el perfil y permisos de un usuario autenticado.
///
/// Separa la estructura de datos del usuario de la capa de interfaz (`screens`)
/// y de la capa de base de datos (`services`).
class UserModel {
  final String uid;
  final String email;
  final String rol; // 'enumerator' o 'admin'
  final String encuestasPermitidas; // 'AMBAS', 'SOLO_JFM', 'SOLO_CONEVAL'

  const UserModel({
    required this.uid,
    required this.email,
    this.rol = 'enumerator',
    this.encuestasPermitidas = 'AMBAS',
  });

  /// Indica si el usuario tiene privilegios de administrador.
  bool get esAdmin => rol == 'admin';

  /// Indica si el usuario tiene permiso para aplicar el censo Familia Misionera.
  bool get permiteJfm =>
      encuestasPermitidas == 'AMBAS' || encuestasPermitidas == 'SOLO_JFM';

  /// Indica si el usuario tiene permiso para aplicar el diagnóstico CONEVAL.
  bool get permiteConeval =>
      encuestasPermitidas == 'AMBAS' || encuestasPermitidas == 'SOLO_CONEVAL';

  /// Iniciales para mostrar en el avatar del encabezado.
  String get inicialesRol => esAdmin ? 'AD' : 'EN';

  /// Etiqueta legible del rol activo.
  String get tituloRol => esAdmin ? 'Administrador JFM' : 'Encuestador Activo';

  /// Normaliza el identificador ingresado en el login agregando el dominio institucional si falta.
  static String normalizarCorreo(String entrada) {
    final limpio = entrada.trim();
    return limpio.contains('@') ? limpio : '$limpio@anahuac.mx';
  }

  /// Crea un perfil inicial de encuestador cuando la cuenta aún no tiene perfil.
  /// Los permisos de administrador se asignan explícitamente en Firestore.
  factory UserModel.nuevoPerfil({required String uid, required String email}) {
    final emailLimpio = email.trim();
    return UserModel(
      uid: uid,
      email: emailLimpio,
      rol: 'enumerator',
      encuestasPermitidas: 'AMBAS',
    );
  }

  /// Construye una instancia de [UserModel] a partir de un mapa proveniente de Firestore.
  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    String? uidFallback,
    String? emailFallback,
  }) {
    return UserModel(
      uid: (map['uid'] ?? uidFallback ?? '').toString(),
      email: (map['email'] ?? emailFallback ?? 'Sin correo registrado')
          .toString()
          .trim(),
      rol: (map['rol'] ?? 'enumerator').toString(),
      encuestasPermitidas: (map['encuestas_permitidas'] ?? 'AMBAS').toString(),
    );
  }

  /// Convierte la instancia de [UserModel] a un mapa clave-valor para guardarse en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'rol': rol,
      'encuestas_permitidas': encuestasPermitidas,
    };
  }
}
