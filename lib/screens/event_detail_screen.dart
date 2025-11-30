import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../models/merch_sku.dart';
import '../models/merch_variant.dart';
import '../models/cart_item.dart';
import '../services/supabase_service.dart';
import 'cart_screen.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  late Future<List<MerchSku>> futureMerch;

  @override
  void initState() {
    super.initState();
    futureMerch = SupabaseService.getMerchByEvent(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
      body: FutureBuilder<List<MerchSku>>(
        future: futureMerch,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay merchandising disponible"));
          }

          final merchList = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Banner del evento
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/banner_bad_bunny.jpg",
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "MERCHANDISING OFICIAL",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 20),

              // Lista de productos
              ...merchList.map((sku) => MerchCard(sku: sku)).toList(),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }
}

// ========================================================
// TARJETA DE PRODUCTO MEJORADA
// ========================================================
class MerchCard extends ConsumerStatefulWidget {
  final MerchSku sku;
  const MerchCard({super.key, required this.sku});

  @override
  ConsumerState<MerchCard> createState() => _MerchCardState();
}

class _MerchCardState extends ConsumerState<MerchCard> {
  MerchVariant? selectedVariant;
  late Future<List<MerchVariant>> futureVariants;

  // MAPA DE IMÁGENES (todas corregidas y funcionando)
  static const Map<String, String> productImages = {
    // Nombre del producto en minúsculas → URL completa
    'polo oficial negro': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/polo_negro.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvcG9sb19uZWdyby5qcGciLCJpYXQiOjE3NjQ0MzA0MTMsImV4cCI6MTc2NzAyMjQxM30.7xZU4Su51zEz8vjc7RUro80rLoN6I2Ndew8R-wEzSgU',
    'taza bad bunny world tour': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/taza_verano.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvdGF6YV92ZXJhbm8uanBnIiwiaWF0IjoxNzY0NDU1NzA1LCJleHAiOjE3NjcwNDc3MDV9.VjaG-pom1nWLi20N1w0qIAqhVmvCJYsS0lk7BPG93SU',
    'bolsas de tela': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Bolsas_de_Tela.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvQm9sc2FzX2RlX1RlbGEuanBnIiwiaWF0IjoxNzY0NDYwMzAyLCJleHAiOjE3NjcwNTIzMDJ9.ub6y6kVB3jT5Fgf4DVokyWjXTz2nC4M997-mweQAtLs',
    'calcetines': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/calcetines_negro.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvY2FsY2V0aW5lc19uZWdyby5qcGciLCJpYXQiOjE3NjQ0NTU3MzYsImV4cCI6MTc2NzA0NzczNn0._6sM9Wck9iOXT5AuduRvOyoiIFrwyjY1yT4OVeVQvIU',
    'chaquetas ligeras': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Chaquetas_Ligeras_negro.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvQ2hhcXVldGFzX0xpZ2VyYXNfbmVncm8uanBnIiwiaWF0IjoxNzY0NDYwNDI3LCJleHAiOjE3NjcwNTI0Mjd9.Hfu09JlLB04EFY2nXo3w-6c6O_KB9ejZfffWhVF2KMk',
    'llaveros': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/llaveros.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvbGxhdmVyb3MuanBnIiwiaWF0IjoxNzY0NDYxMjczLCJleHAiOjE3OTU5OTcyNzN9.DW46VeaTbilhdoVxwzi1H2EUawI9w-l1kEWlQ2U_zUo',
    'misteri box': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Misteri_box.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvTWlzdGVyaV9ib3guanBnIiwiaWF0IjoxNzY0NDU1NzU2LCJleHAiOjE3NjcwNDc3NTZ9.-wUpDQ7ehL2c9OywKmd_jgmWjzDnkvS8hcr5MwFOaDk',
    'pads': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Pads.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvUGFkcy5qcGciLCJpYXQiOjE3NjQ0NTU3NjcsImV4cCI6MTc2NzA0Nzc2N30.aiedJnaFMtHWoGk5vgfU3Qi3_pD5dCfXqGLtKN5iFqw',
    'posters': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Posters.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvUG9zdGVycy5qcGciLCJpYXQiOjE3NjQ0NjA0MDAsImV4cCI6MTc2NzA1MjQwMH0.RQ-NkmiqFXCSnUbWsn5a7a9u0tadxqo9CsijTo2KrT4',
    'pulsera led': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Pulsera_led_silicona.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvUHVsc2VyYV9sZWRfc2lsaWNvbmEuanBnIiwiaWF0IjoxNzY0NDU1NzgyLCJleHAiOjE3NjcwNDc3ODJ9.hPKhmpZccLYUJA8rX9Z2fE1U8zY4hxUZMuipyUcVOmo',
    'sudadera': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/sudadera_negro.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvc3VkYWRlcmFfbmVncm8uanBnIiwiaWF0IjoxNzY0NDU1Nzg4LCJleHAiOjE3NjcwNDc3ODh9.Vb7BIPC9FQX3xvhL7BUUvHfOx55_y6PGh15Ljxm2lIs',
    'termos': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Termos.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvVGVybW9zLmpwZyIsImlhdCI6MTc2NDQ2MDMzNSwiZXhwIjoxNzY3MDUyMzM1fQ.RUSo_GeSglSLevthO21rfVIXcR8QnR_xDToTNcsJ7zw',
  };

@override
void initState() {
  super.initState();
  futureVariants = SupabaseService.getVariants(widget.sku.id);
}

