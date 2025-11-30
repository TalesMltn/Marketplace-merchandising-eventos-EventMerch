// lib/models/order.dart
class Order {
  final String id;
  final String eventId;
  final double totalAmount;
  final String deliveryOption; // 'shipping' o 'pickup'
  final String status;
  final String? pickupCode;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.eventId,
    required this.totalAmount,
    required this.deliveryOption,
    required this.status,
    this.pickupCode,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      eventId: json['event_id'],
      totalAmount: double.parse(json['total_amount'].toString()),
      deliveryOption: json['delivery_option'],
      status: json['status'],
      pickupCode: json['pickup_code'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}