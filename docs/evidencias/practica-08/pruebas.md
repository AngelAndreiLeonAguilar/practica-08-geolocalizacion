# Evidencias – Práctica 8

## flutter analyze

```
Analyzing Praxtica 8...
No issues found!
```

## flutter test

```
00:00 +1: Distancias distancia entre el mismo punto es cero
00:00 +2: Distancias Campeche a Mérida está entre 155 y 165 km
00:00 +3: Distancias formatearDistancia usa metros o kilómetros
00:00 +4: PuntoInteres se serializa y deserializa
00:00 +5: muestra coordenadas y precisión al obtener ubicación
00:00 +6: permiso denegado no cierra la app y muestra mensaje
00:01 +7: guarda un punto y calcula su distancia
00:01 +7: All tests passed!
```

## Casos manuales

Dispositivo: emulador Android "Medium Phone" (API 36), ubicación simulada en Calkiní, Campeche (20.3736, -90.0542).

| # | Caso | Resultado | Evidencia |
|---|---|---|---|
| 1 | Primera ejecución y pulsar "Obtener ubicación" | Correcto. Aparece el diálogo de permiso del sistema | `01_permiso.png` |
| 2 | Conceder permiso | Correcto. Lat 20.373598, Lon -90.054198, precisión 5.0 m | `02_ubicacion.png` |
| 3 | Denegar permiso | Correcto. Mensaje "Permiso de ubicación denegado", la app no se cierra | `03_permiso_denegado.png` |
| 4 | Denegar por segunda vez (denegado permanente) | Correcto. Mensaje y botón "Abrir ajustes de la app" | `04_permiso_permanente.png` |
| 5 | GPS desactivado | Correcto. Mensaje "Activa el servicio de ubicación"; el botón "Activar ubicación" abre los ajustes de ubicación | `05_gps_desactivado.png` |
| 6 | "Abrir en mapa" desde la ubicación actual | Correcto. Google Maps abre en 20.373598, -90.054198 (Calkiní) | `07_mapa_ubicacion.png` |
| 7 | Guardar 4 puntos con nombre | Correcto. Calkini 0 m, Hecelchakan 23.20 km, Campeche Centro 76.59 km, Merida Centro 79.85 km, ordenados por cercanía | `06_agregar_punto.png`, `08_lista_puntos.png` |
| 8 | Cerrar la app (force stop) y volver a abrir | Correcto. Los 4 puntos siguen guardados | – |
| 9 | Botón de mapa en "Merida Centro" | Correcto. Google Maps abre en 20.9671, -89.6237 (Mérida, Yucatán) | `09_mapa_punto.png` |
| 10 | Deslizar un punto a la izquierda | Correcto. El punto se elimina y el contador se actualiza | `10_eliminar.png` |

## Problema encontrado y solución

En la primera prueba, al pedir la ubicación con alta precisión, Android mostró el diálogo de "Precisión de la ubicación" de Google Play Services. Al rechazarlo, la lectura nunca terminaba y la app mostraba "No se pudo obtener la ubicación: TimeoutException" (sin cerrarse, gracias al límite de 20 s y al try/catch).

Solución: en Android se configuró `AndroidSettings(forceLocationManager: true)` para leer el GPS directamente con el `LocationManager` del sistema. Así la app no depende de Google Play Services y funciona también en equipos que no los tienen.
