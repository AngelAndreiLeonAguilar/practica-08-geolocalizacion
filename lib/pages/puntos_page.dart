import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/punto_interes.dart';
import '../services/puntos_repositorio.dart';
import '../services/ubicacion_service.dart';

/// Ejercicio evaluable: lista de puntos de interés con distancia
/// calculada desde la ubicación actual.
class PuntosPage extends StatefulWidget {
  const PuntosPage({
    super.key,
    this.servicio = const UbicacionService(),
    required this.repositorio,
  });

  final UbicacionService servicio;
  final PuntosRepositorio repositorio;

  @override
  State<PuntosPage> createState() => _PuntosPageState();
}

class _PuntosPageState extends State<PuntosPage> {
  List<PuntoInteres> puntos = [];
  Position? actual;
  String mensaje = 'Actualiza tu ubicación para calcular distancias';
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarPuntos();
  }

  Future<void> _cargarPuntos() async {
    final guardados = await widget.repositorio.cargar();
    if (!mounted) return;
    setState(() => puntos = guardados);
  }

  Future<void> _actualizarUbicacion() async {
    setState(() => cargando = true);
    final resultado = await widget.servicio.obtenerPosicion();
    if (!mounted) return;
    setState(() {
      cargando = false;
      mensaje = resultado.mensaje;
      if (resultado.posicion != null) actual = resultado.posicion;
    });
  }

  double? _distanciaA(PuntoInteres p) {
    if (actual == null) return null;
    return widget.servicio.distancia(
      actual!.latitude,
      actual!.longitude,
      p.latitud,
      p.longitud,
    );
  }

  List<PuntoInteres> get _ordenados {
    if (actual == null) return puntos;
    final copia = [...puntos];
    copia.sort((a, b) => _distanciaA(a)!.compareTo(_distanciaA(b)!));
    return copia;
  }

  Future<void> _agregar() async {
    final nuevo = await showDialog<PuntoInteres>(
      context: context,
      builder: (_) => _DialogoPunto(actual: actual),
    );
    if (nuevo == null) return;
    setState(() => puntos = [...puntos, nuevo]);
    await widget.repositorio.guardar(puntos);
  }

  Future<void> _eliminar(PuntoInteres p) async {
    setState(() => puntos = puntos.where((e) => e.id != p.id).toList());
    await widget.repositorio.guardar(puntos);
  }

  Future<void> _abrirMapa(PuntoInteres p) async {
    final ok = await widget.servicio.abrirMapa(p.latitud, p.longitud);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo abrir el mapa')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = _ordenados;
    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.person_pin_circle, size: 36),
              title: Text(
                actual == null
                    ? 'Ubicación actual desconocida'
                    : '${actual!.latitude.toStringAsFixed(6)}, '
                          '${actual!.longitude.toStringAsFixed(6)}',
              ),
              subtitle: Text(
                actual == null
                    ? mensaje
                    : 'Precisión: ${actual!.accuracy.toStringAsFixed(1)} m',
              ),
              trailing: IconButton(
                tooltip: 'Actualizar ubicación',
                onPressed: cargando ? null : _actualizarUbicacion,
                icon: cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Puntos guardados: ${puntos.length}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (puntos.length < 3)
                  Text(
                    'Agrega al menos 3',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const Center(child: Text('No hay puntos de interés'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final p = lista[i];
                      final d = _distanciaA(p);
                      return Dismissible(
                        key: ValueKey(p.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _eliminar(p),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${i + 1}')),
                          title: Text(p.nombre),
                          subtitle: Text(
                            'Lat: ${p.latitud.toStringAsFixed(6)}\n'
                            'Lon: ${p.longitud.toStringAsFixed(6)}\n'
                            'Distancia: ${d == null ? '—' : formatearDistancia(d)}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: 'Abrir en mapa',
                            icon: const Icon(Icons.map),
                            onPressed: () => _abrirMapa(p),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregar,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Agregar punto'),
      ),
    );
  }
}

class _DialogoPunto extends StatefulWidget {
  const _DialogoPunto({this.actual});

  final Position? actual;

  @override
  State<_DialogoPunto> createState() => _DialogoPuntoState();
}

class _DialogoPuntoState extends State<_DialogoPunto> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _lat = TextEditingController();
  final _lon = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _lat.dispose();
    _lon.dispose();
    super.dispose();
  }

  void _usarActual() {
    final p = widget.actual;
    if (p == null) return;
    _lat.text = p.latitude.toStringAsFixed(6);
    _lon.text = p.longitude.toStringAsFixed(6);
  }

  String? _validarCoordenada(String? v, double limite) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null) return 'Número inválido';
    if (n < -limite || n > limite) return 'Debe estar entre -$limite y $limite';
    return null;
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      PuntoInteres(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nombre: _nombre.text.trim(),
        latitud: double.parse(_lat.text.trim()),
        longitud: double.parse(_lon.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const teclado = TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    );
    return AlertDialog(
      title: const Text('Nuevo punto de interés'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('campoNombre'),
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
              ),
              TextFormField(
                key: const Key('campoLatitud'),
                controller: _lat,
                keyboardType: teclado,
                decoration: const InputDecoration(labelText: 'Latitud'),
                validator: (v) => _validarCoordenada(v, 90),
              ),
              TextFormField(
                key: const Key('campoLongitud'),
                controller: _lon,
                keyboardType: teclado,
                decoration: const InputDecoration(labelText: 'Longitud'),
                validator: (v) => _validarCoordenada(v, 180),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: widget.actual == null ? null : _usarActual,
                icon: const Icon(Icons.my_location),
                label: const Text('Usar ubicación actual'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
