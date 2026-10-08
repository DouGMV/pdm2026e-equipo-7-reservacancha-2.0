import 'package:flutter/material.dart';

class DetalleCanchaScreen extends StatelessWidget {
  const DetalleCanchaScreen({super.key, required this.canchaId});

  final String canchaId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Detalle de cancha $canchaId')));
  }
}
