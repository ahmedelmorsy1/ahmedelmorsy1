class Pitch {
  Pitch({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerHour,
    required this.surfaceType,
    required this.amenities,
    required this.slots,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String location;
  final double pricePerHour;
  final String surfaceType;
  final List<String> amenities;
  final List<String> slots;
  final String? imageUrl;

  factory Pitch.fromJson(Map<String, dynamic> json) {
    final amenities = json['amenities'];
    final slots = json['slots'];
    return Pitch(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String? ?? 'غير محدد',
      pricePerHour: _parsePrice(json['pricePerHour']),
      surfaceType: json['surfaceType'] as String? ?? 'غير محدد',
      amenities: amenities is List
          ? amenities.whereType<String>().toList(growable: false)
          : const <String>[],
      slots: slots is List
          ? slots.whereType<String>().toList(growable: false)
          : const <String>[],
      imageUrl: json['imageUrl'] as String?,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
