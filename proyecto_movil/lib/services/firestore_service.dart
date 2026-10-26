import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Autentica con FirebaseAuth y obtiene/crea el perfil del usuario en la colección 'users'
  Future<Map<String, dynamic>> iniciarSesionYObtenerPerfil({
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'No se pudo obtener la sesión del usuario.',
      );
    }

    final String uid = user.uid;
    final String userEmail = (user.email ?? email).trim();
    final String emailLower = userEmail.toLowerCase();

    final DocumentReference<Map<String, dynamic>> userDocRef =
        _db.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> docSnap =
        await userDocRef.get();

    if (!docSnap.exists || docSnap.data() == null) {
      final bool esAdmin = emailLower.startsWith('admin') ||
          emailLower.startsWith('coordinador');
      final String rolInicial = esAdmin ? 'admin' : 'enumerator';
      const String encuestasPermitidasInicial = 'AMBAS';

      final nuevoPerfil = {
        'uid': uid,
        'email': userEmail,
        'rol': rolInicial,
        'encuestas_permitidas': encuestasPermitidasInicial,
        'fecha_registro': FieldValue.serverTimestamp(),
      };

      await userDocRef.set(nuevoPerfil);

      return {
        'uid': uid,
        'email': userEmail,
        'rol': rolInicial,
        'encuestas_permitidas': encuestasPermitidasInicial,
      };
    }

    final data = docSnap.data()!;
    return {
      'uid': uid,
      'email': (data['email'] ?? userEmail).toString(),
      'rol': (data['rol'] ?? 'enumerator').toString(),
      'encuestas_permitidas': (data['encuestas_permitidas'] ?? 'AMBAS').toString(),
    };
  }

  // Guarda o actualiza cualquier encuesta (Familia Misionera o CONEVAL)
  Future<void> guardarEncuesta({
    required String surveyId,
    required String tipoCuestionario, // 'FAMILIA_MISIONERA' o 'CONEVAL'
    required String sede,
    required String comunidad,
    required String estado, // 'borrador' o 'completado'
    required Map<String, dynamic> respuestas,
    List<Map<String, dynamic>> integrantes = const [],
    Map<String, dynamic>? resultadoPobreza,
  }) async {
    final uid = _auth.currentUser?.uid ?? 'encuestador_anonimo';

    final data = {
      'id': surveyId,
      'tipo_cuestionario': tipoCuestionario,
      'encuestador_id': uid,
      'sede': sede,
      'comunidad': comunidad,
      'estado': estado,
      'fecha_actualizacion': FieldValue.serverTimestamp(),
      'respuestas': respuestas,
      'integrantes': integrantes,
      'resultado_pobreza': resultadoPobreza,
    };

    // SetOptions(merge: true) permite guardar avances (borradores) sin borrar lo anterior
    await _db.collection('surveys').doc(surveyId).set(data, SetOptions(merge: true));
  }

  // Escucha en tiempo real todas las encuestas guardadas en la colección 'surveys'
  Stream<QuerySnapshot> obtenerEncuestas() {
    return _db.collection('surveys').snapshots(includeMetadataChanges: true);
  }

  // Elimina una encuesta o borrador por su ID
  Future<void> eliminarEncuesta(String surveyId) async {
    await _db.collection('surveys').doc(surveyId).delete();
  }
}
