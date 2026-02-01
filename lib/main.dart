import 'package:flutter/material.dart';

import 'screens/multa/MultaFormScreen.dart';
import 'screens/multa/MultaScreedn.dart';
import 'screens/pago/PagoFormScreen.dart';
import 'screens/pago/PagoScreen.dart';

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
        '/pago': (context) => MultaScreen(),
        '/multa/form': (context) => MultaFormScreen(),
        '/': (context) => PagoScreen(),
        '/pago/form': (context) => PagoFormScreen(),
      },
    );
  }
}
