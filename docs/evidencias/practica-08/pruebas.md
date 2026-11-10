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

## Casos manuales en dispositivo

| # | Caso | Resultado esperado | Resultado |
|---|---|---|---|
| 1 | Abrir la app por primera vez y pulsar "Obtener ubicación" | Se solicita el permiso de ubicación | |
| 2 | Conceder permiso | Se muestran latitud, longitud y precisión | |
| 3 | Denegar permiso | Mensaje "Permiso de ubicación denegado", la app no se cierra | |
| 4 | Denegar permanentemente | Mensaje y botón "Abrir ajustes de la app" | |
| 5 | Desactivar el GPS y pulsar "Obtener ubicación" | Mensaje "Activa el servicio de ubicación" | |
| 6 | Pulsar "Abrir en mapa" | Se abre Google Maps en la posición actual | |
| 7 | Agregar 3 puntos con nombre | Se listan con latitud, longitud y distancia | |
| 8 | Cerrar y volver a abrir la app | Los puntos siguen guardados | |
| 9 | Pulsar el ícono de mapa en un punto | Se abre el mapa en esa ubicación | |
| 10 | Deslizar un punto a la izquierda | El punto se elimina | |

## Capturas

Colocar en esta carpeta:

- `01_permiso.png` – diálogo de permiso
- `02_ubicacion.png` – coordenadas y precisión
- `03_permiso_denegado.png` – manejo de permiso denegado
- `04_puntos.png` – lista con 3 o más puntos y distancias
- `05_agregar_punto.png` – formulario de nuevo punto
- `06_mapa.png` – mapa externo abierto
