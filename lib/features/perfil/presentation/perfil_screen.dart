import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/router/app_router.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Nombre'),
            subtitle: Text('Ana López'),
          ),
          const ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text('Correo'),
            subtitle: Text('ana@correo.com'),
          ),
          const ListTile(
            leading: Icon(Icons.badge_outlined),
            title: Text('Rol'),
            subtitle: Text('Cliente'),
          ),
          const Divider(),
          // Las secciones que todavía no existen avisan al usuario en vez de
          // dejar un botón que no hace nada.
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Notificaciones'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.push(AppRoutes.proximamenteDe('Notificaciones')),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}
