# Roles y responsabilidades

Cada integrante es responsable de un área de la app. Además de su rol principal, todos escriben las pruebas de su propio código y revisan PRs de sus compañeros.

## Roles del equipo

### Douglas Morales — Arquitectura / Líder técnico
- Define y mantiene la arquitectura y la estructura base del proyecto (carpetas, router, providers base, `analysis_options.yaml`).
- Revisa los avances de cada integrante y aprueba los PRs antes de fusionarlos a `develop`.
- Realiza correcciones y brinda retroalimentación sobre el código.
- Mantiene el workflow de CI y aprueba la incorporación de paquetes nuevos al `pubspec.yaml`.
- Organiza el backlog, los milestones y el tablero de GitHub Projects.
- Gestiona las ramas `release/*`, los tags de versión y la publicación de APK en Releases.

### Nathaly Reyes — Base de datos / Apoyo backend
- Crea y administra el proyecto de Firebase y agrega al equipo como miembros.
- Diseña e implementa la base de datos en Firestore: colecciones, campos e índices (ver `ARQUITECTURA.md`).
- Escribe y mantiene las reglas de seguridad (`firestore.rules`).
- Carga los datos de prueba: canchas y usuario administrador.
- Apoya a Julian en el desarrollo de la capa de datos y en las consultas complejas.

### Julian Eduardo — Desarrollo del backend
- Implementa la capa `data` de cada funcionalidad: modelos (`fromMap` / `toMap`), datasources y repositorios.
- Implementa la autenticación con Firebase Auth (registro, inicio y cierre de sesión).
- Implementa la creación de reservas con transacción para evitar horarios duplicados, y la cancelación.
- Define los contratos de los repositorios en `domain` junto con Angel.
- Escribe pruebas unitarias de los repositorios.

### Angel Ovalle — Lógica del frontend
- Implementa los providers y Notifiers de Riverpod que conectan las pantallas con los repositorios.
- Implementa la navegación con `go_router`, incluyendo las redirecciones por sesión y por rol (cliente/admin).
- Implementa validaciones de formularios, cálculo de disponibilidad de horarios y manejo de estados (carga, error, datos).
- Escribe pruebas unitarias de los providers.

### Marco Bolaños — Desarrollo del frontend UI
- Diseña las pantallas (wireframes en Figma) y define la guía visual: colores, tipografía y componentes.
- Implementa el tema (`core/theme`) y los widgets reutilizables (`core/widgets`).
- Construye todas las pantallas de la app a partir del diseño, consumiendo los providers de Angel.
- Escribe pruebas de widgets de las pantallas.

## Cómo se conectan los roles

```
Marco (pantallas) → Angel (providers / lógica) → Julian (repositorios) → Nathaly (Firestore)
                         ↑ Douglas define la estructura y revisa cada capa ↑
```

Para no bloquearse entre capas:
- Al inicio de cada funcionalidad, Julian y Angel acuerdan el **contrato del repositorio** (la clase abstracta en `domain`). Con eso, Angel puede avanzar usando un repositorio simulado mientras Julian implementa el real.
- Marco puede construir las pantallas con datos de ejemplo mientras los providers están en desarrollo.

## Reglas de colaboración
- Todo PR requiere la aprobación de Douglas o, si Douglas es el autor, de otro integrante.
- Ningún integrante trabaja directamente en `main` ni en `develop`.
- Si un issue se bloquea más de un día, se avisa en el grupo y se marca con la etiqueta `bloqueado`.

## Asignación propuesta por sprint

| Sprint | Douglas | Nathaly | Julian | Angel | Marco |
|---|---|---|---|---|---|
| 0 – Preparación | Estructura base, CI, tablero y milestones | Proyecto Firebase y modelo de datos | Contratos de repositorios de auth | Configuración de Riverpod y router | Wireframes y guía visual |
| 1 – Auth y canchas | Revisión y correcciones | Colección `usuarios` y reglas iniciales | Repositorio de auth y de canchas | Providers de auth, redirección por sesión | Pantallas de login, registro y listado |
| 2 – Reservar | Revisión y correcciones | Colección `reservas` e índice de disponibilidad | Creación de reserva con transacción | Cálculo de horarios disponibles | Detalle de cancha y selección de horario |
| 3 – Mis reservas | Revisión y correcciones | Ajuste de reglas para cancelación | Consulta y cancelación de reservas | Providers de mis reservas y perfil | Pantallas de mis reservas y perfil |
| 4 – Administración | Revisión y correcciones | Reglas de admin y datos de prueba | Repositorios de administración | Redirección por rol y lógica admin | Pantallas de administración |
| 5 – Release | Release `v2.0.0` y documentación final | Corrección de bugs | Corrección de bugs | Corrección de bugs | Pulido visual y capturas para README |

La asignación se ajusta en cada planificación de sprint según el avance real.
