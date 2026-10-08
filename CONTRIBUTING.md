# Guía de contribución

## Flujo de trabajo

```
Issue → Rama → Commits → Pull Request → Revisión → Merge a develop
```

Nadie hace push directo a `main` ni a `develop`.

## Ramas

| Rama | Uso |
|---|---|
| `main` | Versiones estables. Solo recibe merges desde `release/*` al cerrar un sprint. |
| `develop` | Integración. Todas las ramas de trabajo salen de aquí y regresan aquí. |
| `feature/<issue>-<descripcion>` | Nueva funcionalidad. Ej.: `feature/14-pantalla-login` |
| `fix/<issue>-<descripcion>` | Corrección de bug. Ej.: `fix/31-hora-duplicada` |
| `docs/<issue>-<descripcion>` | Solo documentación. |
| `release/<version>` | Preparación de una versión. Ej.: `release/2.0.0-alpha.1` |

## Paso a paso

```bash
# 1. Partir de develop actualizado
git checkout develop
git pull origin develop

# 2. Crear la rama del issue
git checkout -b feature/14-pantalla-login

# 3. Trabajar y hacer commits pequeños
git add .
git commit -m "feat(auth): agregar formulario de inicio de sesión"

# 4. Antes de subir, traer cambios recientes de develop
git pull origin develop

# 5. Verificar
dart format .
flutter analyze
flutter test

# 6. Subir y abrir el PR hacia develop
git push -u origin feature/14-pantalla-login
```

## Commits

Formato: `tipo(alcance): descripción en minúsculas`

| Tipo | Cuándo |
|---|---|
| `feat` | Funcionalidad nueva |
| `fix` | Corrección de bug |
| `refactor` | Cambio de código sin cambiar comportamiento |
| `test` | Agregar o corregir pruebas |
| `docs` | Documentación |
| `style` | Formato, sin cambios de lógica |
| `chore` | Configuración, dependencias, CI |

Ejemplos: `feat(reservas): validar horario ocupado con transacción`, `fix(canchas): corregir filtro por deporte`.

## Pull Requests

- Destino: `develop` (excepto releases).
- Título con el mismo formato de los commits.
- En la descripción incluir `Closes #<número>` para cerrar el issue automáticamente.
- Incluir capturas de pantalla si hay cambios de UI.
- Requiere **1 aprobación** de alguien distinto al autor y que el **CI pase**.
- PRs pequeños: idealmente un issue por PR.
- Se fusiona con **Squash and merge** para mantener un historial limpio en `develop`.
- La rama se elimina después del merge.

## Revisión de código

Quien revisa verifica:
- Que se cumplan los criterios de aceptación del issue.
- Que el código esté en la capa correcta (ver `docs/ARQUITECTURA.md`).
- Que no haya código comentado, prints de depuración ni archivos innecesarios.
- Que la pantalla maneje estados de carga y error.

Los comentarios se hacen sobre el código, no sobre la persona. Si algo no está claro, se pregunta.

## Definición de terminado (Definition of Done)

Un issue está **terminado** cuando:
1. Cumple todos sus criterios de aceptación.
2. Pasa `dart format`, `flutter analyze` y `flutter test` (CI en verde).
3. Tiene al menos una prueba si contiene lógica (providers o repositorios).
4. Si es UI, fue validado contra el diseño de Figma.
5. Está fusionado en `develop`.

## Conflictos de merge

1. `git pull origin develop` en tu rama.
2. Resolver los conflictos en el editor, conservando los cambios de ambos cuando corresponda.
3. Probar que la app compila y corre.
4. Commit y push. Si el conflicto involucra el trabajo de otra persona, coordinar con ella antes.

## Etiquetas de issues

`ui` · `funcionalidad` · `backend` · `bug` · `docs` · `test` · `prioridad-alta` · `bloqueado`
