import 'package:flutter/material.dart';

import '../models/promocion.dart';

class PromoDetailScreen extends StatelessWidget {
  const PromoDetailScreen({super.key, required this.promocion});

  final Promocion promocion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promoción Nexus'),
        backgroundColor: const Color(0xFF5B21B6),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              promocion.imageUrl,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 240,
                color: const Color(0xFF312E81),
                alignment: Alignment.center,
                child: const Text('No se pudo cargar la imagen'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            promocion.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(promocion.body),
          const SizedBox(height: 16),
          _InfoRow(label: 'ID', value: promocion.id),
          _InfoRow(label: 'Tipo', value: promocion.type),
          _InfoRow(label: 'Deep link', value: promocion.deepLink),
          _InfoRow(label: 'Vigencia', value: promocion.expiresAt),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
