import 'package:flutter/material.dart';

import 'screens/tasks_dashboard_screen.dart';

/// Entry point para Flutter Web — dashboard embebido en Angular.
void main() {
  runApp(const TasksDashboardApp());
}

class TasksDashboardApp extends StatelessWidget {
  const TasksDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0C0C12),
      ),
      home: const TasksDashboardScreen(),
    );
  }
}
