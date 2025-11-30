// lib/screens/report_screen.dart
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte de Ventas"),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .rpc('sales_by_event')
            .select()
            .withConverter((data) => List<Map<String, dynamic>>.from(data)),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error al cargar reporte",
                    style: TextStyle(fontSize: 18, color: Colors.red.shade700),
                  ),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }

          // Sin datos
          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text(
                "No hay ventas registradas aún",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Éxito: mostramos el reporte
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, i) {
              final row = data[i];
              final eventName = row['event_name'] ?? 'Evento desconocido';
              final totalSales = (row['total_sales'] ?? 0.0).toStringAsFixed(2);
              final itemsSold = row['items_sold'] ?? 0;

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: Text(
                      eventName[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ),
                  title: Text(
                    eventName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    "$itemsSold productos vendidos",
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Text(
                    "S/ $totalSales",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
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