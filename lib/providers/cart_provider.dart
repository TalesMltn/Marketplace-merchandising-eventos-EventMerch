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

  // MÉTODO NUEVO QUE TE FALTABA
  void removeItem(CartItem itemToRemove) {
    final index = state.items.indexWhere((i) =>
    i.type == itemToRemove.type &&
        i.skuId == itemToRemove.skuId &&
        i.selectedVariant?.id == itemToRemove.selectedVariant?.id &&
        i.ticketTypeId == itemToRemove.ticketTypeId);

    if (index != -1) {
      removeItemAt(index);
    }
  }

  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(item); // ahora sí funciona perfectamente
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
}