import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Exercises',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag),
          label: 'Goals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_run),
          label: 'Workouts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: 'Progress',
        ),
      ],
    );
  }
}