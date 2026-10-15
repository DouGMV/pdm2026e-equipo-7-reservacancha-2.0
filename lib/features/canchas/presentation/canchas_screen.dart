import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';

/// Pantalla de listado de canchas con estados de carga, error, vacío y datos.
/// Usa [AsyncValue.when] según lo solicitado en el laboratorio.
class CanchasScreen extends ConsumerWidget {
  const CanchasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canchas = ref.watch(canchasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Canchas')),
      body: canchas.when(
        data: (lista) {
          if (lista.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sports_soccer, size: 80),
                  const SizedBox(height: 16),
                  const Text('No hay canchas disponibles'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(canchasProvider),
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = lista[index];
              return Card(
                child: ListTile(
                  title: Text(c.nombre),
                  subtitle: Text('${c.deporte} • Q${c.precioPorHora}/hora'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Ocurrió un error al cargar las canchas.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(canchasProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
