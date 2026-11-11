import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Autentica con FirebaseAuth y obtiene/crea el perfil tipado (UserModel) en la colección 'users'
  Future<UserModel> iniciarSesionYObtenerPerfil({
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

    final DocumentReference<Map<String, dynamic>> userDocRef =
        _db.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> docSnap =
        await userDocRef.get();

    if (!docSnap.exists || docSnap.data() == null) {
      final nuevoUsuario = UserModel.nuevoPerfil(
        uid: uid,
        email: userEmail,
      );

      await userDocRef.set({
        ...nuevoUsuario.toMap(),
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      return nuevoUsuario;
    }

    return UserModel.fromMap(
      docSnap.data()!,
      uidFallback: uid,
      emailFallback: userEmail,
    );
  }

  // Guarda o actualiza cualquier encuesta (Familia Misionera o CONEVAL)
  Future<void> guardarEncuesta({
    required String surveyId,
    required String tipoCuestionario, // 'FAMILIA_MISIONERA' o 'CONEVAL'
    required String sede,
    required String comunidad,
    required String estado, // 'borrador' o 'completado'
    required Map<String, dynamic> respuestas,
    String? encuestadorUid,
    List<Map<String, dynamic>> integrantes = const [],
    Map<String, dynamic>? resultadoPobreza,
  }) async {
    final uid = encuestadorUid?.isNotEmpty == true
        ? encuestadorUid!
        : _auth.currentUser?.uid ?? 'encuestador_anonimo';

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
