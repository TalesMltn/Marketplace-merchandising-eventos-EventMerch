// lib/services/cart_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/promotion.dart';

final supabase = Supabase.instance.client;

class CartService {
  // Añade ítem con validación de stock + aplicación automática de promociones
  Future<Cart> addItemWithValidation({
    required Cart currentCart,
    required CartItem newItem,
    required String eventId,
    required List<Promotion> activePromotions,
    required bool hasTicketInCart,
  }) async {
    // 1. Validar stock real en Supabase (solo para merch con variante)
    if (newItem.type == CartItemType.merch && newItem.selectedVariant != null) {
      final variantId = newItem.selectedVariant!.id;

      final response = await supabase
          .from('merch_variants')
          .select('stock')
          .eq('id', variantId)
          .single();

      final int availableStock = response['stock'] as int;

      final int alreadyInCart = currentCart.items
          .where((i) => i.selectedVariant?.id == variantId)
          .fold(0, (sum, i) => sum + i.quantity);

      if (availableStock < alreadyInCart + newItem.quantity) {
        throw Exception('Sin stock suficiente. Quedan solo $availableStock unidades.');
      }
    }

    // 2. Aplicar la MEJOR promoción disponible
    double bestDiscount = 0.0;
    String? bestPromotionId;

    for (final promo in activePromotions) {
      final discount = promo.apply(
        hasRequiredTicket: hasTicketInCart,
        merchSkuId: newItem.skuId,           // CORREGIDO: skuId en vez de merchSkuId
        itemPrice: newItem.unitPrice,
        quantity: newItem.quantity,
      );

      if (discount > bestDiscount) {
        bestDiscount = discount;
        bestPromotionId = promo.id;
      }
    }

    // Aplicar descuento al ítem
    final itemWithDiscount = newItem.copyWith(
      discountAmount: bestDiscount,
      promotionId: bestPromotionId,
    );

    // 3. Reserva temporal (soft reserve) → se maneja en el carrito

    // 4. Devolver carrito actualizado
    return currentCart.addItem(itemWithDiscount);
  }
}