// lib/models/promotion.dart
class Promotion {
  final String id;
  final String eventId;
  final String name;
  final String type; // 'percent' | 'fixed_amount'
  final double value; // 15.0 = 15%, o 50.0 = S/50 fijo
  final String? requiredTicketTypeId;
  final String? requiredMerchSkuId;
  final bool active;

  const Promotion({
    required this.id,
    required this.eventId,
    required this.name,
    required this.type,
    required this.value,
    this.requiredTicketTypeId,
    this.requiredMerchSkuId,
    this.active = true,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      value: double.parse(json['value'].toString()),
      requiredTicketTypeId: json['required_ticket_type_id'] as String?,
      requiredMerchSkuId: json['required_merch_sku_id'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  /// APLICA LA PROMOCIÓN Y DEVUELVE EL DESCUENTO EN SOLES
  double apply({
    required bool hasRequiredTicket,
    required String? merchSkuId,
    required double itemPrice,
    required int quantity,
  }) {
    if (!active) return 0.0;
    if (requiredTicketTypeId != null && !hasRequiredTicket) return 0.0;
    if (requiredMerchSkuId != null && requiredMerchSkuId != merchSkuId) return 0.0;

    if (type == 'percent') {
      return (value / 100) * itemPrice * quantity;
    } else {
      // fixed_amount
      return value * quantity;
    }
  }
}