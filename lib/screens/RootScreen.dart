import 'package:flutter/material.dart';

import '../../widgets/MenuButton.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 249, 252, 1),
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: const [
                  Expanded(
                    child: MenuButton(title: "Multas", icon: Icons.receipt_long, route: "/multa"),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: MenuButton(title: "Pagos", icon: Icons.payments, route: "/pago"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: const [
                  Expanded(
                    child: MenuButton(
                      title: "Conductores",
                      icon: Icons.person,
                      route: "/conductor",
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: MenuButton(
                      title: "Vehículos",
                      icon: Icons.directions_car,
                      route: "/vehiculo",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: const [
                  Expanded(
                    child: MenuButton(
                      title: "Tipos de infracción",
                      icon: Icons.gavel,
                      route: "/tipoInfraccion",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
