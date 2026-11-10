import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:puntos_interes/main.dart';
import 'package:puntos_interes/models/punto_interes.dart';
import 'package:puntos_interes/services/ubicacion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Position _posicion(double lat, double lon) => Position(
  latitude: lat,
  longitude: lon,
  timestamp: DateTime(2026),
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

/// Servicio falso para simular cada estado de permisos sin dispositivo.
class ServicioFalso extends UbicacionService {
  const ServicioFalso(this.resultado);

  final ResultadoUbicacion resultado;

  @override
  Future<ResultadoUbicacion> obtenerPosicion() async => resultado;

  @override
  Future<bool> abrirMapa(double latitud, double longitud) async => true;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Distancias', () {
    const servicio = UbicacionService();

    test('distancia entre el mismo punto es cero', () {
      expect(servicio.distancia(19.84, -90.53, 19.84, -90.53), 0);
    });

    test('Campeche a Mérida está entre 155 y 165 km', () {
      final d = servicio.distancia(19.8301, -90.5349, 20.9674, -89.5926);
      expect(d, inInclusiveRange(155000, 165000));
    });

    test('formatearDistancia usa metros o kilómetros', () {
      expect(formatearDistancia(850), '850 m');
      expect(formatearDistancia(1500), '1.50 km');
    });
  });

  test('PuntoInteres se serializa y deserializa', () {
    const p = PuntoInteres(
      id: '1',
      nombre: 'Parque',
      latitud: 1.5,
      longitud: -2,
    );
    final copia = PuntoInteres.fromJson(p.toJson());
    expect(copia.nombre, 'Parque');
    expect(copia.latitud, 1.5);
    expect(copia.longitud, -2.0);
  });

  testWidgets('muestra coordenadas y precisión al obtener ubicación', (
    tester,
  ) async {
    await tester.pumpWidget(
      App(
        servicio: ServicioFalso(
          ResultadoUbicacion(
            EstadoUbicacion.obtenida,
            posicion: _posicion(19.830100, -90.534900),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Obtener ubicación'));
    await tester.pumpAndSettle();

    expect(find.text('Ubicación obtenida'), findsOneWidget);
    expect(find.text('Latitud: 19.830100'), findsOneWidget);
    expect(find.text('Longitud: -90.534900'), findsOneWidget);
    expect(find.text('Precisión: 5.0 m'), findsOneWidget);
  });

  testWidgets('permiso denegado no cierra la app y muestra mensaje', (
    tester,
  ) async {
    await tester.pumpWidget(
      const App(
        servicio: ServicioFalso(
          ResultadoUbicacion(EstadoUbicacion.permisoDenegadoPermanente),
        ),
      ),
    );
    await tester.tap(find.text('Obtener ubicación'));
    await tester.pumpAndSettle();

    expect(find.textContaining('denegado permanentemente'), findsOneWidget);
    expect(find.text('Abrir ajustes de la app'), findsOneWidget);
  });

  testWidgets('guarda un punto y calcula su distancia', (tester) async {
    await tester.pumpWidget(
      App(
        servicio: ServicioFalso(
          ResultadoUbicacion(
            EstadoUbicacion.obtenida,
            posicion: _posicion(19.8301, -90.5349),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Puntos'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Actualizar ubicación'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agregar punto'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('campoNombre')), 'Mérida');
    await tester.enterText(find.byKey(const Key('campoLatitud')), '20.9674');
    await tester.enterText(find.byKey(const Key('campoLongitud')), '-89.5926');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Mérida'), findsOneWidget);
    expect(find.text('Puntos guardados: 1'), findsOneWidget);
    expect(find.textContaining('Distancia: 160.30 km'), findsOneWidget);
  });
}
