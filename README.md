# Práctica 8 – GPS, geolocalización y mapas

App en Flutter para gestionar **puntos de interés**: obtiene la ubicación actual del dispositivo, guarda ubicaciones con nombre, calcula la distancia desde la posición actual con `Geolocator.distanceBetween` y abre cada punto en un mapa externo.

## Objetivo

Solicitar permisos de ubicación, obtener las coordenadas del dispositivo y representarlas en una interfaz preparada para mapas.

## Funciones

- **Ubicación (ejemplo guiado):** solicita permisos en tiempo de ejecución, muestra latitud, longitud y precisión, y abre la posición en Google Maps.
- **Manejo de permisos:** distingue servicio desactivado, permiso denegado, permiso denegado permanentemente y errores, sin cierres inesperados. Ofrece accesos directos a los ajustes del sistema.
- **Puntos de interés (ejercicio evaluable):**
  - Agregar puntos con nombre y coordenadas (manuales o desde la ubicación actual).
  - Persistencia local con `shared_preferences`.
  - Distancia desde la ubicación actual (m / km) y lista ordenada por cercanía.
  - Abrir cada punto en el mapa externo.
  - Eliminar puntos deslizando hacia la izquierda.

## Requisitos

- Flutter 3.x (probado con Flutter 3.47 / Dart 3.13)
- Android Studio o Xcode
- Dispositivo físico con ubicación activa o emulador con ubicación configurada

Paquetes: `geolocator`, `url_launcher`, `shared_preferences`.

## Instalación

```bash
git clone <url-del-repositorio>
cd <carpeta-del-proyecto>
git checkout practica-08-geolocalizacion
flutter pub get
```

## Ejecución

```bash
flutter run
```

En el emulador de Android se puede simular la ubicación desde *Extended controls → Location*.

## Permisos configurados

| Plataforma | Archivo | Permisos |
|---|---|---|
| Android | `android/app/src/main/AndroidManifest.xml` | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `INTERNET`, consulta de intents `https` |
| iOS | `ios/Runner/Info.plist` | `NSLocationWhenInUseUsageDescription`, `LSApplicationQueriesSchemes` |

## Estructura

```
lib/
  main.dart                     Navegación entre pantallas
  models/punto_interes.dart     Modelo y serialización JSON
  services/ubicacion_service.dart  Permisos, GPS, distancias y mapa
  services/puntos_repositorio.dart Persistencia local
  pages/ubicacion_page.dart     Ejemplo guiado
  pages/puntos_page.dart        App de puntos de interés
test/widget_test.dart           Pruebas unitarias y de widgets
docs/evidencias/practica-08/    Capturas y resultados de pruebas
```

## Pruebas

```bash
dart format .
flutter analyze
flutter test
```

Resultados en [`docs/evidencias/practica-08/pruebas.md`](docs/evidencias/practica-08/pruebas.md).

## Vinculación con el proyecto integrador

El módulo de ubicación queda separado en `UbicacionService`, por lo que puede reutilizarse en el proyecto integrador para mostrar la ubicación actual, calcular distancias hacia lugares relevantes o abrir direcciones en el mapa.

## Participantes

- Angel Andrei Leon Aguilar
