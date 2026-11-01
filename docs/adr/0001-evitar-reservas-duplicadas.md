# ADR 0001: evitar reservas duplicadas con id fijo y transacción

**Estado:** aceptada. Implementada en el #53.

## Contexto

El problema central de la app es que dos personas no pueden reservar la misma cancha a la misma hora. Puede pasar aunque la app muestre el horario libre: dos clientes abren el detalle, ven las 18:00 disponibles y confirman casi a la vez.

Firestore no tiene restricciones `UNIQUE` como una base SQL, así que la regla hay que construirla.

## Decisión

1. El id de la reserva no es aleatorio: es `{canchaId}_{yyyyMMdd}_{HH}`, por ejemplo `abc123_20261015_18`. Solo puede existir un documento por cancha, fecha y hora.
2. `ReservasRepositoryFirestore.crearReserva` escribe dentro de una **transacción**:
   - lee el documento con ese id;
   - si está `confirmada`, lanza `ReservaNoDisponibleException` ("Horario no disponible");
   - si no existe o está `cancelada`, escribe la reserva como `confirmada`.

Si dos clientes confirman a la vez, Firestore repite la transacción del segundo. Esa repetición ya encuentra el horario confirmado, y falla.

## Alternativas descartadas

- **Consultar primero y crear con id aleatorio:** entre la consulta y la escritura hay un momento en que otro cliente puede reservar. Quedarían dos reservas del mismo horario.
- **Confiar en que la pantalla muestra los horarios libres:** esa información puede estar vieja cuando el usuario confirma.

## Consecuencias

- La regla vive en los datos, no en la pantalla: se cumple aunque la lista de horarios esté desactualizada.
- Se puede probar con `fake_cloud_firestore` sin Firebase real (`reservas_repository_firestore_test.dart`).
- Si se reserva de nuevo un horario cancelado, se reemplaza el mismo documento: se pierde el registro de esa cancelación anterior.
- Las reglas de `firestore.rules` tienen que permitir pasar de `cancelada` a `confirmada`.
- La transacción necesita conexión: sin internet, la reserva falla y la pantalla lo avisa.
