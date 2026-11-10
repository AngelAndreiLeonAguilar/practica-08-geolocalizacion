import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/punto_interes.dart';

/// Guarda los puntos de interés de forma local en el dispositivo.
class PuntosRepositorio {
  static const _clave = 'puntos_interes';

  Future<List<PuntoInteres>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_clave);
    if (texto == null) return [];
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((e) => PuntoInteres.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> guardar(List<PuntoInteres> puntos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _clave,
      jsonEncode(puntos.map((p) => p.toJson()).toList()),
    );
  }
}
