class PuntoInteres {
  const PuntoInteres({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });

  final String id;
  final String nombre;
  final double latitud;
  final double longitud;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'latitud': latitud,
    'longitud': longitud,
  };

  factory PuntoInteres.fromJson(Map<String, dynamic> json) => PuntoInteres(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    latitud: (json['latitud'] as num).toDouble(),
    longitud: (json['longitud'] as num).toDouble(),
  );
}
