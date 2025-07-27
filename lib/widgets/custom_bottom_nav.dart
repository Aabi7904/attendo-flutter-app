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
    //final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
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
              const Color.fromRGBO(255, 255, 255, 0.1),
              const Color.fromRGBO(255, 255, 255, 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromRGBO(255, 255, 255, 0.5),
              const Color.fromRGBO(255, 255, 255, 0.5),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, Icons.dashboard_rounded, "Home", 0),
              _buildNavItem(context, Icons.check_circle_outline_rounded, "Attendance", 1),
              _buildNavItem(context, Icons.calendar_today_rounded, "Timetable", 2),
              _buildNavItem(context, Icons.person_outline_rounded, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    final color = isSelected ? Colors.cyanAccent : Colors.white70;
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded( // ⬅️ Ensures even spacing and prevents overflow
      child: InkWell(
        onTap: () => onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02, // Responsive padding
            vertical: screenWidth * 0.015,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(0, 255, 255, 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: screenWidth * 0.06), // responsive icon
              const SizedBox(height: 2),
              FittedBox(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: screenWidth * 0.028, // responsive font size
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
