// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _recogidaEnEvento = true;
  bool _aceptaTerminos = false;
  bool _procesando = false;

  @override
  void dispose() {
    _dniCtrl.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final totalFinal = cart.total + (_recogidaEnEvento ? 0.0 : 20.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Datos de compra", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextFormField(
                controller: _dniCtrl,
                decoration: const InputDecoration(labelText: "DNI", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "DNI requerido";
                  if (v.length != 8 || !RegExp(r'^\d+$').hasMatch(v)) return "DNI inválido";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombres y apellidos", border: OutlineInputBorder()),
                validator: (v) => v?.trim().isNotEmpty == true ? null : "Campo requerido",
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(labelText: "Teléfono", border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => (v?.length ?? 0) >= 9 ? null : "Mínimo 9 dígitos",
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email (opcional)", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 30),
              const Text("Método de entrega", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile<bool>(
                title: const Text("Recogida en el evento (GRATIS)"),
                value: true,
                groupValue: _recogidaEnEvento,
                onChanged: (v) => setState(() => _recogidaEnEvento = v!),
              ),
              RadioListTile<bool>(
                title: const Text("Envío a domicilio (+ S/20)"),
                value: false,
                groupValue: _recogidaEnEvento,
                onChanged: (v) => setState(() => _recogidaEnEvento = v!),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _aceptaTerminos,
                    onChanged: (v) => setState(() => _aceptaTerminos = v!),
                  ),
                  const Expanded(child: Text("Acepto los términos y condiciones")),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                  ),
                  onPressed: (_aceptaTerminos && !_procesando && cart.itemCount > 0)
                      ? () => _procesarPago(totalFinal)
                      : null,
                  child: _procesando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "PAGAR S/ ${totalFinal.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _procesarPago(double totalFinal) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _procesando = true);

    try {
      final cart = ref.read(cartProvider);
      final codigo = "EV${DateTime.now().millisecondsSinceEpoch}";

      // ¡AHORA SÍ FUNCIONA!
      ref.read(cartProvider.notifier).updateDeliveryOption(
        _recogidaEnEvento ? 'pickup' : 'shipping',
      );

      await Supabase.instance.client.from('orders').insert({
        'code': codigo,
        'event_id': cart.items.first.eventId,
        'dni': _dniCtrl.text.trim(),
        'customer_name': _nombreCtrl.text.trim(),
        'phone': _telefonoCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'total_amount': totalFinal,
        'delivery_option': _recogidaEnEvento ? 'pickup' : 'shipping',
        'status': 'paid',
        'pickup_code': _recogidaEnEvento ? codigo : null,
        'items': cart.items.map((i) => i.toJson()).toList(),
        'created_at': DateTime.now().toIso8601String(),
      });

      ref.read(cartProvider.notifier).clear();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SuccessScreen(codigo: codigo, total: totalFinal)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }
}

// SuccessScreen (sin cambios)
class SuccessScreen extends StatelessWidget {
  final String codigo;
  final double total;
  const SuccessScreen({super.key, required this.codigo, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 120, color: Colors.green),
              const SizedBox(height: 20),
              Text("¡PAGO EXITOSO!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
              const SizedBox(height: 20),
              const Text("Código de pedido:", style: TextStyle(fontSize: 20)),
              SelectableText(codigo, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Text("Total: S/ ${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text("Volver al inicio"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}