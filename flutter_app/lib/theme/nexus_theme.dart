import 'package:flutter/material.dart';

class NexusColors {
  static const purple = Color(0xFF5B21B6);
  static const purpleDark = Color(0xFF3B0764);
  static const purpleSoft = Color(0xFFF5F3FF);
  static const card = Color(0xFFFFFFFF);
}

ThemeData nexusMobileTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: NexusColors.purple),
    useMaterial3: true,
    scaffoldBackgroundColor: NexusColors.purpleSoft,
    appBarTheme: const AppBarTheme(
      backgroundColor: NexusColors.purple,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: NexusColors.purple,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: NexusColors.purple,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        side: const BorderSide(color: NexusColors.purple),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NexusColors.purple, width: 2),
      ),
    ),
  );
}

class NexusLoadingScreen extends StatelessWidget {
  const NexusLoadingScreen({super.key, this.mensaje = 'Cargando Nexus...'});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.purple,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.nightlife, color: Colors.white, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Nexus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'App móvil',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 28),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(mensaje, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class NexusStatusBanner extends StatelessWidget {
  const NexusStatusBanner({
    super.key,
    required this.texto,
    this.error = false,
  });

  final String texto;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: error ? const Color(0xFFB91C1C) : const Color(0xFF166534),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
