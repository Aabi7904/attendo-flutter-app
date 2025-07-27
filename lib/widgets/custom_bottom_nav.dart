import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 70,
        borderRadius: 20,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(255, 255, 255, 0.1),
            Color.fromRGBO(255, 255, 255, 0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(255, 255, 255, 0.5),
            Color.fromRGBO(255, 255, 255, 0.5),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard_rounded, "Home", 0),
            _buildNavItem(Icons.check_circle_outline_rounded, "Attendance", 1),
            _buildNavItem(Icons.calendar_today_rounded, "Timetable", 2),
            _buildNavItem(Icons.person_outline_rounded, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    final color = isSelected ? Colors.cyanAccent : Colors.white70;

    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color.fromRGBO(0, 255, 255, 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
