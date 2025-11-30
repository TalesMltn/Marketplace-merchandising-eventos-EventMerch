// lib/providers/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/promotion.dart';
import '../services/cart_service.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(Cart(items: [], deliveryOption: 'pickup'));

  final CartService _service = CartService();

  Future<void> addMerchItem({
    required CartItem item,
    required String eventId,
    required List<Promotion> activePromotions,
    required bool hasTicketInCart,
  }) async {
    try {
      final updatedCart = await _service.addItemWithValidation(
        currentCart: state,
        newItem: item,
        eventId: eventId,
        activePromotions: activePromotions,
        hasTicketInCart: hasTicketInCart,
      );
      state = updatedCart;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      throw Exception(message);
    }
  }

  void addItem(CartItem item) {
    state = state.addItem(item);
  }

  void removeItemAt(int index) {
    if (index >= 0 && index < state.items.length) {
      state = state.removeItem(index);
    }
  }

  void removeItem(CartItem itemToRemove) {
    final index = state.items.indexWhere((i) =>
    i.type == itemToRemove.type &&
        i.skuId == itemToRemove.skuId &&
        i.selectedVariant?.id == itemToRemove.selectedVariant?.id &&
        i.ticketTypeId == itemToRemove.ticketTypeId);

    if (index != -1) removeItemAt(index);
  }

  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(item);
      return;
    }

    final index = state.items.indexWhere((i) =>
    i.type == item.type &&
        i.skuId == item.skuId &&
        i.selectedVariant?.id == item.selectedVariant?.id &&
        i.ticketTypeId == item.ticketTypeId);

    if (index == -1) return;

    final updatedItem = item.copyWith(quantity: newQuantity);
    state = state.copyWith(
      items: List.from(state.items)..[index] = updatedItem,
    );
  }

  void updateDeliveryOption(String option) {
    state = state.updateDeliveryOption(option);
  }

  void clear() {
    state = state.clear();
  }

  // NUEVAS FUNCIONES PARA DESCENTOS AUTOMÁTICOS
  double get subtotal => state.total;

  double get discountPercentage {
    if (subtotal >= 1000) return 15;
    if (subtotal >= 600) return 10;
    if (subtotal >= 300) return 5;
    return 0;
  }

  double get discountAmount => subtotal * (discountPercentage / 100);

  double get totalWithDiscount => subtotal - discountAmount;

  String get discountText {
    if (discountPercentage == 0) return "Sin descuento";
    return "¡$discountPercentage% OFF por compra mayor a S/ ${discountPercentage == 15 ? '1000' : discountPercentage == 10 ? '600' : '300'}!";
  }

  String get nextDiscountMessage {
    if (subtotal >= 1000) return "¡Ya tienes el máximo descuento!";
    if (subtotal >= 600) return "Agrega S/ ${(1000 - subtotal).toStringAsFixed(2)} más para 15% OFF";
    if (subtotal >= 300) return "Agrega S/ ${(600 - subtotal).toStringAsFixed(2)} más para 10% OFF";
    return "Agrega S/ ${(300 - subtotal).toStringAsFixed(2)} más para 5% OFF";
  }
}