import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/ubicacion_service.dart';

/// Ejemplo guiado: obtener la ubicación actual y abrirla en el mapa.
class UbicacionPage extends StatefulWidget {
  const UbicacionPage({super.key, this.servicio = const UbicacionService()});

  final UbicacionService servicio;

  @override
  State<UbicacionPage> createState() => _UbicacionPageState();
}

class _UbicacionPageState extends State<UbicacionPage> {
  Position? posicion;
  EstadoUbicacion? estado;
  String mensaje = 'Sin ubicación';
  bool cargando = false;

  Future<void> obtener() async {
    setState(() => cargando = true);
    final resultado = await widget.servicio.obtenerPosicion();
    if (!mounted) return;
    setState(() {
      cargando = false;
      estado = resultado.estado;
      mensaje = resultado.mensaje;
      if (resultado.posicion != null) posicion = resultado.posicion;
    });
  }

  Future<void> abrirMapa() async {
    if (posicion == null) return;
    final ok = await widget.servicio.abrirMapa(
      posicion!.latitude,
      posicion!.longitude,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo abrir el mapa')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 80),
            const SizedBox(height: 8),
            Text(mensaje, textAlign: TextAlign.center),
            if (posicion != null) ...[
              const SizedBox(height: 12),
              Text('Latitud: ${posicion!.latitude.toStringAsFixed(6)}'),
              Text('Longitud: ${posicion!.longitude.toStringAsFixed(6)}'),
              Text('Precisión: ${posicion!.accuracy.toStringAsFixed(1)} m'),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: cargando ? null : obtener,
              icon: cargando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Obtener ubicación'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: posicion == null ? null : abrirMapa,
              icon: const Icon(Icons.map),
              label: const Text('Abrir en mapa'),
            ),
            if (estado == EstadoUbicacion.permisoDenegadoPermanente)
              TextButton(
                onPressed: widget.servicio.abrirAjustes,
                child: const Text('Abrir ajustes de la app'),
              ),
            if (estado == EstadoUbicacion.servicioDesactivado)
              TextButton(
                onPressed: widget.servicio.abrirServicioUbicacion,
                child: const Text('Activar ubicación'),
              ),
          ],
        ),
      ),
    );
  }
}
