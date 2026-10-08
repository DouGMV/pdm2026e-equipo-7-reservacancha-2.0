# Plan de desarrollo

Desarrollo iterativo en sprints de **1 a 2 semanas**. Cada sprint es un **Milestone** en GitHub y entrega funcionalidades completas (UI + lógica + pruebas), no capas sueltas.

## Fases

### Fase 0 — Preparación (Sprint 0)
- Configurar el repositorio: ramas `main` y `develop`, protección de ramas, etiquetas, tablero en GitHub Projects, milestones.
- Crear el proyecto Flutter con la estructura de `ARQUITECTURA.md` y el CI funcionando.
- Crear el proyecto de Firebase y conectar la app.
- Todos clonan el repo, ejecutan la app y hacen un primer PR de prueba (por ejemplo, agregar su nombre a un archivo) para practicar el flujo.

### Fase 1 — Requisitos y alcance
- Redactar historias de usuario con criterios de aceptación para cada pantalla.
- Separar el **MVP** de los extras.
- Decidir qué se reutiliza de la versión 1 y qué se rehace.

### Fase 2 — Diseño
- Wireframes y prototipo en Figma de las pantallas del MVP.
- Guía visual: colores, tipografía, componentes.
- Modelo de datos y reglas de seguridad iniciales.

Las fases 1 y 2 se trabajan en paralelo con la Fase 0.

### Fase 3 — Sprints de desarrollo

| Sprint | Objetivo | Entregable |
|---|---|---|
| 1 | Registro, inicio de sesión, navegación protegida, listado de canchas | `v2.0.0-alpha.1` |
| 2 | Detalle de cancha, disponibilidad por fecha y crear reserva | `v2.0.0-alpha.2` |
| 3 | Mis reservas, cancelación, perfil | `v2.0.0-alpha.3` |
| 4 | Módulo de administración | `v2.0.0-beta.1` |

Cada sprint sigue este ciclo:
1. **Planificación:** se eligen issues del backlog y se asignan.
2. **Desarrollo:** issue → rama → PR → revisión → merge a `develop`.
3. **Revisión (demo):** se prueba lo terminado contra los criterios de aceptación.
4. **Retrospectiva:** qué funcionó, qué no y qué se cambia.
5. **Rediseño:** lo que no cumplió se convierte en issues para el siguiente sprint.
6. **Release:** `develop` → `release/<version>` → `main` con su tag.

### Fase 4 — Estabilización y entrega
- Rama `release/2.0.0`: solo corrección de bugs.
- Pruebas completas en dispositivos reales.
- README final con capturas, APK en GitHub Releases, tag `v2.0.0`.
- Presentación final.

## MVP vs extras

**MVP:** registro/login, listado de canchas, disponibilidad por fecha, crear reserva sin duplicados, mis reservas, cancelar, perfil, administración básica de canchas.

**Extras (si hay tiempo):** notificaciones, reservas de varias horas, calificaciones de canchas, mapa de ubicación, modo oscuro, iOS.

## Trazabilidad

- Todo trabajo tiene un issue asignado a un milestone.
- Cada rama incluye el número de issue; cada PR lo cierra con `Closes #n`.
- Cada sprint cerrado genera un tag y una release.
- Evidencia de avance: tablero de Projects, milestones, historial de PRs e Insights → Contributors.
