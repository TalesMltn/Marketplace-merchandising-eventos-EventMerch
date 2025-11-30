// lib/models/order.dart
class Order {
  final String id;
  final String eventId;
  final double totalAmount;
  final String deliveryOption; // 'pickup' o 'shipping'
  final String status;         // 'pending', 'paid', 'preparing', 'delivered'
  final String? pickupCode;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items; // detalle de order_items

  Order({
    required this.id,
    required this.eventId,
    required this.totalAmount,
    required this.deliveryOption,
    required this.status,
    this.pickupCode,
    required this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      totalAmount: double.parse(json['total_amount'].toString()),
      deliveryOption: json['delivery_option'] as String,
      status: json['status'] as String,
      pickupCode: json['pickup_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: List<Map<String, dynamic>>.from(json['order_items'] ?? []),
    );
  }
}