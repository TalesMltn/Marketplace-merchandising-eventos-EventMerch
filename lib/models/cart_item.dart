// lib/models/cart_item.dart
import 'merch_variant.dart';

enum CartItemType { ticket, merch }

class CartItem {
  final CartItemType type;
  final String eventId;
  final String? merchSkuId;
  final MerchVariant? selectedVariant;
  final int quantity;
  final double unitPrice;

  CartItem({
    required this.type,
    required this.eventId,
    this.merchSkuId,
    this.selectedVariant,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => unitPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      type: type,
      eventId: eventId,
      merchSkuId: merchSkuId,
      selectedVariant: selectedVariant,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
    );
  }
}