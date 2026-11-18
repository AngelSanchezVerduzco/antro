import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/nexus_theme.dart';

class PromoNetworkImage extends StatelessWidget {
  const PromoNetworkImage({
    super.key,
    required this.url,
    required this.height,
  });

  final String url;
  final double height;

  bool get _esSvg => url.toLowerCase().contains('.svg');

  Widget _placeholder() {
    return Container(
      height: height,
      width: double.infinity,
      color: NexusColors.purpleSoft,
      alignment: Alignment.center,
      child: const Text(
        'Promo sin imagen',
        style: TextStyle(color: NexusColors.purple),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();

    if (_esSvg) {
      return SvgPicture.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => SizedBox(
          height: height,
          child: const Center(
            child: CircularProgressIndicator(color: NexusColors.purple),
          ),
        ),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }
}
