// lib/models/cart_item.dart
import 'merch_variant.dart';

enum CartItemType { ticket, merch }

class CartItem {
  final CartItemType type;
  final String eventId;
  final String? ticketTypeId;
  final String skuId;           // ID del SKU (MerchSku.id o TicketType.id)
  final String skuName;         // Nombre visible (ej: "Polo Oficial Negro")
  final MerchVariant? selectedVariant;
  final int quantity;
  final double unitPrice;
  final double discountAmount;
  final String? promotionId;

  CartItem({
    required this.type,
    required this.eventId,
    this.ticketTypeId,
    required this.skuId,
    required this.skuName,
    this.selectedVariant,
    this.quantity = 1,
    required this.unitPrice,
    this.discountAmount = 0.0,
    this.promotionId,
  });

  double get total => (unitPrice * quantity) - discountAmount;

  CartItem copyWith({
    int? quantity,
    double? discountAmount,
    String? promotionId,
  }) {
    return CartItem(
      type: type,
      eventId: eventId,
      ticketTypeId: ticketTypeId,
      skuId: skuId,
      skuName: skuName,
      selectedVariant: selectedVariant,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      promotionId: promotionId ?? this.promotionId,
    );
  }

  // ← AQUÍ ESTABA EL ERROR: ¡toJson() debe estar DENTRO de la clase!
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'event_id': eventId,
      'ticket_type_id': ticketTypeId,
      'sku_id': skuId,                    // ← ahora sí existe
      'sku_name': skuName,
      'variant_id': selectedVariant?.id,
      'size': selectedVariant?.size,
      'color': selectedVariant?.color,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_amount': discountAmount,
      'promotion_id': promotionId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CartItem &&
              runtimeType == other.runtimeType &&
              type == other.type &&
              skuId == other.skuId &&
              selectedVariant?.id == other.selectedVariant?.id;

  @override
  int get hashCode => Object.hash(type, skuId, selectedVariant?.id);
}