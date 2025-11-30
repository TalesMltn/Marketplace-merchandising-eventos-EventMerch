// lib/models/cart.dart
import 'cart_item.dart';
export 'cart_item.dart';   // ← ESTO HACE QUE CartItemType SEA VISIBLE EN TODOS LADOS

class Cart {
  final List<CartItem> items;
  final String deliveryOption; // 'pickup' o 'shipping'

  Cart({
    this.items = const [],
    this.deliveryOption = 'pickup',
  });

  // Cálculos
  double get subtotal => items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
  double get discountTotal => items.fold(0, (sum, item) => sum + item.discountAmount);
  double get total => subtotal - discountTotal;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get hasTickets => items.any((i) => i.type == CartItemType.ticket);
  bool get hasMerch => items.any((i) => i.type == CartItemType.merch);

  // Añadir ítem (con merge si ya existe)
  Cart addItem(CartItem newItem) {
    final existingIndex = items.indexWhere((i) =>
    i.type == newItem.type &&
        i.skuId == newItem.skuId &&  // ← ahora usa skuId (como ya corregimos antes)
        i.selectedVariant?.id == newItem.selectedVariant?.id &&
        i.ticketTypeId == newItem.ticketTypeId);

    if (existingIndex >= 0) {
      final updatedItems = items.map((i) {
        if (i == items[existingIndex]) {
          return i.copyWith(
            quantity: i.quantity + newItem.quantity,
            discountAmount: i.discountAmount + newItem.discountAmount,
          );
        }
        return i;
      }).toList();
      return Cart(items: updatedItems, deliveryOption: deliveryOption);
    } else {
      return Cart(items: [...items, newItem], deliveryOption: deliveryOption);
    }
  }

  Cart removeItem(int index) {
    final newItems = List<CartItem>.from(items)..removeAt(index);
    return Cart(items: newItems, deliveryOption: deliveryOption);
  }

  Cart updateDeliveryOption(String option) {
    return Cart(items: items, deliveryOption: option);
  }

  Cart clear() => Cart(items: [], deliveryOption: deliveryOption);

  Cart copyWith({
    List<CartItem>? items,
    String? deliveryOption,
  }) {
    return Cart(
      items: items ?? this.items,
      deliveryOption: deliveryOption ?? this.deliveryOption,
    );
  }
}