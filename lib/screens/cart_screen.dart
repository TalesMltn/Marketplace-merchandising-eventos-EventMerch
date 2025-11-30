// lib/screens/cart_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  // TU MAPA EXACTO CON URLs FIRMADAS COMPLETAS (nunca expiran a expirar mientras no cambies el token)
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

  String _getProductImageUrl(String? skuName) {
    if (skuName == null) return productImages['polo oficial negro']!;

    final lower = skuName.toLowerCase().trim();

    if (lower.contains('llavero')) return productImages['llaveros']!;
    if (lower.contains('chaqueta')) return productImages['chaquetas ligeras']!;
    if (lower.contains('bolsa') || lower.contains('tela')) return productImages['bolsas de tela']!;
    if (lower.contains('termo')) return productImages['termos']!;
    if (lower.contains('poster') || lower.contains('cartel')) return productImages['posters']!;
    if (lower.contains('taza')) return productImages['taza bad bunny world tour']!;
    if (lower.contains('sudadera') || lower.contains('hoodie')) return productImages['sudadera']!;
    if (lower.contains('calcet')) return productImages['calcetines']!;
    if (lower.contains('pulsera')) return productImages['pulsera led']!;
    if (lower.contains('misteri') || lower.contains('mystery') || lower.contains('box')) {
      return productImages['misteri box']!;
    }
    if (lower.contains('pad')) return productImages['pads']!;
    if (lower.contains('polo')) return productImages['polo oficial negro']!;

    return productImages['polo oficial negro']!; // fallback
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito"),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: cart.items.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text("Tu carrito está vacío", style: TextStyle(fontSize: 22, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // IMAGEN DIRECTA CON TU URL FIRMADA (sin FutureBuilder = más rápido)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: _getProductImageUrl(item.skuName),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.skuName ?? "Producto",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.selectedVariant != null
                              ? "Talla: ${item.selectedVariant!.size}"
                              : "Talla única",
                          style: TextStyle(color: Colors.grey[700], fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "S/ ${item.unitPrice.toStringAsFixed(2)} c/u",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: () => notifier.updateQuantity(item, item.quantity - 1),
                                    color: Colors.purple.shade700,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text("${item.quantity}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () => notifier.updateQuantity(item, item.quantity + 1),
                                    color: Colors.purple.shade700,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.red, size: 32),
                              onPressed: () {
                                notifier.removeItem(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Eliminado"), duration: Duration(seconds: 1)),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: cart.items.isNotEmpty
          ? Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total:", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(
              "S/ ${cart.total.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
            ),
          ],
        ),
      )
          : null,
    );
  }
}