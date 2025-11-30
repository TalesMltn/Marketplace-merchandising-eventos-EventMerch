// lib/screens/merch_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/merch_sku.dart';
import '../models/merch_variant.dart';
import '../providers/cart_provider.dart';

class MerchDetailScreen extends ConsumerStatefulWidget {
  final MerchSku sku;
  const MerchDetailScreen({super.key, required this.sku});

  @override
  ConsumerState<MerchDetailScreen> createState() => _MerchDetailScreenState();
}

class _MerchDetailScreenState extends ConsumerState<MerchDetailScreen> {
  MerchVariant? selectedVariant;
  late Future<List<MerchVariant>> futureVariants;

  @override
  void initState() {
    super.initState();
    futureVariants = _loadVariants();
  }

  // CORREGIDO: ahora usa skuId (como tu modelo real)
  Future<List<MerchVariant>> _loadVariants() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final skuId = widget.sku.id;

    return [
      MerchVariant(id: '${skuId}_S',  skuId: skuId, size: 'S',  stock: 50),
      MerchVariant(id: '${skuId}_M',  skuId: skuId, size: 'M',  stock: 45),
      MerchVariant(id: '${skuId}_L',  skuId: skuId, size: 'L',  stock: 30),
      MerchVariant(id: '${skuId}_XL', skuId: skuId, size: 'XL', stock: 20),
    ];
  }

  String _getProductImage() {
    final name = widget.sku.name.toLowerCase();
    const base = 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/';
    if (name.contains('polo')) return '${base}polo_negro.jpg?token=...';
    if (name.contains('sudadera')) return '${base}sudadera_negro.jpg?...';
    if (name.contains('chaqueta')) return '${base}Chaquetas_Ligeras_negro.jpg?...';
    return '${base}polo_negro.jpg?...';
  }

  void _addToCart(MerchVariant? variant) async {
    if (variant != null && variant.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sin stock"), backgroundColor: Colors.red),
      );
      return;
    }

    final esPoloSudaderaOChaqueta = widget.sku.name.toLowerCase().contains('polo') ||
        widget.sku.name.toLowerCase().contains('sudadera') ||
        widget.sku.name.toLowerCase().contains('chaqueta');

    double precioFinal = widget.sku.price;

    if (esPoloSudaderaOChaqueta && variant != null) {
      switch (variant.size.toUpperCase()) {
        case 'M': precioFinal += 13.0; break;
        case 'L': precioFinal += 26.0; break;
        case 'XL': precioFinal += 39.0; break;
      }
    }

    // CORREGIDO: ahora usa skuId y skuName (NO merchSkuId/merchSkuName)
    final item = CartItem(
      type: CartItemType.merch,
      eventId: widget.sku.eventId,
      skuId: widget.sku.id,        // CORRECTO
      skuName: widget.sku.name,    // CORRECTO
      selectedVariant: variant,
      quantity: 1,
      unitPrice: precioFinal,
    );

    try {
      await ref.read(cartProvider.notifier).addMerchItem(
        item: item,
        eventId: widget.sku.eventId,
        activePromotions: const [],
        hasTicketInCart: ref.read(cartProvider).hasTickets,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${widget.sku.name} ${variant != null ? "(${variant.size})" : ""} agregado al carrito"),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sku.name),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: _getProductImage(),
                height: 380,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.sku.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Desde S/ ${widget.sku.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
            const SizedBox(height: 20),

            FutureBuilder<List<MerchVariant>>(
              future: futureVariants,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final variants = snapshot.data ?? [];

                if (variants.isEmpty) {
                  return ElevatedButton.icon(
                    onPressed: () => _addToCart(null),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text("AGREGAR AL CARRITO"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Selecciona tu talla:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: variants.map((v) {
                        final disponible = v.stock > 0;
                        return FilterChip(
                          label: Text(v.size),
                          selected: selectedVariant?.id == v.id,
                          selectedColor: Colors.purple.shade100,
                          backgroundColor: disponible ? Colors.grey[200] : Colors.grey[400],
                          onSelected: disponible ? (s) => setState(() => selectedVariant = s ? v : null) : null,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: selectedVariant == null ? null : () => _addToCart(selectedVariant),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("AGREGAR AL CARRITO"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[400],
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}