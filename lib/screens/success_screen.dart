// lib/screens/success_screen.dart
import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String codigo;
  final double total;
  final String deliveryOption;     // 'pickup' o 'delivery'
  final String? trackingNumber;    // solo si es delivery

  const SuccessScreen({
    super.key,
    required this.codigo,
    required this.total,
    required this.deliveryOption,
    this.trackingNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Check gigante
              const Icon(Icons.check_circle, size: 130, color: Colors.green),

              const SizedBox(height: 30),

              Text(
                "¡PAGO EXITOSO!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Código del pedido
              const Text("Tu código de pedido:", style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 8),
              SelectableText(
                codigo,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3),
              ),

              const SizedBox(height: 30),

              // Opción de envío / recogida
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: deliveryOption == 'pickup' ? Colors.orange.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: deliveryOption == 'pickup' ? Colors.orange.shade400 : Colors.blue.shade400,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      deliveryOption == 'pickup' ? Icons.location_on : Icons.local_shipping,
                      size: 40,
                      color: deliveryOption == 'pickup' ? Colors.orange.shade700 : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      deliveryOption == 'pickup'
                          ? "Recogerás en el evento"
                          : "Envío a domicilio",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: deliveryOption == 'pickup' ? Colors.orange.shade900 : Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),

              // Tracking si es envío
              if (trackingNumber != null) ...[
                const SizedBox(height: 25),
                const Text("Número de seguimiento:", style: TextStyle(fontSize: 17, color: Colors.grey)),
                const SizedBox(height: 8),
                SelectableText(
                  trackingNumber!,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
              ],

              const SizedBox(height: 40),

              Text(
                "Total pagado: S/ ${total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home, size: 28),
                  label: const Text("Volver al inicio", style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}