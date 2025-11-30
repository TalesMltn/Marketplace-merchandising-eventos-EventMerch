// lib/models/cart.dart
import 'cart_item.dart';

class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  double get total => items.fold(0, (sum, item) => sum + item.total);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get hasTickets => items.any((i) => i.type == CartItemType.ticket);
  bool get hasMerch => items.any((i) => i.type == CartItemType.merch);

  Cart addItem(CartItem item) {
    final existingIndex = items.indexWhere((i) =>
    i.type == item.type &&
        i.merchSkuId == item.merchSkuId &&
        i.selectedVariant?.id == item.selectedVariant?.id);

    if (existingIndex >= 0) {
      final updatedItems = items.map((i) {
        if (i == items[existingIndex]) {
          return i.copyWith(quantity: i.quantity + item.quantity);
        }
        return i;
      }).toList();
      return Cart(items: updatedItems);
    } else {
      return Cart(items: [...items, item]);
    }
  }

  Cart removeItem(int index) {
    final newItems = List<CartItem>.from(items)..removeAt(index);
    return Cart(items: newItems);
  }

  Cart clear() => Cart(items: []);
}