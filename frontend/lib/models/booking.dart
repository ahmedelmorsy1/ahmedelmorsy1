class Booking {
  Booking({
    required this.id,
    required this.pitchId,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.slot,
    required this.status,
  });

  final String id;
  final String pitchId;
  final String customerName;
  final String customerPhone;
  final String date;
  final String slot;
  final String status;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      pitchId: json['pitchId'] as String,
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      date: json['date'] as String? ?? '',
      slot: json['slot'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }
}
