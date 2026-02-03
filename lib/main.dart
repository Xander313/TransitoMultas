import 'package:flutter/material.dart';



import 'screens/RootScreen.dart';
import 'screens/conductor/conductor_form_screen.dart';
import 'screens/conductor/conductor_screen.dart';
import 'screens/multa/MultaFormScreen.dart';
import 'screens/multa/MultaScreedn.dart';
import 'screens/pago/PagoFormScreen.dart';
import 'screens/pago/PagoScreen.dart';
import 'screens/vehiculos/vehiculo_form_screen.dart';
import 'screens/vehiculos/vehiculo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: ':/',
      routes: {
        '/': (context) => RootScreen(),
        '/multa': (context) => MultaScreen(),
        '/multa/form': (context) => MultaFormScreen(),
        '/pago': (context) => PagoScreen(),
        '/pago/form': (context) => PagoFormScreen(),
        '/vehiculo': (context) => VehiculoScreen(),
        '/vehiculo/form': (context) => VehiculoFormsScreen(),
        '/conductor': (context) => ConductorScreen(),
        '/conductor/form': (context) => ConductorFormScreen(),
      },
    );
  }
}
