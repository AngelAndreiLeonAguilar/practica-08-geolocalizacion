import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Posibles resultados al intentar leer la ubicación del dispositivo.
enum EstadoUbicacion {
  obtenida,
  servicioDesactivado,
  permisoDenegado,
  permisoDenegadoPermanente,
  error,
}

class ResultadoUbicacion {
  const ResultadoUbicacion(this.estado, {this.posicion, this.detalle});

  final EstadoUbicacion estado;
  final Position? posicion;
  final String? detalle;

  String get mensaje {
    switch (estado) {
      case EstadoUbicacion.obtenida:
        return 'Ubicación obtenida';
      case EstadoUbicacion.servicioDesactivado:
        return 'Activa el servicio de ubicación';
      case EstadoUbicacion.permisoDenegado:
        return 'Permiso de ubicación denegado';
      case EstadoUbicacion.permisoDenegadoPermanente:
        return 'Permiso denegado permanentemente. Habilítalo en Ajustes';
      case EstadoUbicacion.error:
        return 'No se pudo obtener la ubicación${detalle != null ? ': $detalle' : ''}';
    }
  }
}

/// Encapsula Geolocator y url_launcher para poder sustituirlo en pruebas.
class UbicacionService {
  const UbicacionService();

  Future<ResultadoUbicacion> obtenerPosicion() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const ResultadoUbicacion(EstadoUbicacion.servicioDesactivado);
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied) {
        return const ResultadoUbicacion(EstadoUbicacion.permisoDenegado);
      }
      if (permiso == LocationPermission.deniedForever) {
        return const ResultadoUbicacion(
          EstadoUbicacion.permisoDenegadoPermanente,
        );
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return ResultadoUbicacion(EstadoUbicacion.obtenida, posicion: posicion);
    } catch (e) {
      return ResultadoUbicacion(EstadoUbicacion.error, detalle: e.toString());
    }
  }

  /// Distancia en metros entre dos coordenadas.
  double distancia(double lat1, double lon1, double lat2, double lon2) =>
      Geolocator.distanceBetween(lat1, lon1, lat2, lon2);

  Future<bool> abrirAjustes() => Geolocator.openAppSettings();

  Future<bool> abrirServicioUbicacion() => Geolocator.openLocationSettings();

  Future<bool> abrirMapa(double latitud, double longitud) {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Convierte metros a un texto legible (m o km).
String formatearDistancia(double metros) {
  if (metros < 1000) return '${metros.toStringAsFixed(0)} m';
  return '${(metros / 1000).toStringAsFixed(2)} km';
}
