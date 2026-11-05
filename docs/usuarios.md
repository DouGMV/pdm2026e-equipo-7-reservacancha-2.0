# Pruebas con usuarios

Tres personas probaron un **prototipo navegable** del MVP en un teléfono, antes de programar las pantallas en Flutter (informe del 19 de octubre de 2026). Todavía no se ha repetido la prueba con la app final contra el Firebase real.

## Resultado general

- **Tareas de cliente:** crear cuenta, encontrar una cancha y su precio, reservar y cancelar. Las 4 se completaron en las 3 sesiones.
- **Satisfacción:** 3.7 de 5 (dos participantes dieron 4 y uno dio 3).
- **Tareas de administrador:** las recorrió el facilitador, integrante del equipo. Es una revisión interna, no una prueba con usuarios.

**Limitaciones:** con tres personas los resultados muestran tendencias. Las sesiones usaron un registro automático de toques y tiempos, así que no hay frases textuales de los participantes ni se anotó quién dio cada calificación.

## Resultados

### Persona 1 (D. A.)

- **Quién es:** participante en el rol de cliente.
- **Dispositivo:** prototipo en un teléfono.
- **Qué intentó:** creó su cuenta (41 s), encontró Cancha Sintética 1 a Q150.00 por hora, reservó (20 s) y canceló una reserva (3 s).
- **Qué falló o le costó:** tocó la palabra "Libre" de la leyenda de horarios y un espacio vacío, que no hacen nada, antes de elegir la hora.

### Persona 2 (D. G.)

- **Quién es:** participante en el rol de cliente.
- **Dispositivo:** prototipo en un teléfono.
- **Qué intentó:** creó su cuenta (27 s), encontró Cancha Sintética 1 a Q150.00 por hora, reservó (16 s), canceló una reserva (2 s) y probó los cinco filtros de deporte.
- **Qué falló o le costó:** no tuvo errores. Confirmó la reserva en 1 segundo, casi sin revisar la pantalla de confirmación.

### Persona 3 (D. M.)

- **Quién es:** participante en el rol de cliente.
- **Dispositivo:** prototipo en un teléfono.
- **Qué intentó:** creó su cuenta (46 s), usó el filtro Básquetbol, encontró Duela Techada a Q120.00 por hora, reservó (8 s) y canceló una reserva (2 s).
- **Qué falló o le costó:** tocó primero el campo de correo del inicio de sesión antes de encontrar Crear cuenta.

## Problemas y estado en la app

| Hallazgo | Gravedad | Origen | Estado en la app | PR |
|---|---|---|---|---|
| La leyenda de horarios parecía un botón | Media | Persona 1 | **Resuelto:** no hay leyenda; las horas ocupadas y pasadas salen deshabilitadas | #53 |
| Las opciones de administración eran difíciles de encontrar | Media | Facilitador | **Resuelto:** tienen su propia pestaña Admin, visible solo para ese rol | #33, #45 |
| La pantalla de confirmación casi no se revisa (1 a 6 s) | Media | Personas 1, 2 y 3 | **Parcial:** muestra el día completo y el bloque de hora, pero no van primero ni en letra grande | #53 |
| Las acciones del administrador no advertían ni se podían deshacer | Alta | Facilitador | **Parcial:** una cancha con reservas no se puede borrar, y eliminar tiene Deshacer. Desactivar una cancha con reservas próximas todavía no avisa | #34, #37, #69 |
| El enlace Crear cuenta destaca poco | Baja | Persona 3 | **Pendiente:** sigue siendo un enlace de texto | |

## Qué cambiamos por lo que observamos

_Pendiente: elegir el cambio que se muestra en la demo._

## Para la próxima prueba

1. Instalar el APK en un teléfono, con las canchas de prueba ya limpias en Firestore.
2. Dar tareas concretas (cancha, día y hora) sin explicar cómo se hacen.
3. Pedir a la persona que piense en voz alta y anotar lo que dice.
4. Anotar quién da cada calificación y por qué.
5. Por cada problema real, abrir un issue y un PR, y anotar aquí el número.
