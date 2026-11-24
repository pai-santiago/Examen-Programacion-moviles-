# Revisión del frontend

**Fecha:** 24 de noviembre de 2026

**Alcance:** acceso y sesión, tablero de encuestadores, captura JFM y CONEVAL, y reportes administrativos.

**Resultado:** mejoras de código aplicadas; la inspección visual en navegador sigue pendiente.

## Hallazgos y cambios

1. **Inicio de sesión y confianza.** La pantalla permitía entrar con perfiles de demostración que evitaban Firebase Auth. Se retiró ese acceso de la interfaz y el guardado ahora exige una sesión autenticada.
2. **Permisos administrativos.** El rol se asignaba por el prefijo del correo. Los perfiles nuevos ahora comienzan como encuestadores; el rol administrador debe asignarse explícitamente en Firestore.
3. **Regreso a la aplicación.** El splash esperaba tres segundos sin comprobar la sesión. Ahora restaura la sesión de Firebase, abre el tablero cuando corresponde y ofrece reintento si no puede recuperar el perfil.
4. **Estados de datos.** El tablero y el panel de reportes podían representar un error de Firestore como si no hubiera encuestas. Ahora distinguen carga, error y datos disponibles y permiten volver a cargar.
5. **Diseño adaptable.** El marco de la aplicación dejaba tablets de 600–899 px limitadas a 430 px. Ahora usa un ancho intermedio; el panel administrativo limita el contenido en pantallas grandes y acomoda sus filtros en dos columnas.
6. **Filtros de reportes.** La búsqueda ignora acentos. “Limpiar búsqueda” ahora vacía también el campo visible y se agregó una acción para restablecer todos los filtros.
7. **Guardado de formularios.** Se retiró el mensaje que afirmaba que los datos quedaban guardados localmente aunque fallara Firestore. La interfaz ahora indica cuándo se guarda y cuándo el formulario sigue pendiente.
8. **Accesibilidad y ayuda.** Se añadieron descripciones a los controles de contraseña y firma y un mensaje cuando el perfil no tiene cuestionarios asignados.

## Límites de la revisión

- Esta sesión no dispone de una herramienta para abrir el producto y capturar sus pantallas. La revisión se hizo sobre el código; no se afirma que sea una auditoría visual terminada.
- No se comprobaron contraste real, navegación completa con teclado, lectores de pantalla ni reflujo al ampliar texto. Hace falta inspeccionar la app ejecutándose en un navegador y en un teléfono.
- No se implementa una cola offline propia. Si Firestore no confirma el guardado, se informa el error y la persona debe volver a guardar.
- No hay reglas de Firestore en este repositorio. La interfaz oculta reportes a perfiles no administradores, pero la protección real de encuestas y roles debe aplicarse también en las reglas del backend.
- El archivo de prueba de widgets existente todavía espera el flujo antiguo de acceso por ID y los perfiles demo; no se ejecutó en esta revisión.
