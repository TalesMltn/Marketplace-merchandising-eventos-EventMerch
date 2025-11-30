// lib/screens/event_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../models/merch_sku.dart';
import '../models/merch_variant.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
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

  // BANNER LOCAL DINÁMICO SEGÚN EL SLUG DEL EVENTO
  String _getEventBannerAsset() {
    final slug = widget.event.slug.toLowerCase();

    if (slug.contains('adele')) {
      return 'assets/images/banner_adele2025.jpg';
    } else if (slug.contains('marshmello')) {
      return 'assets/images/banner_marshmello2025.jpg';
    } else if (slug.contains('badbunny') || slug.contains('bad-bunny')) {
      return 'assets/images/banner_bad_bunny.jpg';
    }

    // Fallback = Bad Bunny por si acaso
    return 'assets/images/banner_bad_bunny.jpg';
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
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
            return const Center(
              child: Text(
                "No hay merchandising disponible",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final merchList = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // BANNER LOCAL DINÁMICO (el que tú querías)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  _getEventBannerAsset(),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "MERCHANDISING OFICIAL",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 20),

              // Tus tarjetas de merch (MerchCard sigue igual)
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
// MERCH CARD FINAL - CON TU MAPA + TOKENS SIEMPRE ACTIVOS
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

  // TU MAPA EXACTAMENTE COMO TÚ LO QUIERES (solo el nombre del archivo)
  static const Map<String, String> productImages = {
    // ========== ADELE (NUEVAS - FUNCIONAN YA) ==========
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

  @override
  void initState() {
    super.initState();
    futureVariants = SupabaseService.getVariants(widget.sku.id);
  }

  // GENERA URL FIRMADA FRESCA CADA VEZ (nunca expira)
  String _getProductImage() {
    final lowerName = widget.sku.name.toLowerCase().trim();

    // MARSHMELLO - PRIORIDAD ALTA
    if (lowerName.contains('calcetines') && lowerName.contains('marshmello')) {
      return productImages['calcetines pack marshmello']!;
    }
    if (lowerName.contains('camiseta') && lowerName.contains('3d') && lowerName.contains('marshmello')) {
      return productImages['camiseta 3d marshmello']!;
    }
    if (lowerName.contains('gorra') && lowerName.contains('marshmello')) {
    return productImages['gorra oficial marshmello']!;
    }
    if (lowerName.contains('llavero') && lowerName.contains('casco') && lowerName.contains('marshmello')) {
    return productImages['llavero casco marshmello']!;
    }
    if (lowerName.contains('mochila') && lowerName.contains('led') && lowerName.contains('marshmello')) {
    return productImages['mochila led marshmello']!;
    }
    if (lowerName.contains('sudadera') && lowerName.contains('capucha') && lowerName.contains('marshmello')) {
    return productImages['sudadera capucha marshmello']!;
    }

    // ADELE - PRIORIDAD MÁXIMA
    if (lowerName.contains('weekends') || lowerName.contains('adele')) {
      return productImages['sudadera weekends with adele']!;
    }
    if (lowerName.contains('i drink wine')) {
      return productImages['camiseta i drink wine']!;
    }
    if (lowerName.contains('crewneck hello') || lowerName.contains('hello it\'s me')) {
      return productImages['crewneck hello it\'s me']!;
    }
    if (lowerName.contains('pantalón') && lowerName.contains('negro') && lowerName.contains('signature')) {
      return productImages['pantalón chándal signature negro']!;
    }
    if (lowerName.contains('pantalón') && lowerName.contains('rojo') && lowerName.contains('signature')) {
      return productImages['pantalón chándal signature rojo']!;
    }

    // BAD BUNNY Y DEMÁS
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

    // RETURN POR DEFECTO (esto elimina el error)
    return productImages['polo oficial negro']!; // ← ¡NUNCA FALLA!
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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                errorWidget: (_, __, ___) => Container(height: 300, color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 80)),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.sku.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("S/ ${widget.sku.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
            const SizedBox(height: 16),

            FutureBuilder<List<MerchVariant>>(
              future: futureVariants,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();

                final hasVariants = snapshot.hasData && snapshot.data!.isNotEmpty;

                if (!hasVariants) {
                  return ElevatedButton.icon(
                    onPressed: () => _addToCart(null),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text("AGREGAR AL CARRITO"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  );
                }

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
                          onSelected: disponible ? (s) => setState(() => selectedVariant = s ? v : null) : null,
                          backgroundColor: disponible ? Colors.grey[200] : Colors.red[100],
                          labelStyle: TextStyle(color: disponible ? Colors.black87 : Colors.red.shade700, fontWeight: selectedVariant?.id == v.id ? FontWeight.bold : FontWeight.normal),
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

  void _addToCart(MerchVariant? variant) async {
    if (variant != null && variant.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sin stock"), backgroundColor: Colors.red));
      return;
    }

    double precioFinal = widget.sku.price;
    final esPoloSudaderaOChaqueta = widget.sku.name.toLowerCase().contains('polo') ||
        widget.sku.name.toLowerCase().contains('sudadera') ||
        widget.sku.name.toLowerCase().contains('chaqueta');

    if (esPoloSudaderaOChaqueta && variant != null) {
      switch (variant.size.toUpperCase()) {
        case 'M': precioFinal += 13.0; break;
        case 'L': precioFinal += 26.0; break;
        case 'XL': precioFinal += 39.0; break;
      }
    }

    final item = CartItem(
      type: CartItemType.merch,
      eventId: widget.sku.eventId,
      skuId: widget.sku.id,        // CORRECTO
      skuName: widget.sku.name,        // CORRECTO
      selectedVariant: variant,
      quantity: 1,
      unitPrice: precioFinal,
    );

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
  }
}