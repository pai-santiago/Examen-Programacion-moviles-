# Red Anáhuac · Censos comunitarios

Aplicación Flutter para levantar el Censo Juventud y Familia Misionera (JFM) y el Diagnóstico Comunitario (CONEVAL), guardar avances en Firestore y consultar reportes desde una vista administrativa web.

## Funciones

- Acceso institucional con Firebase Authentication y recuperación de la sesión.
- Permisos de cuestionarios por perfil (`AMBAS`, `SOLO_JFM` o `SOLO_CONEVAL`).
- Captura y edición de borradores y encuestas completas.
- Fichas JFM y CONEVAL con búsqueda por sede, comunidad y texto.
- Panel administrativo con indicadores, filtros y detalle de cada hogar.

## Ejecutar

Desde esta carpeta:

```powershell
flutter pub get
flutter run -d chrome
```

Para generar el sitio web:

```powershell
flutter build web
```

La configuración de Firebase para las plataformas está en `lib/firebase_options.dart`. Las cuentas deben existir en Firebase Authentication y tener su documento en `users/{uid}`. Un perfil nuevo comienza como `enumerator`; para dar acceso de administrador, asigna `rol: "admin"` desde un proceso autorizado.

## Seguridad y guardado

El rol que muestra Flutter solo controla la interfaz. Configura reglas de Firestore para verificar la autenticación, el propietario de cada encuesta y el rol administrativo; no uses la interfaz como límite de seguridad. Este repositorio no incluye esas reglas.

Los formularios se guardan al pulsar **Guardar** o avanzar al siguiente paso. No hay una cola offline propia: si Firestore no confirma un guardado, la app pide volver a intentarlo.
