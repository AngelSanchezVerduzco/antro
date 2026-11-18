class Promocion {
  const Promocion({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.deepLink,
    required this.expiresAt,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String imageUrl;
  final String deepLink;
  final String expiresAt;
  final String createdAt;

  factory Promocion.fromJson(Map<String, dynamic> json) {
    return Promocion(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'promocion_nueva',
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      deepLink: json['deepLink'] as String? ?? '/inicio',
      expiresAt: json['expiresAt']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
