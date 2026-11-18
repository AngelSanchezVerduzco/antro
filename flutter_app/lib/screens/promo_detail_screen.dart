import 'package:flutter/material.dart';

import '../models/promocion.dart';
import '../widgets/promo_network_image.dart';

class PromoDetailScreen extends StatelessWidget {
  const PromoDetailScreen({super.key, required this.promocion});

  final Promocion promocion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promoción')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PromoNetworkImage(
              url: promocion.imageUrl,
              height: 240,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            promocion.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(promocion.body, style: const TextStyle(fontSize: 16, height: 1.4)),
        ],
      ),
    );
  }
}
