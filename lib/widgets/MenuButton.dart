import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final String subtitle;

  const MenuButton({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
    this.subtitle = "Ver / administrar",
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(229, 231, 235, 1), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 46, color: const Color.fromRGBO(0, 66, 137, 1)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color.fromRGBO(17, 24, 39, 1),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color.fromRGBO(107, 114, 128, 1)),
            ),
          ],
        ),
      ),
    );
  }
}
