// lib/screens/picking_screen.dart
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class PickingScreen extends StatefulWidget {
  final String eventId;
  const PickingScreen({super.key, required this.eventId});

  @override
  State<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Picking - Recogida en Evento"),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('orders')
            .select(''', order_items!inner(merch_sku_id, merch_variants(size)) ''')
            .eq('event_id', widget.eventId)
            .eq('status', 'paid')
            .withConverter((data) => List<Map<String, dynamic>>.from(data)),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // No hay datos
          final orders = snapshot.data;
          if (orders == null || orders.isEmpty) {
            return const Center(
              child: Text(
                "No hay pedidos para entregar",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Éxito: mostramos los pedidos
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final order = orders[i];
              final items = (order['order_items'] as List? ?? []);

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    "Orden #${order['id'].toString().substring(0, 8).toUpperCase()}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    items
                        .map((e) => "${e['merch_variants']['size']} ×${e['quantity']}")
                        .join('  •  '),
                    style: const TextStyle(fontSize: 15),
                  ),
                  trailing: order['delivered'] == true
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 36)
                      : ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text("ENTREGADO"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () async {
                      await supabase
                          .from('orders')
                          .update({'delivered': true})
                          .eq('id', order['id']);
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}