  String _getProductImage() {
    final lowerName = widget.sku.name.toLowerCase().trim();

    // Verificaciones específicas en orden de prioridad
    if (lowerName.contains('llavero')) return productImages['llaveros']!;
    if (lowerName.contains('chaqueta')) return productImages['chaquetas ligeras']!;
    if (lowerName.contains('bolsa') || lowerName.contains('tela')) return productImages['bolsas de tela']!;
    if (lowerName.contains('termo')) return productImages['termos']!;
    if (lowerName.contains('poster') || lowerName.contains('cartel')) return productImages['posters']!;
    if (lowerName.contains('taza')) return productImages['taza bad bunny world tour']!;
    if (lowerName.contains('sudadera')) return productImages['sudadera']!;
    if (lowerName.contains('calcetín') || lowerName.contains('calcetin')) return productImages['calcetines']!;
    if (lowerName.contains('pulsera')) return productImages['pulsera led']!;
    if (lowerName.contains('misteri') || lowerName.contains('mystery') || lowerName.contains('caja')) return productImages['misteri box']!;
    if (lowerName.contains('pad')) return productImages['pads']!;
    if (lowerName.contains('polo')) return productImages['polo oficial negro']!;

    // Si no encuentra ninguna coincidencia específica, usa la imagen por defecto
    return productImages['polo oficial negro']!;
  }

@override
Widget build(BuildContext context) {
  final imageUrl = _getProductImage();

  return Card(
    elevation: 8,
    margin: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN DEL PRODUCTO
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 80),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            widget.sku.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "S/ ${widget.sku.price.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
          ),
          const SizedBox(height: 16),

          // SELECTOR DE TALLAS (solo si tiene variantes)
          FutureBuilder<List<MerchVariant>>(
            future: futureVariants,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              final hasVariants = snapshot.hasData && snapshot.data!.isNotEmpty;

              if (!hasVariants) {
                // Producto sin tallas (taza, llavero, etc.)
                return ElevatedButton.icon(
                  onPressed: () => _addToCart(null),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text("AGREGAR AL CARRITO"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }

              // Producto con tallas
              final variants = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Talla:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: variants.map((v) {
                      final disponible = v.stock > 0;
                      return FilterChip(
                        label: Text(v.size),
                        selected: selectedVariant?.id == v.id,
                        selectedColor: Colors.purple.shade100,
                        checkmarkColor: Colors.purple.shade900,
                        onSelected: disponible
                            ? (selected) {
                          setState(() {
                            selectedVariant = selected ? v : null;
                          });
                        }
                            : null,
                        backgroundColor: disponible ? Colors.grey[200] : Colors.red[100],
                        labelStyle: TextStyle(
                          color: disponible ? Colors.black87 : Colors.red.shade700,
                          fontWeight: selectedVariant?.id == v.id ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: selectedVariant == null ? null : () => _addToCart(selectedVariant),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("AGREGAR AL CARRITO", style: TextStyle(fontSize: 17)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        disabledBackgroundColor: Colors.grey[400],
                      ),
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

void _addToCart(MerchVariant? variant) {
  final item = CartItem(
    type: CartItemType.merch,
    eventId: widget.sku.eventId,
    merchSkuId: widget.sku.id,
    selectedVariant: variant,
    quantity: 1,
    unitPrice: widget.sku.price,
  );

  ref.read(cartProvider.notifier).update((state) => state.addItem(item));

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("${widget.sku.name}${variant != null ? " (${variant!.size})" : ""} agregado al carrito"),
      backgroundColor: Colors.purple,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
}