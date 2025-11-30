// lib/screens/cart_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  // TU MAPA EXACTO CON URLs FIRMADAS COMPLETAS (nunca expiran a expirar mientras no cambies el token)
  static const Map<String, String> productImages = {

    // ADELE - PRIORIDAD MÁXIMA
    'sudadera weekends with adele': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Sudadera_Weekends_With_Adele.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvU3VkYWRlcmFfV2Vla2VuZHNfV2l0aF9BZGVsZS5qcGciLCJpYXQiOjE3NjQ1MzQxMDcsImV4cCI6MTc2NzEyNjEwN30.81l_Lro9aR6n4l-8m3xI26XTdANOBz2l7yWDv59AdQ0',
    'camiseta i drink wine': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Camiseta_I_Drink_Wine.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvQ2FtaXNldGFfSV9Ecmlua19XaW5lLmpwZyIsImlhdCI6MTc2NDUzNDAyMiwiZXhwIjoxNzY3MTI2MDIyfQ.yW53Dd4aQz4u4AxBrS835QCrI7Kcizjg90Irc1i4Mew',
    'crewneck hello it\'s me': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Crewneck_Hello_Its_Me.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvQ3Jld25lY2tfSGVsbG9fSXRzX01lLmpwZyIsImlhdCI6MTc2NDUzNDA0MywiZXhwIjoxNzY3MTI2MDQzfQ.ty1SmdlgCPlkbd_RQODtSfaSW6yHCnTFNLFpjJZ7q-U',
    'pantalón chándal signature negro': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Pantalon_Chandal_Signature_Negro.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvUGFudGFsb25fQ2hhbmRhbF9TaWduYXR1cmVfTmVncm8uanBnIiwiaWF0IjoxNzY0NTM0MDY0LCJleHAiOjE3NjcxMjYwNjR9.E4_jyerzirQER1bUgA97YjdD-qyfN687VoyyvjEvT9A',
    'pantalón chándal signature rojo': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Pantalon_Chandal_Signature_Rojo.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvUGFudGFsb25fQ2hhbmRhbF9TaWduYXR1cmVfUm9qby5qcGciLCJpYXQiOjE3NjQ1MzQwODQsImV4cCI6MTc2NzEyNjA4NH0.SnQ7y3gYpZ49TCS-XI9SRgmrR_slEl3xOVD4tOyvklI',

    // ========== MARSHMELLO 2025 ==========
    'calcetines pack marshmello': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Calcetines_Pack_Marshmello.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvQ2FsY2V0aW5lc19QYWNrX01hcnNobWVsbG8uanBnIiwiaWF0IjoxNzY0NTM2NTk3LCJleHAiOjE3NjcxMjg1OTd9.XAWbTcEuH_IE6SKWqkhmB0pMngkdRiOphs8xFjCHiMs',
    'camiseta 3d marshmello': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Camiseta%20_3D%20_Marshmello.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvQ2FtaXNldGEgXzNEIF9NYXJzaG1lbGxvLmpwZyIsImlhdCI6MTc2NDUzNjYxMiwiZXhwIjoxNzY3MTI4NjEyfQ.adMDQwUF6a-7A9-Fgp0XW32wh_p9GT7rLx4xtQtNw64',
    'gorra oficial marshmello': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Gorra_Oficial_Marshmello.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvR29ycmFfT2ZpY2lhbF9NYXJzaG1lbGxvLmpwZyIsImlhdCI6MTc2NDUzNjYzMiwiZXhwIjoxNzY3MTI4NjMyfQ.zbFP4GrQUoJLmpaAOFNak2JMtltStSZAu2yHNlczvZ0',
    'llavero casco marshmello': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Llavero_Casco_Marshmello.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvTGxhdmVyb19DYXNjb19NYXJzaG1lbGxvLmpwZyIsImlhdCI6MTc2NDUzNjY1MCwiZXhwIjoxNzY3MTI4NjUwfQ.uxuzxrm0fJf0Bcts53_iBRBYKcHZkYm-BLE5IFt0ahg',
    'mochila led marshmello': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Mochila_LED_Marshmello.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvTW9jaGlsYV9MRURfTWFyc2htZWxsby5qcGciLCJpYXQiOjE3NjQ1MzY2NjksImV4cCI6MTc2NzEyODY2OX0.M5A_5BhQLws7rhl9CFZWtwlwIpDgjnMDp0GIyGPGluo',
    'sudadera capucha marshmello': 'https://thmlvvgerforijewihgf.supabase.co/storage/v1/object/sign/merch-images/Sudadera_Capucha_Marshmello.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV84NmEzNGY5My1lMjliLTRiNWQtYjZiYy1jOTMzYjQzNjE3MjciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJtZXJjaC1pbWFnZXMvU3VkYWRlcmFfQ2FwdWNoYV9NYXJzaG1lbGxvLmpwZyIsImlhdCI6MTc2NDUzNjY4MSwiZXhwIjoxNzY3MTI4NjgxfQ.cf5eQFtcll4caGjW4DDTZF_iAogRW8jvl1fG8I07W7g',

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

    // MARSHMELLO - PRIORIDAD MÁXIMA (siempre primero)
    if (lower.contains('marshmello')) {
      if (lower.contains('calcetines')) return productImages['calcetines pack marshmello']!;
      if (lower.contains('camiseta') && lower.contains('3d')) return productImages['camiseta 3d marshmello']!;
      if (lower.contains('gorra')) return productImages['gorra oficial marshmello']!;
      if (lower.contains('llavero') && lower.contains('casco')) return productImages['llavero casco marshmello']!;
      if (lower.contains('mochila') && lower.contains('led')) return productImages['mochila led marshmello']!;
      if (lower.contains('sudadera') && lower.contains('capucha')) return productImages['sudadera capucha marshmello']!;
    }
    // ADELE - PRIORIDAD MÁXIMA
    if (lower.contains('weekends') || lower.contains('adele')) return productImages['sudadera weekends with adele']!;
    if (lower.contains('i drink wine')) return productImages['camiseta i drink wine']!;
    if (lower.contains('crewneck') || lower.contains('hello it')) return productImages['crewneck hello it\'s me']!;
    if (lower.contains('pantalón') && lower.contains('negro')) return productImages['pantalón chándal signature negro']!;
    if (lower.contains('pantalón') && lower.contains('rojo')) return productImages['pantalón chándal signature rojo']!;

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
                          item.selectedVariant != null ? "Talla: ${item.selectedVariant!.size}" : "Talla única",
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

      // AQUÍ EMPIEZA TODO LO NUEVO (reemplaza tu bottomNavigationBar viejo)
      bottomNavigationBar: cart.items.isNotEmpty
          ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SUBTOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal", style: TextStyle(fontSize: 18)),
                Text("S/ ${notifier.subtotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),

            // DESCUESTO AUTOMÁTICO
            if (notifier.discountPercentage > 0) ...[
              Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.green.shade600, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notifier.discountText,
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                  ),
                  Text("-S/ ${notifier.discountAmount.toStringAsFixed(2)}", style: TextStyle(color: Colors.green.shade700, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20, thickness: 1),
            ],

            // TOTAL FINAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total a pagar", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("S/ ${notifier.totalWithDiscount.toStringAsFixed(2)}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
              ],
            ),

            const SizedBox(height: 16),

            // MENSAJE MOTIVADOR
            if (notifier.discountPercentage < 15)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade400),
                ),
                child: Text(
                  notifier.nextDiscountMessage,
                  style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            // BOTÓN DE CHECKOUT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // NAVEGACIÓN REAL AL CHECKOUT (¡YA FUNCIONA TODO!)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                  shadowColor: Colors.purple.withOpacity(0.5),
                ),
                child: const Text(
                  "Continuar al pago",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }
}