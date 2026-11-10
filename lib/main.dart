import 'package:flutter/material.dart';

import 'pages/puntos_page.dart';
import 'pages/ubicacion_page.dart';
import 'services/puntos_repositorio.dart';
import 'services/ubicacion_service.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key, this.servicio = const UbicacionService()});

  final UbicacionService servicio;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puntos de interés',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: InicioPage(servicio: servicio),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key, required this.servicio});

  final UbicacionService servicio;

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int indice = 0;
  final repositorio = PuntosRepositorio();

  @override
  Widget build(BuildContext context) {
    final paginas = [
      UbicacionPage(servicio: widget.servicio),
      PuntosPage(servicio: widget.servicio, repositorio: repositorio),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(indice == 0 ? 'Mi ubicación' : 'Puntos de interés'),
      ),
      body: IndexedStack(index: indice, children: paginas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: (i) => setState(() => indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Ubicación',
          ),
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place),
            label: 'Puntos',
          ),
        ],
      ),
    );
  }
}
