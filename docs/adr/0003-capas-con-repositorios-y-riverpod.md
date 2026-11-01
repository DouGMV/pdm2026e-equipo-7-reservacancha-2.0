# ADR 0003: pantallas sin Firebase, con repositorios y Riverpod

**Estado:** aceptada. Base del proyecto (ver `docs/ARQUITECTURA.md` y `docs/TECNOLOGIAS.md`).

## Contexto

Cinco personas trabajan a la vez en la misma app, y cada una se encarga de una capa. Necesitábamos avanzar sin esperarnos entre capas y probar las pantallas sin depender de Firebase.

## Decisión

Cada funcionalidad se separa en tres capas:

| Capa | Contiene | Regla |
|---|---|---|
| `presentation` | Pantallas y providers | No importa Firebase. |
| `domain` | Entidades y contratos de repositorios | Dart puro. |
| `data` | Modelos e implementación de los repositorios | Único lugar donde se usa Firebase. |

Un dato viaja así: la pantalla hace `ref.watch` de un provider, el provider llama al contrato del repositorio y la implementación habla con Firestore. Los providers exponen `AsyncValue`, y la pantalla muestra carga, error o datos.

Usamos `flutter_riverpod` para el estado y para inyectar el repositorio: en la app el provider entrega la implementación de Firestore, y en las pruebas se sustituye con un `override`.

## Alternativas descartadas

- **Usar Firestore directamente en las pantallas:** es menos código al inicio, pero no se puede probar una pantalla sin Firebase y cada cambio de datos toca la interfaz.
- **`setState` y pasar datos por constructores:** la sesión, la pestaña activa y los filtros se usan en varias pantallas, y habría que pasarlos por todos los widgets intermedios.

## Consecuencias

- Las pantallas se prueban con repositorios falsos, sin conexión y en el CI.
- Cambiar la implementación de datos solo toca `data/` y el provider del repositorio.
- Hay más archivos por funcionalidad.
- Cada método nuevo en un contrato obliga a actualizar las implementaciones. Por eso los repositorios de prueba usan `extends Fake implements ...`.
