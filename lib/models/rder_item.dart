// lib/models/order_item.dart
import 'cart_item.dart';
import 'merch_variant.dart';

class OrderItem {
  final CartItemType type;
  final String? ticketTypeId;
  final String? merchSkuId;
  final String? merchSkuName;
  final MerchVariant? selectedVariant;
  final int quantity;
  final double unitPrice;
  final double discountAmount;
  final String? promotionId;

  OrderItem({
    required this.type,
    this.ticketTypeId,
    this.merchSkuId,
    this.merchSkuName,
    this.selectedVariant,
    required this.quantity,
    required this.unitPrice,
    this.discountAmount = 0.0,
    this.promotionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'ticket_type_id': ticketTypeId,
      'merch_sku_id': merchSkuId,
      'merch_sku_name': merchSkuName,
      'variant_id': selectedVariant?.id,
      'size': selectedVariant?.size,
      'color': selectedVariant?.color,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_amount': discountAmount,
      'promotion_id': promotionId,
    };
  }
}