# ADR 0002: migraciones con una versión de esquema en Firestore

**Estado:** aceptada. Implementada en el #68 (issue #62).

## Contexto

El curso pide que los cambios a la base estén en migraciones probadas. Firestore no tiene `onUpgrade` como SQLite: no hay un esquema ni un número de versión.

Para el nombre único de las canchas (#61) necesitábamos consultar un campo nuevo, `nombreNormalizado`. Las canchas que ya estaban guardadas no lo tenían, así que una consulta no las encontraría y permitiría repetir sus nombres.

## Decisión

- La versión de la base se guarda en el documento `config/esquema` (`{version: 2}`). Si no existe, la base está en la versión 1.
- `MigradorEsquema.migrar()` lee la versión, aplica en orden los pasos pendientes y guarda la versión nueva en el mismo `WriteBatch`.
- Cada paso es idempotente: el paso 1 → 2 salta las canchas que ya tienen `nombreNormalizado`.
- Corre en segundo plano cuando inicia sesión un **admin**, porque `firestore.rules` no deja a un cliente escribir en `canchas/`.
- Nunca se edita un paso publicado: un cambio nuevo es un paso nuevo.

## Alternativas descartadas

- **Calcular el campo solo al guardar:** las canchas que nadie edite nunca lo tendrían, y el nombre único fallaría justo con esas.
- **Revisar el nombre leyendo todas las canchas en la app:** evita migrar, pero cada guardado tendría que descargar la colección completa.
- **Migrar con Cloud Functions:** requiere el plan de pago de Firebase, y usamos el plan Spark.

## Consecuencias

- `migrador_esquema_test.dart` crea una base en versión 1 con datos y comprueba que los datos siguen iguales, que existe el campo nuevo y que migrar otra vez no cambia nada.
- Hasta que entre un admin, la base sigue en la versión anterior. Si la app falla al migrar, sigue funcionando y lo intenta en el siguiente inicio de sesión.
- Firestore limita cada solicitud a 10 MiB, así que una colección muy grande no cabe en un solo `WriteBatch`. El issue #79 divide el paso en lotes.
